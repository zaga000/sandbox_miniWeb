resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_role-${var.environment}"

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
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_acess_policy-${var.environment}"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Effect   = "Allow"
      Resource = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_instace_profile" {
  name = "app-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}