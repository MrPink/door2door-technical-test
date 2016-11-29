# master
resource "aws_iam_role" "ticker_role" {
  name               = "ticker_role"
  path               = "/"
  assume_role_policy = "${file("${path.module}/ticker-role.json")}"
}

resource "aws_iam_role_policy" "ticker_policy" {
  name   = "ticker_policy"
  role   = "${aws_iam_role.ticker_role.id}"
  policy = "${file("${path.module}/ticker-policy.json")}"
}

resource "aws_iam_instance_profile" "ticker_profile" {
  name  = "ticker_profile"
  roles = ["${aws_iam_role.ticker_role.name}"]
}
