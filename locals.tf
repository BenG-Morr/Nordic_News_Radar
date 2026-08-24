locals {
  name_prefix = "${var.project_slug}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  frontend_bucket_name = "${local.name_prefix}-frontend"
  data_bucket_name     = "${local.name_prefix}-data"

  frontend_origin_id = "s3-frontend"
  data_origin_id     = "s3-data"

  data_prefix    = "data/"
  archive_prefix = "data/archive/"
}
