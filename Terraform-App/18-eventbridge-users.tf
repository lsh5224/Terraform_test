resource "aws_cloudwatch_event_rule" "ecr_push_users" {
  name        = "ecr-image-push-users"
  description = "Trigger Lambda on ECR push to users repo"
  event_pattern = jsonencode({
    "source": ["aws.ecr"],
    "detail-type": ["ECR Image Action"],
    "detail": {
      "action-type": ["PUSH"],
      "repository-name": ["multi-backend-users"]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_lambda_users" {
  rule      = aws_cloudwatch_event_rule.ecr_push_users.name
  target_id = "lambda"
  arn       = aws_lambda_function.deploy_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_users" {
  statement_id  = "AllowExecutionFromEventBridgeUsers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deploy_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push_users.arn
}