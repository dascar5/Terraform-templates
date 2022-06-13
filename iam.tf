locals{
  mlp = length(regexall("dev|qa", var.env)) > 0 ? var.mlp_dev : var.mlp_prod
}

resource "aws_iam_user" "iam" {
  name = "mlpv2-dash-to-athena-user-${var.env}"
}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.iam.name
}

resource "aws_iam_policy" "iam_policy" {
  name = "mlpv2-dash-to-athena-policy-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListAllMyBuckets",
                "athena:ListWorkGroups",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "BusinessPolicyList"
        },
        {
            "Action": [
                "athena:GetNamedQuery",
                "athena:StartQueryExecution",
                "athena:GetQueryResultsStream",
                "athena:GetQueryResults",
                "athena:ListQueryExecutions",
                "athena:ListNamedQueries",
                "athena:GetWorkGroup",
                "athena:CreateNamedQuery",
                "athena:StopQueryExecution",
                "athena:GetQueryExecution",
                "athena:BatchGetNamedQuery",
                "athena:BatchGetQueryExecution",
                "glue:GetTables",
                "glue:GetPartition*",
                "glue:GetTable",
                "glue:GetDatabase*",
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket",
                "s3:ListMultipartUploadParts",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:glue:*:${var.arn_no}:catalog",
                "arn:aws:glue:*:${var.arn_no}:database/reporting",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_brokerage_clients",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_ci_lines",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_ci_tariff_active",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_container",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_date_notes",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_manifest",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_master_house_bills",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_shipments",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_evolve_tracing_dates",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_locus_entrylines",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_locus_recap",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_locus_shipments",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_ci_lines",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_ci_tariff_active",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_container",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_date_notes",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_master_house_bills",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_shipments",
                "arn:aws:glue:*:${var.arn_no}:table/reporting/daily_smartborder_tracing_dates",
                "arn:aws:s3:::lii-data-analytics-${var.env}/application/reporting",
                "arn:aws:s3:::lii-data-analytics-${var.env}/application/reporting/*",
                "arn:aws:s3:::lii-data-athena-results-${var.env}/business-access-group",
                "arn:aws:s3:::lii-data-athena-results-${var.env}/business-access-group/*",
                "arn:aws:athena:*:${var.arn_no}:workgroup/business-access-group"
            ],
            "Effect": "Allow",
            "Sid": "BusinessPolicyUserPermissions"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "iam-attachment" {
  user       = aws_iam_user.iam.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_ssm_parameter" "user_arn" {
  name  = "/app/mlpv2/iam/user/mlpv2-dash-to-athena-user-${var.env}/arn"
  type  = "String"
  value = aws_iam_user.iam.arn
}

resource "aws_secretsmanager_secret" "credentials" {
  name = "/app/mlpv2/iam/user/mlpv2-dash-to-athena-user-${var.env}/credentials"
  description = "mlpv2 dash-to-athena credentials"
}

resource "aws_secretsmanager_secret_version" "credentials_val" {
  secret_id     = "${aws_secretsmanager_secret.credentials.id}"
  secret_string = jsonencode({"AccessKey" = aws_iam_access_key.key.id, "SecretAccessKey" = aws_iam_access_key.key.secret})
}

resource "aws_secretsmanager_secret_policy" "secret_policy" {
  secret_arn = aws_secretsmanager_secret.credentials.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAnotherAWSAccountToReadTheSecret",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.mlp}:role/mlpv2/${var.env}/roles/mlpv2-${var.env}-svc-dash"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
POLICY
}
