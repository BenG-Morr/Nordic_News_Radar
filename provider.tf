provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Nordic News Radar"
      ManagedBy = "Terraform"
      Course    = "DLBSEPCP01_D"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
