
# CloudWatch Event to notify eks create cluster event
resource "aws_cloudwatch_event_rule" "EKS-CreateCluster-Event" {
  name        = "EKS-CreateCluster-Event"
  description = "Monitor EKS create cluster call and trigger lambda to tag the cluster"

event_pattern = <<EOF
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": ["eks.amazonaws.com"],
    "eventName": ["CreateCluster" , "DeleteCluster"]
  }
}
EOF
}
# Cloudwatch Event target lambda to tag eks cluster.
resource "aws_cloudwatch_event_target" "EKS-EventTarget" {
  rule      = aws_cloudwatch_event_rule.EKS-CreateCluster-Event.name
  target_id = "SendToEKSLambda"
  arn       = aws_lambda_function.EKS-Tag-Lambda.arn
}

# Allow Cloudwatch to invoke Lambda to tag eks cluster
resource "aws_lambda_permission" "Allow-Cloudwatch-EKS-Cluster-Tag" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.EKS-Tag-Lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EKS-CreateCluster-Event.arn
}

#-------------------------------------------------------------------------------
# CloudWatch Event to notify eks node group creation/deletion

resource "aws_cloudwatch_event_rule" "EKS-NodeGroup-Event" {
  name        = "EKS-NodeGroup-Event"
  description = "Monitor EKS node group creation/deletion api call and trigger lambda."

event_pattern = <<EOF
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": ["eks.amazonaws.com"],
    "eventName": [
      "CreateNodegroup",
      "DeleteNodegroup"
    ]
  }
}
EOF
}
# Cloudwatch Event target lambda to tag node group and to store parameters ssm.
resource "aws_cloudwatch_event_target" "EKS-NodeGroup-EventTarget" {
  rule      = aws_cloudwatch_event_rule.EKS-NodeGroup-Event.name
  target_id = "SendToNodeGroupLambda"
  arn       = aws_lambda_function.Node-group-creation-deletion-ssm-parameter.arn
}

# Allow Cloudwatch to invoke Lambda to tag node group and put ssm parameter
resource "aws_lambda_permission" "Allow-Cloudwatch-NodeGroup-SSM-Parameter" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Node-group-creation-deletion-ssm-parameter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EKS-NodeGroup-Event.arn
}

#----------------------------------------------------------------------------------------------------
# CloudWatch Event to notify running instances of eks node group.

resource "aws_cloudwatch_event_rule" "EKS-NodeGroupResources-Event" {
  name        = "EKS-NodeGroupResources-Event"
  description = "Monitor instance running in association with node group."

event_pattern = <<EOF
{
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ec2.amazonaws.com"],
    "eventName": ["RunInstances"],
    "userAgent": ["autoscaling.amazonaws.com"]
  }
}
EOF
}
# Cloudwatch Event target lambda to tag node group resources.
resource "aws_cloudwatch_event_target" "EKS-NodeGroupResources-EventTarget" {
  rule      = aws_cloudwatch_event_rule.EKS-NodeGroupResources-Event.name
  target_id = "SendToNodeGroupResourcesLambda"
  arn       = aws_lambda_function.Node-group-resources-tagging.arn
}

# Allow Cloudwatch to invoke Lambda to tag node group resources.
resource "aws_lambda_permission" "Allow-Cloudwatch-NodeGroupResources" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Node-group-resources-tagging.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EKS-NodeGroupResources-Event.arn
}
