module "app_amitype" {
  source        = "github.com/terraform-community-modules/tf_aws_virttype"
  instance_type = "${var.app_instance_type}"
}

module "app_ami" {
  source   = "github.com/terraform-community-modules/tf_aws_coreos_ami"
  region   = "${var.region}"
  channel  = "${var.coreos_channel}"
  virttype = "${module.app_amitype.prefer_hvm}"
}

resource "template_file" "app_cloud_init" {
  template   = "app-cloud-config.yml.tpl"
  vars {
    cluster_name = "${var.cluster_name}"
    region       = "${var.region}"
    rds_hostname = "${module.rds.rds_hostname}"
  }
}

resource "aws_instance" "app" {
  instance_type     = "${var.app_instance_type}"
  ami               = "${module.app_ami.ami_id}"
  count             = "2"
  key_name          = "${module.aws-ssh.keypair_name}"
  source_dest_check = false
  iam_instance_profile = "app_profile"
  subnet_id         = "${element(split(",", module.vpc.private_subnets), count.index)}"
  vpc_security_group_ids = ["${module.sg-default.security_group_id}"]
  user_data         = "${template_file.app_cloud_init.rendered}"
  tags = {
    Name = "tags-app"
  }
}
