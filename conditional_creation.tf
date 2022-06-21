#if variable bool = true, create resource, if false, don't

resource "aws_api_gateway_rest_api" "apig" {
  count = var.api_gateway ? 1:0
  name = "ldi-hs-file-downloader-ca-apig"

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