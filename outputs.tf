output "vpc" {
    value = aws_vpc.regional_vpc
}
output "subnets" {
    value = aws_subnet.vpc_subnets
}
output "subnets_ids" {
    value = values(aws_subnet.vpc_subnets)[*].id
}
output "private_subnets_ids" {
    value = toset([ for each in aws_subnet.vpc_subnets : each.id if each.map_public_ip_on_launch == false ])
}
