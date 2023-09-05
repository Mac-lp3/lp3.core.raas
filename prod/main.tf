terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.15"
        }
    }

    backend "s3" {
        bucket  = "core-raas-state"
        key     = "tf-state/terraform.tfstate"
        region  = "ap-southeast-2"
        encrypt = "true"
    }
}

provider "aws" {
    default_tags {
        tags = {
            managedBy = "raas"
        }
    }
}

locals {
    yamls = fileset("${path.module}", "../projects/*/*.{yaml,yml}")
}

module "deployers" {
    for_each = local.yamls

    source    = "../modules/deployers"
    file_path = each.value
    iam_path  = var.iam_path
}

module "roles" {
    for_each = local.yamls
    
    source = "../modules/roles"
    file_path = each.value
    iam_path  = var.iam_path
}
