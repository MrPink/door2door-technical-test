variable "postgres_password" {}
variable "postgres_user" {}
variable "private_subnets" {}
variable "default_security_group" {}

# DB subnet
resource "aws_db_subnet_group" "ticker" {
    name = "db-ticker"
    description = "Internal subnets"
    subnet_ids  = ["${split(",", "${var.private_subnets}")}"]
    tags {
        Name = "ticker DB subnet group"
    }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 1
  engine               = "postgres"
  engine_version       = "9.4.7"
  instance_class       = "db.t2.medium"
  username             = "${var.postgres_user}"
  password             = "${var.postgres_password}"
  db_subnet_group_name = "db-ticker"
  parameter_group_name = "default.postgres9.4"
  vpc_security_group_ids = ["${var.default_security_group}"]
  multi_az             = "false"
  backup_retention_period = 14
  copy_tags_to_snapshot = true
}

# output variables
output "rds_hostname" {
  value = "${aws_db_instance.db.address}"
}
