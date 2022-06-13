
resource "aws_ecr_repository" "lii-ldi-shared-ecr" {
  name                 = "lii-ldi-shared-ecr-${var.env}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "lii-ldi-shared-ecr-policy" {
  repository = aws_ecr_repository.lii-ldi-shared-ecr.name

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

resource "aws_ssm_parameter" "lii-ldi-shared-ecr-param" {
  name  = "/${var.env}/lii-ldi/ecr/name"
  type  = "String"
  value = aws_ecr_repository.lii-ldi-shared-ecr.name
}