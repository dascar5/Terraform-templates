resource "aws_elasticsearch_domain" "es" {
  domain_name           = "project-${var.env}-ess"
  elasticsearch_version = "OpenSearch_1.1"
 
  cluster_config {
    instance_type = "r4.large.elasticsearch"
    instance_count = "2"
  }
  snapshot_options {
    automated_snapshot_start_hour = 00
  }
  vpc_options {
    # ValidationException: You must specify exactly one subnet.
    subnet_ids = [var.subnet1]
    security_group_ids = [aws_security_group.OSS_SG.id]
  }
  ebs_options {
    ebs_enabled = "true"
    volume_size = "40"
    volume_type = "gp2"
  }
  encrypt_at_rest {
    enabled = "true"
  }
  node_to_node_encryption {
    enabled = "true"
  }

  domain_endpoint_options {
    enforce_https = "true"
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
}
 
 
resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.es.domain_name
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${aws_elasticsearch_domain.es.arn}/*"
        }
    ]
}
POLICIES
}

resource "aws_iam_service_linked_role" "es" {
    aws_service_name = "es.amazonaws.com"
    description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

resource "aws_iam_role" "iam_for_oss" {
  name               = "project-${var.env}-oss-role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com",
                "AWS": [
                    "*"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "policy" {
  name = "projectOSSrolePolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "es:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

  role = aws_iam_role.iam_for_oss.name
}

resource "aws_ssm_parameter" "role_arn" {
  name  = "/project/role/${var.env}/oss"
  type  = "String"
  value = "${aws_iam_role.iam_for_oss.arn}"
}
