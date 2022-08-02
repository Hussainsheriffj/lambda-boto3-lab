# Archive a single file.
data "archive_file" "python_script_file" {
  type        = "zip"
  source_file = "${path.module}/python-scripts/${var.lambda_function_name}.py"
  output_path = "${path.module}/lambda-function.zip"
}

resource "aws_lambda_function" "lab_lambda_image_rekognition" {

  filename      = data.archive_file.python_script_file.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_assume_role.arn
  handler       = "${var.lambda_function_name}.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(data.archive_file.python_script_file.output_path)

  runtime = "python3.8"

  # we can create variable directly from here
  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}