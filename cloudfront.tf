locals{
  dev = "${var.env == "dev" ? "arn:aws:acm:us-east-1:336990213410:certificate/3da0109f-6da2-4f6a-a5c8-fccef7c3e09b" : ""}"
  qa = "${var.env == "qa" ? "arn:aws:acm:us-east-1:336990213410:certificate/8952549e-cd55-47e9-b636-e9c76f1610e9" : ""}"
  uat = "${var.env == "uat" ? "arn:aws:acm:us-east-1:711237182968:certificate/578d8f8e-6445-4574-ae6e-8c0f3bd8ef91" : ""}"
  prod = "${var.env == "prod" ? "arn:aws:acm:us-east-1:711237182968:certificate/6b2a5e83-f9ee-4e4e-9767-2bbdc9d16324" : ""}"
  acm = "${coalesce(local.dev, local.qa, local.uat, local.prod)}"
}

data "aws_iam_policy_document" "assume-policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "ldi-${var.env}-ui-cf"
  assume_role_policy = "${data.aws_iam_policy_document.assume-policy.json}"
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
    name = "s3-access_ldi-${var.env}-ui-cf"
    path = "/"
    policy = data.aws_iam_policy_document.s3-access.json
}

resource "aws_iam_role_policy_attachment" "s3-access" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.s3-access.arn
}

#----------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "prod_website" {  
  bucket = "ldi-${var.env}-ui"
  force_destroy = true
    acl = "public-read"
    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["PUT","POST","GET","HEAD","DELETE"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
    }
}


resource "aws_s3_bucket_policy" "prod_website" {  
  bucket = aws_s3_bucket.prod_website.id   
  policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": "*",   
            "Action": ["s3:*"],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.prod_website.id}",
                "arn:aws:s3:::${aws_s3_bucket.prod_website.id}/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.prod_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

output "s3_bucket_id" {
  value = aws_s3_bucket.prod_website.id
}

#---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.prod_website.bucket_regional_domain_name}"
    origin_id = "S3-${aws_s3_bucket.prod_website.bucket}"
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["cloudfront.${var.env}.mlnonprod.liiaws.net"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.prod_website.bucket}"
    forwarded_values {
      query_string = false
    cookies {
        forward = "none"
        }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


price_class = "PriceClass_100"
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
  viewer_certificate {
    acm_certificate_arn = "${local.acm}"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}