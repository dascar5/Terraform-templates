locals{
  aws_env = length(regexall("dev|qa", var.env)) > 0 ? "mlnonprod" : "mlprod"
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name = "${var.env}.${local.aws_env}.liiaws.net"
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_downloader" {
  name = "ldi-hs-file-downloader-ca-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_downloader" {
  api_id      = aws_api_gateway_rest_api.apig_downloader.id
  base_path = "hs"
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}

resource "aws_ssm_parameter" "apig_downloader" {
  name  = "/lii-ldi/${var.env}/api/hs-file-downloader-ca/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_downloader.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_searchterm" {
  name = "ldi-searchterm-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_searchterm" {
  api_id      = aws_api_gateway_rest_api.apig_searchterm.id
  base_path = "st"
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}

resource "aws_ssm_parameter" "apig_searchterm" {
  name  = "/lii-ldi/${var.env}/api/search-term/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_searchterm.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_process" {
  name = "ldi-multi-description-search-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_process" {
  api_id      = aws_api_gateway_rest_api.apig_process.id
  base_path = "mds"
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}

resource "aws_ssm_parameter" "apig_process" {
  name  = "/lii-ldi/${var.env}/api/mult-desc-srch-process/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_process.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_searchwatch" {
  name = "ldi-searchwatch-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_searchwatch" {
  api_id      = aws_api_gateway_rest_api.apig_searchwatch.id
  base_path = "sw"
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}

resource "aws_ssm_parameter" "apig_searchwatch" {
  name  = "/lii-ldi/${var.env}/api/searchwatch/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_searchwatch.id
}
#---------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "apig_upc" {
  name = "ldi-upc-service-apig"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = ["${var.vpce}"]
  }
}

resource "aws_api_gateway_base_path_mapping" "apig_upc" {
  api_id      = aws_api_gateway_rest_api.apig_upc.id
  base_path = "upc"
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}

resource "aws_ssm_parameter" "apig_upc" {
  name  = "/lii-ldi/${var.env}/api/upcservice/APIId"
  type  = "String"
  value = aws_api_gateway_rest_api.apig_upc.id
}