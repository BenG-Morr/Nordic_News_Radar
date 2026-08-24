# ---------- Lambda-Ausführungsrolle ----------
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.project_slug}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_runtime" {
  statement {
    sid     = "WriteGeneratedReports"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.data.arn}/${local.data_prefix}latest.json",
      "${aws_s3_bucket.data.arn}/${local.archive_prefix}*"
    ]
  }

  # Zugriff auf das systemdefinierte geografische Inferenzprofil in der Quellregion.
  statement {
    sid       = "InvokeNovaMicroEUInferenceProfile"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [data.aws_bedrock_inference_profile.nova_micro_eu.inference_profile_arn]
  }

  # AWS verlangt zusätzlich Zugriff auf das Foundation Model in allen Zielregionen des Profils.
  # Die Modell-ARNs werden dynamisch aus dem Inferenzprofil übernommen, statt Regionen fest zu codieren.
  statement {
    sid       = "InvokeNovaMicroDestinationModels"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [for model in data.aws_bedrock_inference_profile.nova_micro_eu.models : model.model_arn]

    condition {
      test     = "StringEquals"
      variable = "bedrock:InferenceProfileArn"
      values   = [data.aws_bedrock_inference_profile.nova_micro_eu.inference_profile_arn]
    }
  }

  statement {
    sid       = "WriteLambdaLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }
}

resource "aws_iam_role_policy" "lambda_runtime" {
  name   = "${var.project_slug}-lambda-runtime"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_runtime.json
}

# ---------- EventBridge-Scheduler-Ausführungsrolle ----------
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    # AWS empfiehlt zusätzlich die konkrete Schedule Group als SourceArn,
    # um das Confused-Deputy-Risiko zu begrenzen.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_scheduler_schedule_group.daily.arn]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${var.project_slug}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

data "aws_iam_policy_document" "scheduler_invoke_lambda" {
  statement {
    sid       = "InvokeOnlyNordicNewsRadarLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.processor.arn]
  }
}

resource "aws_iam_role_policy" "scheduler_invoke_lambda" {
  name   = "${var.project_slug}-scheduler-invoke-lambda"
  role   = aws_iam_role.scheduler.id
  policy = data.aws_iam_policy_document.scheduler_invoke_lambda.json
}
