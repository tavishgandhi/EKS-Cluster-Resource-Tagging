
# IAM Policy to allow node group tagging and put ssm parameters
  resource "aws_iam_policy" "NodeGroupResources-Tag-Policy" {
  name        =    "NodeGroupResources-Tag-Policy"
  path        =    "/"
  description =    "Policy to allow tagging of node group resources. "

policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":"logs:CreateLogGroup",
         "Resource":"arn:aws:logs:*:*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":[
            "arn:aws:logs:*:*:log-group:/aws/lambda/Node-group-resources-tagging:*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":"autoscaling:CreateOrUpdateTags",
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "ssm:GetParameters",
            "ssm:GetParameter"
         ],
         "Resource":"arn:aws:ssm:*:*:parameter/NodeGroupNames/*"
      },
      {
         "Action":[
            "ec2:CreateTags",
            "ec2:Describe*"
         ],
         "Resource":[
            "*"
         ],
         "Effect":"Allow"
      }
   ]
}
EOF
}

# IAM role for lambda.
resource "aws_iam_role" "NodeGroupResources-Tag-Role"{
  name = "NodeGroupResources-Tag-Role"

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
resource "aws_iam_role_policy_attachment" "NodeGroupResources-Tag-Policy-Attach" {
  role = aws_iam_role.NodeGroupResources-Tag-Role.name
  policy_arn = aws_iam_policy.NodeGroupResources-Tag-Policy.arn
}
