data "aws_iam_policy_document" "image-assume-policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["ecs.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_image" {
  name               = "ldi-${var.env}-app"
  assume_role_policy = "${data.aws_iam_policy_document.image-assume-policy.json}"
}

resource "aws_iam_role_policy_attachment" "vpc_policy_for_image" {
  role       = aws_iam_role.iam_for_image.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "allow_egress" {
  name        = "allow_egress_ldi-${var.env}-app-${substr(uuid(), 0, 3)}"
  description = "Allows all Egress"
  vpc_id      = "${var.vpcid}"

  lifecycle {
      create_before_destroy = true
      ignore_changes        = [name]
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      description = "Security Group for deployment"
      self = false
    }
  ]
}


data "aws_iam_policy_document" "ecr" {
    statement {
        actions = [
            "ecr:*",
        ]
        resources = [
            "*", 
        ]
    }
}

resource "aws_iam_policy" "ecr" {
  name   = "ecr_ldi-${var.env}-app"
  policy = "${data.aws_iam_policy_document.ecr.json}"
}

resource "aws_iam_role_policy_attachment" "ecr" {
    role       = aws_iam_role.iam_for_image.name
    policy_arn = aws_iam_policy.ecr.arn
}

data "aws_iam_policy_document" "ecs" {
    statement {
        actions = [
            "ecs:*",
        ]
        resources = [
            "*", 
        ]
    }
}

resource "aws_iam_policy" "ecs" {
  name   = "ecs_ldi-${var.env}-app"
  policy = "${data.aws_iam_policy_document.ecs.json}"
}

resource "aws_iam_role_policy_attachment" "ecs" {
    role       = aws_iam_role.iam_for_image.name
    policy_arn = aws_iam_policy.ecs.arn
}

data "aws_iam_policy_document" "s3-access" {
    statement {
        actions = [
            "s3:*",
        ]
        resources = [
            "*", 
        ]
    }
}

resource "aws_iam_policy" "s3-access" {
    name = "s3-access_ldi-${var.env}-app"
    path = "/"
    policy = data.aws_iam_policy_document.s3-access.json
}

resource "aws_iam_role_policy_attachment" "s3-access" {
    role       = aws_iam_role.iam_for_image.name
    policy_arn = aws_iam_policy.s3-access.arn
}