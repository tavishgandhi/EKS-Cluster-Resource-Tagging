# Lambda for EKS Cluster Tagging
data "archive_file" "EKS-Cluster-Tag"{
  type = "zip"
  source_file = "Code_files/EKS_Cluster_tag.py"
  output_path = "Code_files/EKS_Cluster_tag.zip"
}

# Lambda for EKS Cluster tagging
resource "aws_lambda_function" "EKS-Tag-Lambda" {
  filename = data.archive_file.EKS-Cluster-Tag.output_path
  function_name = "EKS-Tag-Lambda"
  role = aws_iam_role.EKS-Cluster-Tag-Lambda-Role.arn
  handler = "EKS_Cluster_tag.lambda_handler"
  timeout = "59"
  source_code_hash = filebase64sha256(data.archive_file.EKS-Cluster-Tag.output_path)

  runtime = "python3.8"
}

#-----------------------------------------------------------------------------------------------
# Lambda for node group tagging and inserting/deleting node group name and owner in ssm store.
data "archive_file" "NodeGroup"{
  type = "zip"
  source_file = "Code_files/Node-group-creation-deletion-ssm-parameter.py"
  output_path = "Code_files/Node-group-creation-deletion-ssm-parameter.zip"
}

resource "aws_lambda_function" "Node-group-creation-deletion-ssm-parameter" {
  filename = data.archive_file.NodeGroup.output_path
  function_name = "Node-group-creation-deletion-ssm-parameter"
  role = aws_iam_role.NodeGroup-Tag-SSM-Parameter-Role.arn
  handler = "Node-group-creation-deletion-ssm-parameter.lambda_handler"
  timeout = "59"
  source_code_hash = filebase64sha256(data.archive_file.NodeGroup.output_path)

  runtime = "python3.8"
}
#---------------------------------------------------------------------------------------------------
# Lambda for node group resources tagging.
data "archive_file" "NodeGroupResources"{
  type = "zip"
  source_file = "Code_files/Node-group-resources-tagging.py"
  output_path = "Code_files/Node-group-resources-tagging.zip"
}

resource "aws_lambda_function" "Node-group-resources-tagging" {
  filename = data.archive_file.NodeGroupResources.output_path
  function_name = "Node-group-resources-tagging"
  role = aws_iam_role.NodeGroupResources-Tag-Role.arn
  handler = "Node-group-resources-tagging.lambda_handler"
  timeout = "59"
  source_code_hash = filebase64sha256(data.archive_file.NodeGroupResources.output_path)

  runtime = "python3.8"
}
