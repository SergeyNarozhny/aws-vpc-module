# All AWS VPC env

## Params
- env ("common", "test", "stage", "prod")
- region ("eu-central-1")

## Usage example
```
module "vpc_aws" {
  source = "git@gitlab.fbs-d.com:terraform/modules/aws-vpc.git"

  env = "common"
  region = "eu-central-1"
  region_side_asns = 64520
}
```
