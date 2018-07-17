terraform {
  required_version = "~>0.11.7"
}

provider "aws" {
  region  = "us-west-2"
  profile = "${var.aws_profile}"
}

variable "aws_profile" {
  default = "default"
}
