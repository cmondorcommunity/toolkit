module "tf_statefile_bucket" {
  source      = "../modules/s3/src"
  bucket_name = "${var.environment}-${var.org}-tfstate"
  org         = "${var.org}"
  project     = "${var.project}"
  environment = "${var.environment}"
}
