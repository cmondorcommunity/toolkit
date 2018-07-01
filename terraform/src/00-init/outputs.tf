data "aws_caller_identity" "main" {}

output "aws_account_number" {
  value = "${data.aws_caller_identity.main.account_id}"
}
