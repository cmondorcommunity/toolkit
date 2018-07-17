terraform {
  required_version = "~>0.11.7"

  backend "s3" {
    region = "us-west-2"
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "${var.aws_profile}"
}

variable "aws_profile" {
  default = "default"
}
