locals {
    vpc_to_deploy = var.environments[var.env]["regional_vpcs"][var.region]
    gws_to_deploy = var.vpc_ext_gateways[var.vpn_gw_set]
    private_subnets = [ for subnet in aws_subnet.vpc_subnets : subnet if subnet.map_public_ip_on_launch == false ]
    public_subnets  = [ for subnet in aws_subnet.vpc_subnets : subnet if subnet.map_public_ip_on_launch != false ]
    # get only one private subnet for each az in region for vpc-attachement to tgw
    # method from  https://stackoverflow.com/questions/67408965/get-first-unique-key-from-map-with-common-values
    # result in subnet_uniq_ids
    subnet_priv_ids     = { for subnet in aws_subnet.vpc_subnets : subnet.id => subnet.availability_zone if subnet.map_public_ip_on_launch == false }
    subnet_tmp_map = zipmap(  values(local.subnet_priv_ids),  keys(local.subnet_priv_ids) )
    subnet_uniq_ids = values (local.subnet_tmp_map)
}

# create vpcs
resource "aws_vpc" "regional_vpc" {
    cidr_block       = local.vpc_to_deploy.main_network
    instance_tenancy = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.env}-${local.vpc_to_deploy.region_short}"
        env = var.env
    }
}

# create subnets
resource "aws_subnet" "vpc_subnets" {
    for_each = {
        for key, subnet in local.vpc_to_deploy.az_subnets : key => subnet
    }

    vpc_id     = aws_vpc.regional_vpc.id
    cidr_block = each.value.ip_range
    availability_zone = each.value.az_geo
    map_public_ip_on_launch = each.value.is_public
    tags = {
        Name = each.key
        env  = var.env
    }
    depends_on = [ aws_vpc.regional_vpc ]
}

# transit gateway
resource "aws_ec2_transit_gateway" "tgw" {
    description                     = "central router"
    amazon_side_asn                 = var.region_side_asns
    auto_accept_shared_attachments  = "disable"
    default_route_table_association = "enable"
    default_route_table_propagation = "enable"
    dns_support                     = "enable"
    multicast_support               = "disable"
    # transit_gateway_cidr_blocks   = ""
    vpn_ecmp_support                = "disable"
    tags = {
        Name = "tgw-${local.vpc_to_deploy.region_short}"
        env  = var.env
    }
}

# remote ipsec peers
resource "aws_customer_gateway" "ext_gateways_items" {
    for_each   = local.gws_to_deploy
    bgp_asn    = each.value.peer_asn
    ip_address = each.value.ip_address
    type       = "ipsec.1"
    tags = {
        Name = each.key
        env  = var.env
    }
}

# ipsec tunnels
resource "aws_vpn_connection" "ipsec_peer_items" {
    for_each                = local.gws_to_deploy
    customer_gateway_id     = aws_customer_gateway.ext_gateways_items[each.key].id
    type                    = aws_customer_gateway.ext_gateways_items[each.key].type

    transit_gateway_id      = aws_ec2_transit_gateway.tgw.id
    tunnel1_inside_cidr     = each.value.interface_ip_range
    tunnel1_preshared_key   = each.value.shared_secret
    tunnel2_inside_cidr     = each.value.interface_ip_range_2
    tunnel2_preshared_key   = each.value.shared_secret
    static_routes_only      = false

    tunnel1_dpd_timeout_action = "restart"
    tunnel2_dpd_timeout_action = "restart"

    tunnel1_ike_versions = ["ikev2"]
    tunnel2_ike_versions = ["ikev2"]

    tags = {
        Name = each.key
        env  = var.env
    }
    depends_on = [ aws_customer_gateway.ext_gateways_items, aws_ec2_transit_gateway.tgw ]
}

# add names-tags to VPN-attachement on TGW
# https://github.com/hashicorp/terraform-provider-aws/issues/16438
resource "aws_ec2_tag" "tag_vpn_attach_item" {
    for_each    = local.gws_to_deploy
    resource_id = aws_vpn_connection.ipsec_peer_items[each.key].transit_gateway_attachment_id
    key         = "Name"
    value       = each.key
    depends_on = [ aws_vpn_connection.ipsec_peer_items, aws_ec2_transit_gateway.tgw ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
    subnet_ids = local.subnet_uniq_ids
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_id             = aws_vpc.regional_vpc.id
    tags = {
        Name = aws_vpc.regional_vpc.tags.Name
    }
    depends_on = [ aws_subnet.vpc_subnets, aws_ec2_transit_gateway.tgw, aws_vpc.regional_vpc ]
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.regional_vpc.id
    tags = {
        Name = "igw-${local.vpc_to_deploy.region_short}"
    }
    depends_on = [ aws_vpc.regional_vpc ]
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.regional_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    route {
        cidr_block = "10.0.0.0/8"
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    }

    route {
        cidr_block = "192.168.0.0/16"
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    }
    tags = {
        Name = "default_to_igw"
    }
    depends_on = [ aws_vpc.regional_vpc, aws_ec2_transit_gateway.tgw, aws_internet_gateway.igw ]
}

# connect public nets to igw route table
resource "aws_route_table_association" "rt_assoc" {
    for_each = {
        for key, subnet in local.public_subnets : key => subnet
    }

    subnet_id      = each.value.id
    route_table_id = aws_route_table.public_route_table.id
    depends_on = [ aws_subnet.vpc_subnets, aws_route_table.public_route_table ]
}

# public ip for nat - gateway
resource "aws_eip" "nat_ip" {
    tags = {
        Name = "nat-ip-igw-${local.vpc_to_deploy.region_short}"
    }
    depends_on  = [ aws_internet_gateway.igw ]
}

# nat gateway for private nets, placed in public net
resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.nat_ip.id
    subnet_id     = aws_subnet.vpc_subnets[local.vpc_to_deploy.natgw_subnet].id    
    tags = {
        Name = "natgw-${local.vpc_to_deploy.region_short}"
    }
    depends_on    = [ aws_internet_gateway.igw, aws_eip.nat_ip, aws_subnet.vpc_subnets ]
}

# add route in vpc route table to tgw
resource "aws_default_route_table" "vpc_route_table" {
    default_route_table_id = aws_vpc.regional_vpc.default_route_table_id

    route {
        cidr_block = "10.0.0.0/8"
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    }

    route {
        cidr_block = "192.168.0.0/16"
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    }

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }

    tags = {
        Name = "private_vpc_rt"
    }
    depends_on = [ aws_vpc.regional_vpc, aws_ec2_transit_gateway.tgw, aws_nat_gateway.natgw ]
}
