resource "aws_s3_bucket" "tf_states" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags {
    Name        = "${var.bucket_name}"
    org         = "${var.org}"
    environment = "${var.environment}"
    project     = "${var.project}"
  }
}
