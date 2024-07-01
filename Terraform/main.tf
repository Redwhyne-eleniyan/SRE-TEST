terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.56.1"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  # Configuration options
}

# Create an SNS topic
resource "aws_sns_topic" "ec2restart" {
  name = "ec2restart-topic"
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the IAM role for the Lambda function
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda execution"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = "sns:Publish",
        Effect = "Allow",
        Resource = aws_sns_topic.ec2restart.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create a Lambda function
resource "aws_lambda_function" "lambda_trigger" {
  filename         = "lambda_function.zip"
  function_name    = "lambda_trigger_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.ec2restart.arn
    }
  }
}

# Create an EC2 instance
resource "aws_instance" "lambdaec2" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"

  tags = {
    Name = "lambdaec2"
  }
}

# IAM role for EC2 instance with minimal privileges
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ridwan" {
  name = "example-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

# Attach a minimal policy to the EC2 instance role
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Policy for EC2 instance"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "logs:CreateLogStream",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_instance" "ec2" {
  ami           = "ami-04b70fa74e45c3917" 
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ridwan.name

  tags = {
    Name = "ridwan-instance"
  }
}
