locals{
  endpoint_id = length(regexall("dev|qa", var.env)) > 0 ? "chmydox7cb8s" : "c6iyn5efgjjt"
}

resource "aws_ssm_parameter" "ClientApplicableAgreementExport2s3Config" {
  name  = "/tcm/${var.env}/companymicroservice/clientapplicableagreement-export2s3/config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"ENDPOINT":"gtmo-${var.env}-companymicroservice.${local.endpoint_id}.us-east-1.rds.amazonaws.com","PORT":"5432","USR":"db_ro_user","REGION":"us-east-1","DBNAME":"company","_limit":10000,"bucket":"lii-data-ingest-${var.env}","microservice_table":"Company_ClientApplicableAgreement","db_schema":"gtmo","db_table":"ClientApplicableAgreement","counter_key":"Id","orderby_key":"Id","updated_on_key":"UpdatedOn","db_columns":["Id","RegionName","RegionCode","ClientRoleServiceId","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"json_schema":{"$schema":"http://json-schema.org/draft-07/schema","$id":"http://example.com/example.json","type":"object","default":{},"properties":{"sequence_number":{"type":"number"},"executed_on":{"type":"string"},"Company_ClientApplicableAgreement":{"type":"object","properties":{"total_rows":{"type":"number"},"Rows":{"type":"array","additionalItems":true,"items":{"anyOf":[{"type":"object","required":["Id","RegionName","RegionCode","ClientRoleServiceId","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"properties":{"Id":{"type":"number"},"RegionName":{"type":["string","null"]},"RegionCode":{"type":["string","null"]},"ClientRoleServiceId":{"type":"number"},"CreatedBy":{"type":"string"},"CreatedOn":{"type":"string"},"UpdatedBy":{"type":["string","null"]},"UpdatedOn":{"type":["string","null"]}},"additionalProperties":true}]}}},"additionalProperties":true}},"additionalProperties":true}})
}

resource "aws_ssm_parameter" "ClientApplicableAgreementExport2s3LastExecutedDateTime" {
  name  = "/tcm/${var.env}/companymicroservice/clientapplicableagreement-export2s3/lastExecutedDateTime"
  type  = "String"
  tier = "Standard"
  value = "2021-01-01T01:00:00.257118+00:00"
  lifecycle {
    ignore_changes = [
     name,type,tier,value
    ]
  }
}

resource "aws_ssm_parameter" "ClientSupplierContactExport2s3Config" {
  name  = "/tcm/${var.env}/companymicroservice/clientsuppliercontact-export2s3/config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"ENDPOINT":"gtmo-${var.env}-companymicroservice.${local.endpoint_id}.us-east-1.rds.amazonaws.com","PORT":"5432","USR":"db_ro_user","REGION":"us-east-1","DBNAME":"company","_limit":10000,"bucket":"lii-data-ingest-${var.env}","microservice_table":"Company_ClientSupplierContact","db_schema":"gtmo","db_table":"ClientSupplierContact","counter_key":"Id","orderby_key":"Id","updated_on_key":"UpdatedOn","db_columns":["Id","EmailAddress","PrimaryContact","ClientSupplierId","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"json_schema":{"$schema":"http://json-schema.org/draft-07/schema","$id":"http://example.com/example.json","type":"object","default":{},"properties":{"sequence_number":{"type":"number"},"executed_on":{"type":"string"},"Company_ClientSupplierContact":{"type":"object","properties":{"total_rows":{"type":"number"},"Rows":{"type":"array","additionalItems":true,"items":{"anyOf":[{"type":"object","required":["Id","EmailAddress","PrimaryContact","ClientSupplierId","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"properties":{"Id":{"type":"number"},"EmailAddress":{"type":["string","null"]},"PrimaryContact":{"type":"boolean"},"ClientSupplierId":{"type":"number"},"CreatedBy":{"type":"string"},"CreatedOn":{"type":"string"},"UpdatedBy":{"type":["string","null"]},"UpdatedOn":{"type":["string","null"]}},"additionalProperties":true}]}}},"additionalProperties":true}},"additionalProperties":true}})
}

resource "aws_ssm_parameter" "ClientSupplierContactExport2s3LastExecutedDateTime" {
  name  = "/tcm/${var.env}/companymicroservice/clientsuppliercontact-export2s3/lastExecutedDateTime"
  type  = "String"
  tier = "Standard"
  value = "2021-01-01T01:00:00.257118+00:00"
  lifecycle {
    ignore_changes = [
     name,type,tier,value
    ]
  }
}

resource "aws_ssm_parameter" "ClientSupplierExport2s3Config" {
  name  = "/tcm/${var.env}/companymicroservice/clientsupplier-export2s3/config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"ENDPOINT":"gtmo-${var.env}-companymicroservice.${local.endpoint_id}.us-east-1.rds.amazonaws.com","PORT":"5432","USR":"db_ro_user","REGION":"us-east-1","DBNAME":"company","_limit":10000,"bucket":"lii-data-ingest-${var.env}","microservice_table":"Company_ClientSupplier","db_schema":"gtmo","db_table":"ClientSupplier","counter_key":"Id","orderby_key":"Id","updated_on_key":"UpdatedOn","db_columns":["Id","ClientDivisionId","SupplierDivisionId","SupplierCode","AddressId","ClientRoleId","AlternateSupplierCode","IsParentCompany","Status","StatusNote","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"json_schema":{"$schema":"http://json-schema.org/draft-07/schema","$id":"http://example.com/example.json","type":"object","default":{},"properties":{"sequence_number":{"type":"number"},"executed_on":{"type":"string"},"Company_ClientSupplier":{"type":"object","properties":{"total_rows":{"type":"number"},"Rows":{"type":"array","additionalItems":true,"items":{"anyOf":[{"type":"object","required":["Id","ClientDivisionId","SupplierDivisionId","SupplierCode","AddressId","ClientRoleId","AlternateSupplierCode","IsParentCompany","Status","StatusNote","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"properties":{"Id":{"type":"number"},"ClientDivisionId":{"type":"number"},"SupplierDivisionId":{"type":"number"},"SupplierCode":{"type":["string","null"]},"AddressId":{"type":"number"},"ClientRoleId":{"type":"number"},"AlternateSupplierCode":{"type":["string","null"]},"IsParentCompany":{"type":"boolean"},"Status":{"type":["string","null"]},"StatusNote":{"type":["string","null"]},"CreatedBy":{"type":"string"},"CreatedOn":{"type":"string"},"UpdatedBy":{"type":["string","null"]},"UpdatedOn":{"type":["string","null"]}},"additionalProperties":true}]}}},"additionalProperties":true}},"additionalProperties":true}})
}

resource "aws_ssm_parameter" "ClientSupplierExport2s3LastExecutedDateTime" {
  name  = "/tcm/${var.env}/companymicroservice/clientsupplier-export2s3/lastExecutedDateTime"
  type  = "String"
  tier = "Standard"
  value = "2021-01-01T01:00:00.257118+00:00"
  lifecycle {
    ignore_changes = [
     name,type,tier,value
    ]
  }
}

resource "aws_ssm_parameter" "CompanyExport2s3Config" {
  name  = "/tcm/${var.env}/companymicroservice/company-export2s3/config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"ENDPOINT":"gtmo-${var.env}-companymicroservice.${local.endpoint_id}.us-east-1.rds.amazonaws.com","PORT":"5432","USR":"db_ro_user","REGION":"us-east-1","DBNAME":"company","_limit":10000,"bucket":"lii-data-ingest-${var.env}","microservice_table":"Company_Company","db_schema":"gtmo","db_table":"Company","counter_key":"Id","orderby_key":"Id","updated_on_key":"UpdatedOn","db_columns":["Id","Name","ImageUrl","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"json_schema":{"$schema":"http://json-schema.org/draft-07/schema","$id":"http://example.com/example.json","type":"object","default":{},"properties":{"sequence_number":{"type":"number"},"executed_on":{"type":"string"},"Company_Company":{"type":"object","properties":{"total_rows":{"type":"number"},"Rows":{"type":"array","additionalItems":true,"items":{"anyOf":[{"type":"object","required":["Id","Name","ImageUrl","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"properties":{"Id":{"type":"number"},"Name":{"type":["string","null"]},"ImageUrl":{"type":["string","null"]},"CreatedBy":{"type":"string"},"CreatedOn":{"type":"string"},"UpdatedBy":{"type":["string","null"]},"UpdatedOn":{"type":["string","null"]}},"additionalProperties":true}]}}},"additionalProperties":true}},"additionalProperties":true}})
}

resource "aws_ssm_parameter" "CompanyExport2s3LastExecutedDateTime" {
  name  = "/tcm/${var.env}/companymicroservice/company-export2s3/lastExecutedDateTime"
  type  = "String"
  tier = "Standard"
  value = "2021-01-01T01:00:00.257118+00:00"
  lifecycle {
    ignore_changes = [
     name,type,tier,value
    ]
  }
}

resource "aws_ssm_parameter" "DivisionExport2s3Config" {
  name  = "/tcm/${var.env}/companymicroservice/division-export2s3/config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"ENDPOINT":"gtmo-${var.env}-companymicroservice.${local.endpoint_id}.us-east-1.rds.amazonaws.com","PORT":"5432","USR":"db_ro_user","REGION":"us-east-1","DBNAME":"company","_limit":10000,"bucket":"lii-data-ingest-${var.env}","microservice_table":"Company_Division","db_schema":"gtmo","db_table":"Division","counter_key":"Id","orderby_key":"Id","updated_on_key":"UpdatedOn","db_columns":["Id","Name","Active","Customer","Supplier","Broker","Client","CompanyId","PrimaryContactId","PrimaryAccountManagerId","TaxName","TaxId","BusinessNumber","DivisionLogicalId","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"json_schema":{"$schema":"http://json-schema.org/draft-07/schema","$id":"http://example.com/example.json","type":"object","default":{},"properties":{"sequence_number":{"type":"number"},"executed_on":{"type":"string"},"Company_Division":{"type":"object","properties":{"total_rows":{"type":"number"},"Rows":{"type":"array","additionalItems":true,"items":{"anyOf":[{"type":"object","required":["Id","Name","Active","Customer","Supplier","Broker","Client","CompanyId","PrimaryContactId","PrimaryAccountManagerId","TaxName","TaxId","BusinessNumber","DivisionLogicalId","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"properties":{"Id":{"type":"number"},"Name":{"type":["string","null"]},"Active":{"type":"boolean"},"Customer":{"type":"boolean"},"Supplier":{"type":"boolean"},"Broker":{"type":"boolean"},"Client":{"type":"boolean"},"CompanyId":{"type":["number","null"]},"PrimaryContactId":{"type":["number","null"]},"PrimaryAccountManagerId":{"type":["number","null"]},"TaxName":{"type":["string","null"]},"TaxId":{"type":["string","null"]},"BusinessNumber":{"type":["string","null"]},"DivisionLogicalId":{"type":"number"},"CreatedBy":{"type":"string"},"CreatedOn":{"type":"string"},"UpdatedBy":{"type":["string","null"]},"UpdatedOn":{"type":["string","null"]}},"additionalProperties":true}]}}},"additionalProperties":true}},"additionalProperties":true}})
}

resource "aws_ssm_parameter" "DivisionExport2s3LastExecutedDateTime" {
  name  = "/tcm/${var.env}/companymicroservice/division-export2s3/lastExecutedDateTime"
  type  = "String"
  tier = "Standard"
  value = "2021-01-01T01:00:00.257118+00:00"
  lifecycle {
    ignore_changes = [
     name,type,tier,value
    ]
  }
}

resource "aws_ssm_parameter" "AddressExport2s3Config" {
  name  = "/tcm/${var.env}/companymicroservice/address-export2s3/config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"ENDPOINT":"gtmo-${var.env}-companymicroservice.${local.endpoint_id}.us-east-1.rds.amazonaws.com","PORT":"5432","USR":"db_ro_user","REGION":"us-east-1","DBNAME":"company","_limit":10000,"bucket":"lii-data-ingest-${var.env}","microservice_table":"Company_Address","db_schema":"gtmo","db_table":"Address","counter_key":"Id","orderby_key":"Id","updated_on_key":"UpdatedOn","db_columns":["Id","Name","Email","AddressLine1","AddressLine2","City","State","ZipCode","Country","PhoneNumber","PhoneCountry","Bytes","Hash","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"json_schema":{"$schema":"http://json-schema.org/draft-07/schema","$id":"http://example.com/example.json","type":"object","default":{},"properties":{"sequence_number":{"type":"number"},"executed_on":{"type":"string"},"Company_Address":{"type":"object","properties":{"total_rows":{"type":"number"},"Rows":{"type":"array","additionalItems":true,"items":{"anyOf":[{"type":"object","required":["Id","Name","Email","AddressLine1","AddressLine2","City","State","ZipCode","Country","PhoneNumber","PhoneCountry","Bytes","Hash","CreatedBy","CreatedOn","UpdatedBy","UpdatedOn"],"properties":{"Id":{"type":"number"},"Name":{"type":["string","null"]},"Email":{"type":["string","null"]},"AddressLine1":{"type":["string","null"]},"AddressLine2":{"type":["string","null"]},"City":{"type":["string","null"]},"State":{"type":["string","null"]},"ZipCode":{"type":["string","null"]},"Country":{"type":["string","null"]},"PhoneNumber":{"type":["string","null"]},"PhoneCountry":{"type":["string","null"]},"Bytes":{"type":["string","null"]},"Hash":{"type":"number"},"CreatedBy":{"type":"string"},"CreatedOn":{"type":"string"},"UpdatedBy":{"type":["string","null"]},"UpdatedOn":{"type":["string","null"]}},"additionalProperties":true}]}}},"additionalProperties":true}},"additionalProperties":true}})
}

resource "aws_ssm_parameter" "AddressExport2s3LastExecutedDateTime" {
  name  = "/tcm/${var.env}/companymicroservice/address-export2s3/lastExecutedDateTime"
  type  = "String"
  tier = "Standard"
  value = "2021-01-01T01:00:00.257118+00:00"
  lifecycle {
    ignore_changes = [
     name,type,tier,value
    ]
  }
}



