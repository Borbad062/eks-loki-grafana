data "aws_availability_zones" "available" {}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "6.5.1"
  name                   = "${var.deployment_prefix}-VPC"
  cidr                   = "10.23.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  public_subnets         = ["10.23.96.0/22", "10.23.100.0/22", "10.23.104.0/22"]
  
  enable_dns_hostnames               = true
  create_igw                         = true
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.deployment_prefix}-VPC"
  }
  
  public_subnet_tags = {
    "Name"                                        = "public-subnet-${var.deployment_prefix}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "Name"                                        = "private-subnet-${var.deployment_prefix}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  public_route_table_tags = {
    "Name" = "public-route-table-${var.deployment_prefix}"
  }

  private_route_table_tags = {
    "Name" = "private-route-table-${var.deployment_prefix}"
  }
}


resource "aws_security_group" "all_worker_node_groups" {
  name   = "${var.deployment_prefix}-for-all-node-groups-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Inbound traffic only from internal VPC"
    cidr_blocks = ["10.23.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "${var.deployment_prefix}-for-all-node-groups-sg"
    "Description" = "Inbound traffic only from internal VPC"
  }
}
