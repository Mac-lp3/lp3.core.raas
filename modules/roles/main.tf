locals {
    fix = "${var.ENV == "dev" ? "-${var.ENV}" : "" }"
    project_name = yamldecode(file("${var.file_path}"))["projectName"]
    roles = { for role in yamldecode(file("../projects/bermuda/roles.yml"))["roles"] : role.name => { "statement": merge( { "perms":role.perms }, { "principal": role.principal} ) } }
}

resource "aws_iam_role" "project_role" {
    for_each = local.roles

    name = "${each.key}${local.fix}"
    assume_role_policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = [{
            "Action" = "sts:AssumeRole"
            "Effect" = "Allow"
            "Principal" = each.value.statement.principal
        }]
    })
}

resource "aws_iam_role_policy" "project_policy" {
    for_each = local.roles

    name = "${each.key}-policy${local.fix}"
    role = aws_iam_role.project_role[each.key].id
    policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = each.value.statement.perms
    })
}
