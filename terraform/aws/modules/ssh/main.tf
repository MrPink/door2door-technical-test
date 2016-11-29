# input variables
variable "short_name" { default = "ticks" }
variable "public_key_file" {}
variable "private_key_file" {}
variable "region" {}

# output variables
output "keypair_name" {
  value = "${aws_key_pair.default.key_name}"
}

# SSH keypair for the instances
resource "aws_key_pair" "default" {
  key_name   = "${var.short_name}"
	public_key = "${file("${var.public_key_file}")}"
}
