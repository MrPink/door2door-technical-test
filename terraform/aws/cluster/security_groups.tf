resource "aws_security_group" "bastion" {
  name        = "ticker-bastion"
  description = "Security group for bastion instances that allows SSH and VPN traffic from internet"
  vpc_id      = "${module.vpc.vpc_id}"

  # inbound http/https traffic from the private subnets to allow them to talk with the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["93.214.249.120/32","217.9.109.218/32"]
  }

  # outbound access to the inernet
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ticker-bastion-sg"
  }
}
