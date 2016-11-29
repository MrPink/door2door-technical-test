variable "cluster_name" { default = "ticks" }
variable "public_key_file" { default = "../../ssh/ticks.pub" }
variable "private_key_file" { default = "../../ssh/ticks" }
variable "region" { default = "eu-central-1" }
variable "availability_zones" { default = "eu-central-1a,eu-central-1b" }
variable "vpc_cidr_block" { default = "10.0.0.0/16" }
variable "coreos_channel" { default = "stable" }
variable "etcd_discovery_url_file" { default = "etcd_discovery_url.txt" }
variable "docker_version" { default = "1.9.1-0~trusty" }
variable "default_instance_user" { default = "core" }
variable "environment" { default = "production" }
variable "app_instance_type" { default = "m3.medium" }
variable "postgress_password" { default = "CHANGEME" }
variable "postgress_user" { default = "ticks" }

provider "aws" {
  region = "${var.region}"
}

module "iam" { source = "../modules/iam"}

module "vpc" {
  source              = "../modules/vpc"
  name                = "ticks"
  cidr                = "${var.vpc_cidr_block}"
  private_subnets     = "10.0.1.0/24,10.0.2.0/24"
  public_subnets      = "10.0.101.0/24,10.0.102.0/24"
  azs                 = "${var.availability_zones}"
  bastion_instance_id = "${aws_instance.bastion.id}"
}

# ssh keypair for instances
module "aws-ssh" {
  source = "../modules/ssh"
  public_key_file = "${var.public_key_file}"
  private_key_file = "${var.private_key_file}"
  region = "${var.region}"
}

# security group to allow all traffic in and out of the instances in the VPC
module "sg-default" {
  source = "../modules/sg-all-traffic"

  vpc_id = "${module.vpc.vpc_id}"
}

module "elasticache" {
  source = "../modules/elasticache"
  cluster_name = "${var.cluster_name}"
}

module "rds" {
  private_subnets = "${module.vpc.private_subnets}"
  default_security_group = "${module.sg-default.security_group_id}"
  postgres_password = "${var.postgress_password}"
  postgres_user = "${var.postgress_user}"
  source = "../modules/rds"
}

module "elb" {
 source = "../modules/elb"
 security_groups = "${module.sg-default.security_group_id}"
 instances       = "${join(",", aws_instance.app.*.id)}"
 subnets         = "${module.vpc.public_subnets}"
}

# outputs
output "app_ips" {
  value = "${join(",", aws_instance.app.*.private_ip)}"
}

output "vpc_cidr_block_ip" {
 value = "${module.vpc.vpc_cidr_block}"
}
