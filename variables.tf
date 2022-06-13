variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "access_key"{
  description = "access key of the account"
}

variable "secret_key"{
  description = "secret key of the account"
}

variable "env"{
  description = "branch"
}

variable "role_arn"{
  description = "role arn"
}

variable "bucket_id"{
  description = "bucket id"
}

variable "vpcid"{
  description = "vpcid"
}

variable "vpce"{
  description = "vpce"
}

variable "subnet1"{
  description = "data subnet 1"
}

variable "subnet2"{
  description = "data subnet 2"
}

variable "imageuri"{
  description = "Image uri"
}