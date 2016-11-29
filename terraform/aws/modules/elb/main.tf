variable "elb_name" { default = "ticker-api-service" }
variable "health_check_target" { default = "HTTP:3000/" }
variable "instances" {}
variable "subnets" {}
variable "security_groups" {}

resource "aws_elb" "ticker-api-service" {
  name                      = "${var.elb_name}"
  subnets                   = ["${split(",", var.subnets)}"]
  security_groups           = ["${var.security_groups}"]
  instances                 = ["${split(",", var.instances)}"]
  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "${var.health_check_target}"
    interval            = 30
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  tags {
    Name = "${var.elb_name}"
  }
}
