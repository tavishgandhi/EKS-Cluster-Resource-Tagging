terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"
    }
  }
}

provider "aws" {
  profile = "Tavish"
  region = var.using_region 
}

# IAM Policy to allow tagging eks clusters and insert logs to cloudWatch.
resource "aws_iam_policy" "EKS-Cluster-Tag-Policy" {
  name        =    "EKS-Cluster-Tag-Policy"
  path        =    "/"
  description =    "Policy to allow tagging of eks-cluster and put cloudwatch logs"

policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "eks:UntagResource",
                "eks:TagResource"
            ],
            "Resource": "arn:aws:eks:*:*:cluster/*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:/aws/lambda/EKS-Tag-Lambda:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "ssm:PutParameter",
              "ssm:DeleteParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/NodeGroupNames/*"
        }
    ]
}
EOF
}

# IAM role for lambda.
resource "aws_iam_role" "EKS-Cluster-Tag-Lambda-Role"{
  name = "EKS-Cluster-Tag-Lambda-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach role and Policy
resource "aws_iam_role_policy_attachment" "EKS-Cluster-Tag-Role-Policy-Attach" {
  role = aws_iam_role.EKS-Cluster-Tag-Lambda-Role.name
  policy_arn = aws_iam_policy.EKS-Cluster-Tag-Policy.arn
}
