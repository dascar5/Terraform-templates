#if variable bool = true, create resource, if false, don't

resource "aws_api_gateway_rest_api" "apig" {
  count = var.api_gateway ? 1:0
  name = "project-hs-file-downloader-ca-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

variable "api_gateway" {
  type        = bool
  default     = false
  description = ""
}

#-------------------------------------------------------------------------

#hacky conditional

locals{
  create = length(regexall("dev", var.env)) > 0 ? true : false
}

variable "create"{
  type = bool 
  default = true
  description = ""
}
#dev domain
resource "aws_api_gateway_domain_name" "dev-domain" {
  count = var.create ? 1 : 0
  domain_name = "project-apig.dev.mlnonprod.projectaws.net"
  certificate_arn = "arn:aws:acm:us-east-1:xxx"
}

resource "aws_route53_record" "dev-record" {
  count = var.create ? 1 : 0
  name    = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
  type    = "A"
  zone_id = "xxx"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.dev-domain[count.index].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.dev-domain[count.index].cloudfront_zone_id
  }
}