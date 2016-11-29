variable "cluster_name" {}

resource "aws_ecr_repository" "ecr" {
  name = "${var.cluster_name}"
}

resource "aws_ecr_repository_policy" "ticks" {
  repository = "${aws_ecr_repository.ecr.name}"
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

# output variables
output "ecr_url" {
  value = "${aws_ecr_repository.ecr.repository}"
}

resource "template_file" "makefile" {
  template   = "makefile.tpl"
  vars {
    ecr_url  = "${module.ecr.ecr_url}"
  }
}

resource "null_resource" "ssh_cfg" {
  triggers {
    template_rendered = "${ data.template_file.makefile.rendered }"
  }
  provisioner "local-exec" {
    command = "echo '${ data.template_file.ssh_cfg.rendered }' > ../../../makefile"
  }
}
