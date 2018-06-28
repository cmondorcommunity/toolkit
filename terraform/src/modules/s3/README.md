S3 Terraform Module
===================

Terraform module meant to stand up s3 buckets

## Usage
```
module "my_s3_bucket" {
    //source = "git::https://github.com/cmondorcommunity/toolkit//terraform/src/modules?ref=master"
    source = "../modules/s3/src"
    bucket_name = "${var.org)-${var.environment}-mybucketname"
    org         = "${var.org}"
    project     = "${var.project}"
    environment = "${var.environment}"
}
```
