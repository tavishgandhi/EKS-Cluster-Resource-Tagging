
# IAM Policy to allow node group tagging and put ssm parameters
resource "aws_iam_policy" "NodeGroup-Tag-SSM-Parameter-Policy" {
  name        =    "NodeGroup-Tag-SSM-Parameter-Policy"
  path        =    "/"
  description =    "Policy to allow tagging of eks node group and put/delete values in ssm parameter store. "

policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"VisualEditor0",
         "Effect":"Allow",
         "Action":[
            "ssm:PutParameter",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:DescribeParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameter",
            "ssm:DeleteParameters"
         ],
         "Resource":"arn:aws:ssm:*:*:parameter/NodeGroupNames/*"
      },
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
            "arn:aws:logs:*:*:log-group:/aws/lambda/Node-group-creation-deletion-ssm-parameter:*"
         ]
      }
   ]
}
EOF
}

# IAM role for lambda.
resource "aws_iam_role" "NodeGroup-Tag-SSM-Parameter-Role"{
  name = "NodeGroup-Tag-SSM-Parameter-Role"

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
resource "aws_iam_role_policy_attachment" "NodeGroup-Tag-SSM-Parameter-Policy-Attach" {
  role = aws_iam_role.NodeGroup-Tag-SSM-Parameter-Role.name
  policy_arn = aws_iam_policy.NodeGroup-Tag-SSM-Parameter-Policy.arn
}
