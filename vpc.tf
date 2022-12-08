################################################################################
# VPC in eu-west-1
################################################################################

module "vpc_euw1" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
  providers = {
      aws = aws.euw1  
    }
  name = "ksil-euw1"
  cidr = "10.10.0.0/16"
  public_subnets = ["10.10.1.0/24", "10.10.2.0/24","10.10.3.0/24"]
  private_subnets = ["10.10.4.0/24", "10.10.5.0/24","10.10.6.0/24"]
  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  enable_dns_hostnames = true
  enable_dns_support = true 
  enable_nat_gateway = true
  enable_vpn_gateway = false
    
}

################################################################################
# VPC in eu-west-2
################################################################################

module "vpc_euw2" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
  providers = {
      aws = aws.euw2  
    }
  name = "ksil-euw2"
  cidr = "10.12.0.0/16"
  public_subnets = []
  private_subnets = ["10.12.4.0/24", "10.12.5.0/24","10.12.6.0/24"]
  azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  enable_dns_hostnames = true
  enable_dns_support = true
}


resource "aws_vpc_peering_connection" "owner" {
  depends_on = [
    module.vpc_euw1,module.vpc_euw2
  ]
  vpc_id        = module.vpc_euw1.vpc_id
  provider      = aws.euw1
  peer_vpc_id   = module.vpc_euw2.vpc_id
  peer_region   = aws.euw2

  tags = {
    "Name" = "peer_to_accepter"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  depends_on = [
    module.vpc_euw1,module.vpc_euw2
  ]
  provider                  = aws.euw2
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "owner" {
    depends_on = [
    module.vpc_euw1,module.vpc_euw2
    ]
    provider = aws.euw1
    count = length(module.vpc_euw1.private_route_table_ids)
    route_table_id = tolist(module.vpc_euw1.private_route_table_ids)[count.index]
    destination_cidr_block = "10.12.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  
}

resource "aws_route" "accepter" {
    depends_on = [
    module.vpc_euw1,module.vpc_euw2
    ]  
    provider = aws.euw2
    count = length(module.vpc_euw2.private_route_table_ids)
    route_table_id = tolist(module.vpc_euw2.private_route_table_ids)[count.index]
    destination_cidr_block = "10.10.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  
}