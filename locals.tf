#if env=dev, use dev value...
locals{
  dev = "${var.env == "dev" ? "arn:aws:acm:us-east-1:xxx" : ""}"
  qa = "${var.env == "qa" ? "arn:aws:acm:us-east-1:xxx" : ""}"
  uat = "${var.env == "uat" ? "arn:aws:acm:us-east-1:xxx" : ""}"
  prod = "${var.env == "prod" ? "arn:aws:acm:us-east-1:xxx" : ""}"
  acm = "${coalesce(local.dev, local.qa, local.uat, local.prod)}"
}

#if env = dev or qa, use mlnonprod, else use mlprod
locals{
  aws_env = length(regexall("dev|qa", var.env)) > 0 ? "mlnonprod" : "mlprod"
}