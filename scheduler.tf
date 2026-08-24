resource "aws_scheduler_schedule_group" "daily" {
  name = "${var.project_slug}-daily"
}

resource "aws_scheduler_schedule" "daily" {
  name        = "${var.project_slug}-daily-run"
  group_name  = aws_scheduler_schedule_group.daily.name
  description = "Startet den Nordic News Radar einmal täglich."

  state                        = var.scheduler_enabled ? "ENABLED" : "DISABLED"
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.processor.arn
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      trigger = "eventbridge-scheduler"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 2
    }
  }

  depends_on = [aws_iam_role_policy.scheduler_invoke_lambda]
}
