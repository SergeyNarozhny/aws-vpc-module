variable "env" {
    description      = "Environment name"
    type             = string
    default          = "common"
}

variable "region" {
    description     = "Region full name"
    type            = string
    default         = "eu-central-1"
}

variable "region_side_asns" {
    description     = "Region AWS side asn"
    type            = number
    default         = 64520
}

variable "vpn_gw_set" {
    description     = "Set of remote vpn gateways"
    type            = string
}

# old
variable "environments" {
    type = map(object({
        regional_vpcs = map(object({
            region_short = string
            main_network = string
	        natgw_subnet = string
            az_subnets = map(object({
                ip_range = string
                is_public = bool
                az_geo = string
            }))
        }))
    }))
    default = {
        "global" = {
            # regional vpcs
            regional_vpcs = {
                "eu-central-1" = {
                    region_short = "eu-c1"
                    main_network = "10.120.0.0/20"
                    natgw_subnet = "public-az2"
                    # az-subnets
                    az_subnets = {
                        "private-az2" = {
                            ip_range = "10.120.0.0/24"
                            az_geo = "eu-central-1a"
                            is_public = false
                        },
                        "public-az2" = {
                            ip_range = "10.120.1.0/24"
                            az_geo = "eu-central-1a"
                            is_public = true
                        },
                        "private-az3" = {
                            ip_range = "10.120.2.0/24"
                            az_geo = "eu-central-1b"
                            is_public = false
                        },
                        "public-az3" = {
                            ip_range = "10.120.3.0/24"
                            az_geo = "eu-central-1b"
                            is_public = true
                        },
                        "private-az1" = {
                            ip_range = "10.120.4.0/24"
                            az_geo = "eu-central-1c"
                            is_public = false
                        },
                        "public-az1" = {
                            ip_range = "10.120.5.0/24"
                            az_geo = "eu-central-1c"
                            is_public = true
                        }
                    }
		        },
                "ap-southeast-3" = {
                    region_short = "aps3"
                    main_network = "10.120.32.0/20"
                    natgw_subnet = "public-az1"
                    az_subnets = {
                        "private-az1" = {
                            ip_range = "10.120.32.0/24"
                            az_geo = "ap-southeast-3a"
                            is_public = false
                        },
                        "public-az1" = {
                            ip_range = "10.120.33.0/24"
                            az_geo = "ap-southeast-3a"
                            is_public = true
                        },
                        "private-az3" = {
                            ip_range = "10.120.34.0/24"
                            az_geo = "ap-southeast-3c"
                            is_public = false
                        },
                        "public-az3" = {
                            ip_range = "10.120.35.0/24"
                            az_geo = "ap-southeast-3c"
                            is_public = true
                        },
                        "private-az2" = {
                            ip_range = "10.120.36.0/24"
                            az_geo = "ap-southeast-3b"
                            is_public = false
                        },
                        "public-az2" = {
                            ip_range = "10.120.37.0/24"
                            az_geo = "ap-southeast-3b"
                            is_public = true
                        }
                    }
                }
            }
        }
        "finex" = {
            regional_vpcs = {
                "ap-southeast-3" = {
                    region_short = "aps3"
                    main_network = "10.120.64.0/19"
                    natgw_subnet = "public-prod-dmz-az1"
                    az_subnets = {
                        # prod
                        "private-prod-az1" = {
                            ip_range = "10.120.64.0/24"
                            az_geo = "ap-southeast-3a"
                            is_public = false
                        },
                        "private-prod-az3" = {
                            ip_range = "10.120.65.0/24"
                            az_geo = "ap-southeast-3c"
                            is_public = false
                        },
                        "private-prod-az2" = {
                            ip_range = "10.120.66.0/24"
                            az_geo = "ap-southeast-3b"
                            is_public = false
                        },
                        # prod-dmz
                        "public-prod-dmz-az1" = {
                            ip_range = "10.120.67.0/24"
                            az_geo = "ap-southeast-3a"
                            is_public = true
                        },
                        "public-prod-dmz-az3" = {
                            ip_range = "10.120.68.0/24"
                            az_geo = "ap-southeast-3c"
                            is_public = true
                        },
                        "public-prod-dmz-az2" = {
                            ip_range = "10.120.69.0/24"
                            az_geo = "ap-southeast-3b"
                            is_public = true
                        },
                        # stage
                        "private-stage-az1" = {
                            ip_range = "10.120.70.0/24"
                            az_geo = "ap-southeast-3a"
                            is_public = false
                        },
                        "private-stage-az3" = {
                            ip_range = "10.120.71.0/24"
                            az_geo = "ap-southeast-3c"
                            is_public = false
                        },
                        "private-stage-az2" = {
                            ip_range = "10.120.72.0/24"
                            az_geo = "ap-southeast-3b"
                            is_public = false
                        },
                        # stage-dmz
                        "public-stage-dmz-az1" = {
                            ip_range = "10.120.73.0/24"
                            az_geo = "ap-southeast-3a"
                            is_public = true
                        },
                        "public-stage-dmz-az3" = {
                            ip_range = "10.120.74.0/24"
                            az_geo = "ap-southeast-3c"
                            is_public = true
                        },
                        "public-stage-dmz-az2" = {
                            ip_range = "10.120.75.0/24"
                            az_geo = "ap-southeast-3b"
                            is_public = true
                        }
                    }
                }
            }
        }
    }
}


