variable "org" {
  default = "myorg"
}

variable "environment" {
  default = "myenv"
}

variable "project" {
  default = "myproj"
}

variable "ECS_IMAGE" {
  default = "762748083517.dkr.ecr.us-west-2.amazonaws.com/toolkit:latest"
}

variable "EFS_HOST_PATH" {
  default = "/efs"
}

variable "ECS_CONTAINER_NAME" {
  default = "toolkit"
}

variable "ECS_VOLUME_NAME" {
  default = "toolkit"
}

variable "ECS_CONTAINER_PATH" {
  default = "/var/jenkins_home"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "key_name" {
  description = "Name of AWS key pair"
  default = ""
}

variable "instance_type" {
  default     = "t2.large"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "1"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}

variable "admin_cidr_ingress" {
  description = "CIDR to allow tcp/22 ingress to EC2 instance"
  default     = "23.240.120.70/32" # replace with workstation egress/external NAT IP
}

