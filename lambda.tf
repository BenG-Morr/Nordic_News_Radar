resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_slug}-processor"
  retention_in_days = 14
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda_src.zip"
}

resource "aws_lambda_function" "processor" {
  function_name = "${var.project_slug}-processor"
  description   = "Ruft News-Feeds ab, verarbeitet sie mit Nova Micro und schreibt JSON nach S3."

  role    = aws_iam_role.lambda.arn
  handler = "handler.lambda_handler"
  runtime = "python3.13"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  memory_size = 512
  timeout     = 300

  environment {
    variables = {
      DATA_BUCKET                  = aws_s3_bucket.data.bucket
      DATA_PREFIX                  = local.data_prefix
      ARCHIVE_PREFIX               = local.archive_prefix
      ARCHIVE_RETENTION_DAYS       = tostring(var.archive_retention_days)
      BEDROCK_INFERENCE_PROFILE_ID = var.bedrock_inference_profile_id
      BEDROCK_REGION               = var.aws_region
      NEWS_FEEDS_JSON              = jsonencode(local.news_feeds)
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.lambda_runtime
  ]
}
