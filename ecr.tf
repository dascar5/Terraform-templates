
resource "aws_ecr_repository" "project-shared-ecr" {
  name                 = "project-shared-ecr-${var.env}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "project-shared-ecr-policy" {
  repository = aws_ecr_repository.project-shared-ecr.name

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPushPull",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
    }
  ]
}
EOF
}

resource "aws_ssm_parameter" "project-shared-ecr-param" {
  name  = "/${var.env}/project/ecr/name"
  type  = "String"
  value = aws_ecr_repository.project-shared-ecr.name
}