module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "project-${var.env}-rds-integration-cluster"

  engine            = "postgres"
  engine_version    = "14.1"
  instance_class    = "db.r6g.large"
  major_engine_version = "14"
  family = "postgres14"

  allocated_storage = 20
  storage_type = "gp2"

  db_name = "integration"
  username = "dbadmin"
  password = random_password.password.result
  port     = "5432"

  iam_database_authentication_enabled = true

  multi_az = false
  # If multi-az set to true, throws
  # Error: Error creating DB Instance: InvalidVPCNetworkStateFault: Cannot create a db.r6g.large 
  # Multi-AZ instance because at least 2 subnets must exist in availability zones with sufficient capacity for VPC and storage type : gp2 for db.r6g.large, 
  # so 1 more must be created in other availability zones; choose from these availability zones: us-east-1c, us-east-1b, us-east-1d, us-east-1f.
  
  create_db_subnet_group = true
  subnet_ids             = [var.subnet1, var.subnet2]
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window = "03:00-06:00"

  monitoring_interval = "30"
  monitoring_role_name = "project-${var.env}-rds-integration-cluster-monitoring"
  create_monitoring_role = true

  deletion_protection = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "credentials" {
  name = "/gdm/${var.env}/rds/integration/dbadmin"
  description = "GDM RDS password"
}

resource "aws_secretsmanager_secret_version" "credentials_val" {
  secret_id     = "${aws_secretsmanager_secret.credentials.id}"
  secret_string = random_password.password.result
}

resource "aws_secretsmanager_secret_policy" "secret_policy" {
  secret_arn = aws_secretsmanager_secret.credentials.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableToReadTheSecret",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
POLICY
}

