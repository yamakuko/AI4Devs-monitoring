# Rol IAM para la integración con Datadog
resource "aws_iam_role" "datadog_integration" {
  name = "DatadogAWSIntegrationRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root"  # Cuenta de AWS de Datadog
        }
      }
    ]
  })
}

# Política para acceso de solo lectura a CloudWatch
resource "aws_iam_role_policy_attachment" "datadog_cloudwatch" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# Política para acceso a EC2
resource "aws_iam_role_policy_attachment" "datadog_ec2" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Política para acceso a S3
resource "aws_iam_role_policy_attachment" "datadog_s3" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
} 