module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "ldi-${var.env}-searchwatch-ddb"
  hash_key = "SearchQuery"

  attributes = [
    {
      name = "SearchQuery"
      type = "S"
    }
  ]
}