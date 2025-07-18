data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "deploy_lambda" {
  function_name = "terraform-deploy"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      TERRAFORM_GIT = "https://github.com/onetouch-ke/terraform.git"
    }
  }
}