variable "elb_name" { default = "kube-master" }
variable "health_check_target" { default = "HTTP:8080/healthz" }
variable "instances" {}
variable "subnets" {}
variable "security_groups" {}

resource "aws_elb" "kube_master" {
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

  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }

  tags {
    Name = "${var.elb_name}"
  }
}

resource "aws_route53_record" "bouncer-k8-api" {
  zone_id = "ZPAOPEKYYGK3"
  type = "A"
  name = "bouncer-k8-api.tape.tv"

  alias {
    name = "${aws_elb.kube_master.dns_name}"
    zone_id = "${aws_elb.kube_master.zone_id}"
    evaluate_target_health = true
  }
}

# outputs
output "elb_id" { value = "${aws_elb.kube_master.id}" }
output "elb_name" { value = "${aws_elb.kube_master.name}" }
output "elb_dns_name" { value = "${aws_elb.kube_master.dns_name}" }
