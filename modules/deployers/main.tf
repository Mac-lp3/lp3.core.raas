locals {
    fix = "${var.ENV == "dev" ? "-${var.ENV}" : "" }"
    project_name = yamldecode(file("${var.file_path}"))["projectName"]
    permissions  = yamldecode(file("${var.file_path}"))["deployer"]["perms"]
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "deployer_user" {
    name = "${local.project_name}-deploy-user${local.fix}"
    path = "/${var.iam_path}/"
}

resource "aws_iam_role" "deploy_role" {
    name = "${local.project_name}-deploy-role${local.fix}"

    assume_role_policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = [{
            "Action" = "sts:AssumeRole"
            "Effect" = "Allow"
            "Principal" = {
                "AWS": [
                    "${aws_iam_user.deployer_user.arn}"
                ]
            }
        }]
    })
}

resource "aws_iam_role_policy" "deploy_policy" {
    name = "${local.project_name}-deploy-role-policy${local.fix}"
    role = aws_iam_role.deploy_role.id

    policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = local.permissions
    })
}
