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

* replace .env.example with your secure credentials

```
docker-compose up
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
        + 1 private-us-west-2a  <-- instances, LambdaFunctions
    + internet gateway
    + NAT Gateway
    + s3 endpoints
    + default Network ACLs
    + default route tables
 +  ECS cluster
   + IAM policy instance profile
   + IAM trust policy
   + autoscaling group
     + manual scaling 1 instance
     + security groups
     + aws launch configs
 + ECS Service
   + ECS task
   + task definition
 +  ALB
   + security groups
