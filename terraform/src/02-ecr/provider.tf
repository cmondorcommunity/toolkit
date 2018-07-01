terraform {
  required_version = "~>0.11.7"
  backend "s3" {
    bucket  = "myenv-myorg-tfstate" #${var.org}-tfstate, interpolation not available here
    region  = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}
