# Bastion server
module "bastion_amitype" {
  source        = "github.com/terraform-community-modules/tf_aws_virttype"
  instance_type = "t1.micro"
}

module "bastion_ami" {
  source   = "github.com/terraform-community-modules/tf_aws_coreos_ami"
  region   = "${var.region}"
  channel  = "${var.coreos_channel}"
  virttype = "${module.bastion_amitype.prefer_hvm}"
}

 resource "aws_instance" "bastion" {
  instance_type     = "t1.micro"
  ami               = "${module.bastion_ami.ami_id}"
  subnet_id         = "${element(split(",", module.vpc.public_subnets), 0)}"
  vpc_security_group_ids = ["${module.sg-default.security_group_id}", "${aws_security_group.bastion.id}"]
  key_name          = "${module.aws-ssh.keypair_name}"
  source_dest_check = false

  connection {
    user        = "core"
    private_key = "${file("${var.private_key_file}")}"
  }
}

# Bastion elastic IP
resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}
