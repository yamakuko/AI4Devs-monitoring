# Política para acceso a S3
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.code_bucket.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

# Rol IAM para instancias EC2
resource "aws_iam_role" "ec2_role" {
  name               = "lti-project-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Asociación de política S3 al rol EC2
resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Política específica para Datadog Agent
resource "aws_iam_policy" "datadog_agent_policy" {
  name        = "datadog-agent-policy"
  description = "Permite que las instancias EC2 envíen métricas a Datadog"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = [
          "arn:aws:cloudwatch:us-east-1:${data.aws_caller_identity.current.account_id}:metric/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags"
        ]
        Resource = [
          "arn:aws:ec2:us-east-1:${data.aws_caller_identity.current.account_id}:instance/*"
        ]
      }
    ]
  })
}

# Asociación de política Datadog al rol EC2
resource "aws_iam_role_policy_attachment" "attach_datadog_agent_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.datadog_agent_policy.arn
}

# Perfil de instancia EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "lti-project-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