variable "vpc_ext_gateways"  {
    type = map(map(object({
        hostname_title = string
        interface_id = number
        ip_address = string
        shared_secret = string
        interface_ip_range = string
        interface_ip_range_2 = string
        peer_ip_address = string
        peer_ip_address_2 = string
        advertised_ip_ranges = string
        peer_asn = number
        advertised_route_priority = number
    })))
    default = {
        "global-eu-central-1" = {
            "gw01-sc-ams-1" = {
                hostname_title = "prod-gl-infra-srx01"
                interface_id = 0
                ip_address = "23.109.81.20"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.120.0/30"
                peer_ip_address = "169.254.120.2"
                interface_ip_range_2 = "169.254.120.4/30"
                peer_ip_address_2 = "169.254.120.6"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 0
            },
            "gw01-sc-ams-2" = {
                hostname_title = "prod-gl-infra-srx01-2"
                interface_id = 1
                ip_address = "87.245.215.137"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.120.40/30"
                peer_ip_address = "169.254.120.42"
                interface_ip_range_2 = "169.254.120.44/30"
                peer_ip_address_2 = "169.254.120.46"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 100
            },
            "gw02-sc-ams-1" = {
                hostname_title = "prod-gl-infra-srx02"
                interface_id = 0
                ip_address = "23.109.81.36"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.120.8/30"
                peer_ip_address = "169.254.120.10"
                interface_ip_range_2 = "169.254.120.12/30"
                peer_ip_address_2 = "169.254.120.14"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 0
            },
            "gw02-sc-ams-2" = {
                hostname_title = "prod-gl-infra-srx02-2"
                interface_id = 1
                ip_address = "87.245.215.139"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.120.48/30"
                peer_ip_address = "169.254.120.50"
                interface_ip_range_2 = "169.254.120.52/30"
                peer_ip_address_2 = "169.254.120.54"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 100
            },
            "gw01-eq" = {
                hostname_title = "gw01-eq"
                interface_id = 1
                ip_address = "154.61.138.129"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.120.32/30"
                peer_ip_address = "169.254.120.34"
                interface_ip_range_2 = "169.254.120.36/30"
                peer_ip_address_2 = "169.254.120.38"
                advertised_ip_ranges = ""
                peer_asn = 64611
                advertised_route_priority = 0
            },
            "gw02-eq" = {
                hostname_title = "gw02-eq"
                interface_id = 1
                ip_address = "154.61.138.130"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.120.56/30"
                peer_ip_address = "169.254.120.58"
                interface_ip_range_2 = "169.254.120.60/30"
                peer_ip_address_2 = "169.254.120.62"
                advertised_ip_ranges = ""
                peer_asn = 64611
                advertised_route_priority = 0
            }
        },
        "global-ap-southeast-3" = {
            "gw01-sc-ams-1" = {
                hostname_title = "prod-gl-infra-srx01"
                interface_id = 0
                ip_address = "23.109.81.20"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"                
                interface_ip_range = "169.254.24.0/30"
                peer_ip_address = "169.254.24.2"
                interface_ip_range_2 = "169.254.24.4/30"
                peer_ip_address_2 = "169.254.24.6"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 0
            },
            "gw01-sc-ams-2" = {
                hostname_title = "prod-gl-infra-srx01-2"
                interface_id = 1
                ip_address = "87.245.215.137"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.40/30"
                peer_ip_address = "169.254.24.42"
                interface_ip_range_2 = "169.254.24.44/30"
                peer_ip_address_2 = "169.254.24.46"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 100
            },
            "gw02-sc-ams-1" = {
                hostname_title = "prod-gl-infra-srx02"
                interface_id = 0
                ip_address = "23.109.81.36"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.8/30"
                peer_ip_address = "169.254.24.10"
                interface_ip_range_2 = "169.254.24.12/30"
                peer_ip_address_2 = "169.254.24.14"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 0
            },
            "gw02-sc-ams-2" = {
                hostname_title = "prod-gl-infra-srx02-2"
                interface_id = 1
                ip_address = "87.245.215.139"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.48/30"
                peer_ip_address = "169.254.24.50"
                interface_ip_range_2 = "169.254.24.52/30"
                peer_ip_address_2 = "169.254.24.54"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 100
            },
            "gw01-wz" = {
                hostname_title = "gw01-wz"
                interface_id = 0
                ip_address = "188.42.162.28"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.32/30"
                peer_ip_address = "169.254.24.34"
                interface_ip_range_2 = "169.254.24.36/30"
                peer_ip_address_2 = "169.254.24.38"
                advertised_ip_ranges = ""
                peer_asn = 64612
                advertised_route_priority = 0
            },
            "gw02-wz" = {
                hostname_title = "gw02-wz"
                interface_id = 1
                ip_address = "188.42.162.29"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.56/30"
                peer_ip_address = "169.254.24.58"
                interface_ip_range_2 = "169.254.24.60/30"
                peer_ip_address_2 = "169.254.24.62"
                advertised_ip_ranges = ""
                peer_asn = 64612
                advertised_route_priority = 100
            }
            "fx-prod-1" = {
                hostname_title = "fx-prod-1"
                interface_id = 0
                ip_address = "34.101.22.24"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.64/30"
                peer_ip_address = "169.254.24.66"
                interface_ip_range_2 = "169.254.24.68/30"
                peer_ip_address_2 = "169.254.24.70"
                advertised_ip_ranges = ""
                peer_asn = 64518
                advertised_route_priority = 0
            },
            "fx-prod-2" = {
                hostname_title = "fx-prod-2"
                interface_id = 1
                ip_address = "34.101.26.160"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.24.72/30"
                peer_ip_address = "169.254.24.74"
                interface_ip_range_2 = "169.254.24.76/30"
                peer_ip_address_2 = "169.254.24.78"
                advertised_ip_ranges = ""
                peer_asn = 64518
                advertised_route_priority = 0
            }
        }
        "finex-ap-southeast-3" = {
            "gw01-sc-ams-1" = {
                hostname_title = "prod-gl-infra-srx01"
                interface_id = 0
                ip_address = "23.109.81.20"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"                
                interface_ip_range = "169.254.20.0/30"
                peer_ip_address = "169.254.20.2"
                interface_ip_range_2 = "169.254.20.4/30"
                peer_ip_address_2 = "169.254.20.6"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 0
            },
            "gw01-sc-ams-2" = {
                hostname_title = "prod-gl-infra-srx01-2"
                interface_id = 1
                ip_address = "87.245.215.137"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.8/30"
                peer_ip_address = "169.254.20.10"
                interface_ip_range_2 = "169.254.20.12/30"
                peer_ip_address_2 = "169.254.20.14"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 100
            },            
            "gw02-sc-ams-1" = {
                hostname_title = "prod-gl-infra-srx02"
                interface_id = 0
                ip_address = "23.109.81.36"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.16/30"
                peer_ip_address = "169.254.20.18"
                interface_ip_range_2 = "169.254.20.20/30"
                peer_ip_address_2 = "169.254.20.22"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 0
            },
            "gw02-sc-ams-2" = {
                hostname_title = "prod-gl-infra-srx02-2"
                interface_id = 1
                ip_address = "87.245.215.139"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.24/30"
                peer_ip_address = "169.254.20.26"
                interface_ip_range_2 = "169.254.20.28/30"
                peer_ip_address_2 = "169.254.20.30"
                advertised_ip_ranges = ""
                peer_asn = 64601
                advertised_route_priority = 100
            },
            "gcp-fx-prod-1" = {
                hostname_title = "fx-prod-1"
                interface_id = 0
                ip_address = "34.101.22.24"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.32/30"
                peer_ip_address = "169.254.20.34"
                interface_ip_range_2 = "169.254.20.36/30"
                peer_ip_address_2 = "169.254.20.38"
                advertised_ip_ranges = ""
                peer_asn = 64518
                advertised_route_priority = 0
            },
            "gcp-fx-prod-2" = {
                hostname_title = "fx-prod-2"
                interface_id = 1
                ip_address = "34.101.26.160"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.40/30"
                peer_ip_address = "169.254.20.42"
                interface_ip_range_2 = "169.254.20.44/30"
                peer_ip_address_2 = "169.254.20.46"
                advertised_ip_ranges = ""
                peer_asn = 64518
                advertised_route_priority = 0
            },
            "gw01-wz" = {
                hostname_title = "gw01-wz"
                interface_id = 0
                ip_address = "188.42.162.28"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.48/30"
                peer_ip_address = "169.254.20.50"
                interface_ip_range_2 = "169.254.20.52/30"
                peer_ip_address_2 = "169.254.20.54"
                advertised_ip_ranges = ""
                peer_asn = 64612
                advertised_route_priority = 0
            },
            "gw02-wz" = {
                hostname_title = "gw02-wz"
                interface_id = 1
                ip_address = "188.42.162.29"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.56/30"
                peer_ip_address = "169.254.20.58"
                interface_ip_range_2 = "169.254.20.60/30"
                peer_ip_address_2 = "169.254.20.62"
                advertised_ip_ranges = ""
                peer_asn = 64612
                advertised_route_priority = 100
            },
            "prod-hz-dealer-gw01" = {
                hostname_title = "prod-hz-dealer-gw01"
                interface_id = 0
                ip_address = "159.69.56.123"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.64/30"
                peer_ip_address = "169.254.20.66"
                interface_ip_range_2 = "169.254.20.68/30"
                peer_ip_address_2 = "169.254.20.70"
                advertised_ip_ranges = ""
                peer_asn = 64622
                advertised_route_priority = 0
            },
            "prod-hz-dealer-gw02" = {
                hostname_title = "prod-hz-dealer-gw02"
                interface_id = 1
                ip_address = "213.239.219.218"
                shared_secret = "t9HRdzXAyGZ8nMeenuJ1A2Ws2kC35Pk2"
                interface_ip_range = "169.254.20.72/30"
                peer_ip_address = "169.254.20.74"
                interface_ip_range_2 = "169.254.20.76/30"
                peer_ip_address_2 = "169.254.20.78"
                advertised_ip_ranges = ""
                peer_asn = 64622
                advertised_route_priority = 100
            }
        }
    }
}
