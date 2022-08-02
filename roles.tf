resource "aws_iam_role" "lambda_assume_role" {
  name = "labs-lambda-assume-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "labs-lambda-assume-role"
  }
}

data "aws_iam_policy_document" "lambda_rekognition_lab" {
  statement {
    sid = "LambdaForRekognition"

    actions = [
      "rekognition:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_rekognition_lab_policy" {
  name = "lambda-rekognition-lab"
  description = "Allow lambda function to use rekognition"
  policy = data.aws_iam_policy_document.lambda_rekognition_lab.json
}

#giving lambda s3 access
data "aws_iam_policy_document" "lambda_rekognition_s3_access" {
  statement {
    sid = "LambdaAccessS3Bucket"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.image_storage_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.image_storage_bucket.bucket}/*"
    ]
  }
}

#adding new policy so lambda can access s3
resource "aws_iam_policy" "lambda_rekognition_lab_s3_access_policy" {
  name = "lambda-rekognition-lab-s3-access"
  description = "Allow lambda function to access s3 bucket and objects"
  policy = data.aws_iam_policy_document.lambda_rekognition_s3_access.json
}


#adding lambda role to already created assume role
resource "aws_iam_role_policy_attachment" "lambda" {
  role = aws_iam_role.lambda_assume_role.name
  policy_arn = aws_iam_policy.lambda_rekognition_lab_policy.arn
}

#adding lambda s3 access role
resource "aws_iam_role_policy_attachment" "lambda_access_s3" {
  role = aws_iam_role.lambda_assume_role.name
  policy_arn = aws_iam_policy.lambda_rekognition_lab_s3_access_policy.arn
}

#giving permission to s3 bucket to access lambda function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lab_lambda_image_rekognition.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.image_storage_bucket.arn
}

#giving lambda access to dynamodb
data "aws_iam_policy_document" "lambda_rekognition_dynamodb_access" {
  statement {
    sid = "LambdaAccessDynamodb"

    actions = [
      #to store details inside dynamoDb
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.lambda_image_rekognition.arn
    ]
  }
}

#adding new policy so lambda can dynamodb
resource "aws_iam_policy" "lambda_rekognition_lab_dynamodb_access_policy" {
  name = "lambda-rekognition-lab-dynamodb-access"
  description = "Allow lambda function to write item into dynamoDB"
  policy = data.aws_iam_policy_document.lambda_rekognition_dynamodb_access.json
}

#to attach dynamoDB policy to the role
resource "aws_iam_role_policy_attachment" "lambda_write_dynamodb" {
  role = aws_iam_role.lambda_assume_role.name
  policy_arn = aws_iam_policy.lambda_rekognition_lab_dynamodb_access_policy.arn
}