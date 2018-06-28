module "tf_statefile_bucket" {
  source      = "../modules/s3/src"
  bucket_name = "${var.org}-${var.environment}-mybucketname"
  org         = "${var.org}"
  project     = "${var.project}"
  environment = "${var.environment}"
}
