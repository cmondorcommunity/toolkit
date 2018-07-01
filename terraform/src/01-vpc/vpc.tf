module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment}-${var.project}-${var.org}"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    org         = "${var.org}"
    project     = "${var.project}"
    environment = "${var.environment}"
  }

  public_subnet_tags = {
    subnet = "public"
  }

  private_subnet_tags = {
    subnet = "private"
  }

}
