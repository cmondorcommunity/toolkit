output "public_subnets" {
  value = ["${module.vpc.public_subnets}"]
}

output "private_subnets" {
  value = ["${module.vpc.private_subnets}"]
}
