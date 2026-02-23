data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "artifacts_bucket" {
  bucket        = "${var.project_name}-artifacts-${var.environment}538"
  force_destroy = true

  tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
    "Type"        = "ArtifactStorage"
  }
}