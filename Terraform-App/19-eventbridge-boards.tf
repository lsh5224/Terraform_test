resource "aws_cloudwatch_event_rule" "ecr_push_boards" {
  name        = "ecr-image-push-boards"
  description = "Trigger Lambda on ECR push to boards repo"
  event_pattern = jsonencode({
    "source": ["aws.ecr"],
    "detail-type": ["ECR Image Action"],
    "detail": {
      "action-type": ["PUSH"],
      "repository-name": ["multi-backend-boards"]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_lambda_boards" {
  rule      = aws_cloudwatch_event_rule.ecr_push_boards.name
  target_id = "lambda"
  arn       = aws_lambda_function.deploy_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_boards" {
  statement_id  = "AllowExecutionFromEventBridgeBoards"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deploy_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push_boards.arn
}