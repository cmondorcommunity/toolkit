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
