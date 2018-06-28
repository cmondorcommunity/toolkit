# Module parameter definitions go here

# required module parameters

variable "bucket_name" {}
variable "org" {}
variable "environment" {}
variable "project" {}

# optional module parameters, have defaults
variable "optional_param" {
  default = "optional_value"
}
