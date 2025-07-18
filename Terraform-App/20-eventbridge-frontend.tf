resource "aws_cloudwatch_event_rule" "ecr_push_frontend" {
  name        = "ecr-image-push-frontend"
  description = "Trigger Lambda on ECR push to frontend repo"
  event_pattern = jsonencode({
    "source": ["aws.ecr"],
    "detail-type": ["ECR Image Action"],
    "detail": {
      "action-type": ["PUSH"],
      "repository-name": ["multi-frontend"]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_lambda_frontend" {
  rule      = aws_cloudwatch_event_rule.ecr_push_frontend.name
  target_id = "lambda"
  arn       = aws_lambda_function.deploy_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_frontend" {
  statement_id  = "AllowExecutionFromEventBridgeFrontend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deploy_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push_frontend.arn
}



