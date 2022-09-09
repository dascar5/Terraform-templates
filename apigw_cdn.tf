#dev domain
resource "aws_api_gateway_domain_name" "dev-domain" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  domain_name = "project-apig.dev.mlnonprod.liiaws.net"
  certificate_arn = "arn:aws:acm:us-east-1:xxx"
}

#qa domain
resource "aws_api_gateway_domain_name" "qa-domain" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  domain_name = "project-apig.qa.mlnonprod.liiaws.net"
  certificate_arn = "arn:aws:acm:us-east-1:xxx"
}

resource "aws_api_gateway_domain_name" "uat-domain" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  domain_name = "project-apig.uat.mlnonprod.liiaws.net"
  certificate_arn = "arn:aws:acm:us-east-1:xxx"
}

resource "aws_api_gateway_domain_name" "prod-domain" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  domain_name = "project-apig.prod.mlnonprod.liiaws.net"
  certificate_arn = "arn:aws:acm:us-east-1:xxx"
}


#---------------------------------------------------------------------------------------
resource "aws_route53_record" "dev-record" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  name    = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
  type    = "A"
  zone_id = "xxx"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.dev-domain[count.index].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.dev-domain[count.index].cloudfront_zone_id
  }
}

resource "aws_route53_record" "qa-record" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  name    = aws_api_gateway_domain_name.qa-domain[count.index].domain_name
  type    = "A"
  zone_id = "xxx"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.qa-domain[count.index].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.qa-domain[count.index].cloudfront_zone_id
  }
}

resource "aws_route53_record" "uat-record" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  name    = aws_api_gateway_domain_name.uat-domain[count.index].domain_name
  type    = "A"
  zone_id = "xxx"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.uat-domain[count.index].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.uat-domain[count.index].cloudfront_zone_id
  }
}

resource "aws_route53_record" "prod-record" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  name    = aws_api_gateway_domain_name.prod-domain[count.index].domain_name
  type    = "A"
  zone_id = "xxx"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.prod-domain[count.index].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.prod-domain[count.index].cloudfront_zone_id
  }
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_downloader" {
  name = "project-hs-file-downloader-ca-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_downloader-dev" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "dev"
  api_id      = aws_api_gateway_rest_api.apig_downloader.id
  base_path = "hs"
  domain_name = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_downloader-qa" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "qa"
  api_id      = aws_api_gateway_rest_api.apig_downloader.id
  base_path = "hs"
  domain_name = aws_api_gateway_domain_name.qa-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_downloader-uat" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "uat"
  api_id      = aws_api_gateway_rest_api.apig_downloader.id
  base_path = "hs"
  domain_name = aws_api_gateway_domain_name.uat-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_downloader-prod" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "prod"
  api_id      = aws_api_gateway_rest_api.apig_downloader.id
  base_path = "hs"
  domain_name = aws_api_gateway_domain_name.prod-domain[count.index].domain_name
}

resource "aws_ssm_parameter" "apig_downloader" {
  name  = "/lii-project/${var.env}/api/hs-file-downloader-ca/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_downloader.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_searchterm" {
  name = "project-searchterm-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_searchterm-dev" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "dev"
  api_id      = aws_api_gateway_rest_api.apig_searchterm.id
  base_path = "st"
  domain_name = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_searchterm-qa" { 
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "qa"
  api_id      = aws_api_gateway_rest_api.apig_searchterm.id
  base_path = "st"
  domain_name = aws_api_gateway_domain_name.qa-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_searchterm-uat" { 
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "uat"
  api_id      = aws_api_gateway_rest_api.apig_searchterm.id
  base_path = "st"
  domain_name = aws_api_gateway_domain_name.uat-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_searchterm-prod" { 
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "prod"
  api_id      = aws_api_gateway_rest_api.apig_searchterm.id
  base_path = "st"
  domain_name = aws_api_gateway_domain_name.prod-domain[count.index].domain_name
}

resource "aws_ssm_parameter" "apig_searchterm" {
  name  = "/lii-project/${var.env}/api/search-term/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_searchterm.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_process" {
  name = "project-multi-description-search-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_process-dev" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "dev"
  api_id      = aws_api_gateway_rest_api.apig_process.id
  base_path = "mds"
  domain_name = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_process-qa" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "qa"
  api_id      = aws_api_gateway_rest_api.apig_process.id
  base_path = "mds"
  domain_name = aws_api_gateway_domain_name.qa-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_process-uat" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "uat"
  api_id      = aws_api_gateway_rest_api.apig_process.id
  base_path = "mds"
  domain_name = aws_api_gateway_domain_name.uat-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_process-prod" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "prod"
  api_id      = aws_api_gateway_rest_api.apig_process.id
  base_path = "mds"
  domain_name = aws_api_gateway_domain_name.prod-domain[count.index].domain_name
}

resource "aws_ssm_parameter" "apig_process" {
  name  = "/lii-project/${var.env}/api/mult-desc-srch-process/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_process.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_searchwatch" {
  name = "project-searchwatch-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_searchwatch-dev" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "dev"
  api_id      = aws_api_gateway_rest_api.apig_searchwatch.id
  base_path = "sw"
  domain_name = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_searchwatch-qa" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "qa"
  api_id      = aws_api_gateway_rest_api.apig_searchwatch.id
  base_path = "sw"
  domain_name = aws_api_gateway_domain_name.qa-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_searchwatch-uat" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "uat"
  api_id      = aws_api_gateway_rest_api.apig_searchwatch.id
  base_path = "sw"
  domain_name = aws_api_gateway_domain_name.uat-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_searchwatch-prod" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "prod"
  api_id      = aws_api_gateway_rest_api.apig_searchwatch.id
  base_path = "sw"
  domain_name = aws_api_gateway_domain_name.prod-domain[count.index].domain_name
}

resource "aws_ssm_parameter" "apig_searchwatch" {
  name  = "/lii-project/${var.env}/api/searchwatch/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_searchwatch.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_upc" {
  name = "project-upc-service-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_upc-dev" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "dev"
  api_id      = aws_api_gateway_rest_api.apig_upc.id
  base_path = "upc"
  domain_name = aws_api_gateway_domain_name.dev-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_upc-qa" {
  count = length(regexall("dev", var.env)) > 0 ? 1 : 0
  stage_name = "qa"
  api_id      = aws_api_gateway_rest_api.apig_upc.id
  base_path = "upc"
  domain_name = aws_api_gateway_domain_name.qa-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_upc-uat" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "uat"
  api_id      = aws_api_gateway_rest_api.apig_upc.id
  base_path = "upc"
  domain_name = aws_api_gateway_domain_name.uat-domain[count.index].domain_name
}

resource "aws_api_gateway_base_path_mapping" "apig_upc-prod" {
  count = length(regexall("uat", var.env)) > 0 ? 1 : 0
  stage_name = "prod"
  api_id      = aws_api_gateway_rest_api.apig_upc.id
  base_path = "upc"
  domain_name = aws_api_gateway_domain_name.prod-domain[count.index].domain_name
}

resource "aws_ssm_parameter" "apig_upc" {
  name  = "/lii-project/${var.env}/api/upcservice/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_upc.id
}