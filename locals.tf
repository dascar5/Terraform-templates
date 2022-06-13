#if env=dev, use dev value...
locals{
  dev = "${var.env == "dev" ? "arn:aws:acm:us-east-1:336990213410:certificate/3da0109f-6da2-4f6a-a5c8-fccef7c3e09b" : ""}"
  qa = "${var.env == "qa" ? "arn:aws:acm:us-east-1:336990213410:certificate/8952549e-cd55-47e9-b636-e9c76f1610e9" : ""}"
  uat = "${var.env == "uat" ? "arn:aws:acm:us-east-1:711237182968:certificate/578d8f8e-6445-4574-ae6e-8c0f3bd8ef91" : ""}"
  prod = "${var.env == "prod" ? "arn:aws:acm:us-east-1:711237182968:certificate/6b2a5e83-f9ee-4e4e-9767-2bbdc9d16324" : ""}"
  acm = "${coalesce(local.dev, local.qa, local.uat, local.prod)}"
}

#if env = dev or qa, use mlnonprod, else use mlprod
locals{
  aws_env = length(regexall("dev|qa", var.env)) > 0 ? "mlnonprod" : "mlprod"
}