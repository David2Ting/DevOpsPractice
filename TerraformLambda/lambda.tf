locals {
    lambda_zip_path = "outputs/logS3Changes.zip"
}

data "archive_file" "init" {
  type        = "zip"
  source_file = "logS3Changes.py"
  output_path = "${local.lambda_zip_path}"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${local.lambda_zip_path}"
  function_name = "logS3Changes"
  role          = aws_iam_role.lambda_role.arn
  handler       = "logS3Changes.logS3Changes"

  source_code_hash = filebase64sha256(local.lambda_zip_path)

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tryosaurus-bucket-for-lambda"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "AWSLogs/"
    filter_suffix = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}