resource "aws_ecr_repository" "main" {
  name = "${var.project}"
}

//TODO
//resource "aws_ecr_lifecycle_policy" "main" {
//  policy = ""
//  repository = ""
//}
//
//resource "aws_ecr_repository_policy" "main" {
//  policy = ""
//  repository = ""
//}
