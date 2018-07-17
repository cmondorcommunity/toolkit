variable "domain" {}

variable "environment" {}

variable "org" {}

variable "project" {}

variable "EFS_HOST_PATH" {
  default = "/mnt/efs" #see files/ecs_user_data.sh.tpl before changing
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
  default     = ""
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
  default     = "10.0.0.0/8"
}
