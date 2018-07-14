Toolkit
=======

Designed to be used as a tool for deploying a Jenkins instance into
AWS capable of running terraform, packer, docker and other orchestration tooling.

## requires

* docker-compose
* Linux/Unix based OS
* ~/.aws directory with
* optional aws profile

## Usage

* clone the repo
* cd into repository root
* replace content and rename .env.example to .env
* run docker-compose
```
docker-compose run deployer
```

### Destroying Cloud Resources
```
docker-compose run -e DESTROY=1 deployer
```

### Repository Layout
* docs/
* docker/ - docker artifacts required for running terraform locally
* jenkins/ - jenkins related artifacts for building, deploying, upgrading
* terraform/ - terraform code for building the Ops VPC Jenkins will live in
* scripts/
* .env.example - example file to use if needed

### Created Resources

ECS
 + DNS
    + Route53 Record
 + VPC
    + aws_vpc
    + aws_subnets
        + 1 public-us-west-2a  <-- ALBs
        + 1 private-us-west-2a  <-- instances, rds, elasticache, etc
    + internet gateway
    + NAT Gateway
    + s3 endpoints
    + default Network ACLs
    + default route tables
 + bastion EC2 instance
 +  ECS cluster
   + IAM policy instance profile
   + IAM trust policy
   + autoscaling group
     + manual scaling 1 instance
     + security groups
     + aws launch configs
 + ECR Docker Registry
 + ECS Service
   + ECS task
   + task definition
 +  ALB
   + security groups

### Required IAM Role
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "NotAction": [
        "aws-portal:*",
        "cloudtrail:*",
        "config:*",
        "directconnect:*",
        "organizations:*",
        "storagegateway:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### TODO
* remove hard coded hacks from prototype development
* integrate domain & SSL Certs (certbot)
* tagging convention
```
org         = "${var.org}"
project     = "${var.project}"
environment = "${var.environment}"
domain      = "${var.domain}"
terraform   = "true"
```
* docs
* Jenkins hardening
* Toolkit Refresh Pipeline
* CodePipeline Example
* Sample Infrastructure Repo
* cookiecutter tooling to create infrastructure repos
