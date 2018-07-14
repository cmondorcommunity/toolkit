module "tf_statefile_bucket" {
  source      = "../modules/s3/src"
  bucket_name = "${var.org}-tlkt-tfstate" #from deployer entrypoint
  org         = "${var.org}"
  project     = "${var.project}"
  environment = "${var.environment}"
}
