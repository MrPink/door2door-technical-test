# master
resource "aws_iam_role" "ticks_role" {
  name               = "ticks_role"
  path               = "/"
  assume_role_policy = "${file("${path.module}/ticks-role.json")}"
}

resource "aws_iam_role_policy" "ticks_policy" {
  name   = "ticks_policy"
  role   = "${aws_iam_role.ticks_role.id}"
  policy = "${file("${path.module}/ticks-policy.json")}"
}

resource "aws_iam_instance_profile" "ticks_profile" {
  name  = "ticks_profile"
  roles = ["${aws_iam_role.ticks_role.name}"]
}
