locals{
  prefix = length(regexall("prod", var.env)) > 0 ? "" : "${var.env}-"
}

resource "aws_ses_template" "CompanyMicroserviceSuccessTemplate" {
  name    = "tcm-${var.env}-companymicroservice-success"
  subject = "TCM ${var.env} Company Microservice Data Extraction - Successful Execution"
  html    = "<p>The following <strong>{{totalfiles}}</strong> files have been dropped and validated into S3 Bucket including confirmation token file:<br />{{filenameshtml}}<br />Execution times:<br/><li><code>Start time:&nbsp;{{dataexecutionstarttime}}</code></li><li><code>End time:&nbsp;&nbsp;&nbsp;{{dataexecutionendtime}}</code></li><br />Elapsed time: {{elapsedtime}} (s)<br /></p>"
  text    = "The following {{totalfiles}} files have been dropped and validated into S3 Bucket including confirmation token file:\r\n{{filenamestxt}}\r\n\r\nExecution times:\r\n\t- Start time: {{dataexecutionstarttime}}\r\n\t- End time:   {{dataexecutionendtime}}\r\n\r\nElapsed time: {{elapsedtime}} (s)"
}

resource "aws_ssm_parameter" "CompanyMicroserviceSuccessTemplateConfig" {
  name  = "/tcm/${var.env}/companymicroservice/ses-success-template-config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"Destination":{"ToAddresses":["lii-dataops@livingstonintl.com"],"BccAddresses":["stasovac@livingstonintl.com","JRios@livingstonintl.com"]},"Source":"noreply@${local.prefix}tcm.livingston.com","Template":"tcm-${var.env}-companymicroservice-success", "TemplateData":"\\{\"totalfiles\": \"{}\", \"filenameshtml\": \"{}\",  \"filenamestxt\": \"{}\", \"dataexecutionstarttime\": \"{}\", \"dataexecutionendtime\": \"{}\",\"elapsedtime\": \"{}\"\\}"})
}

resource "aws_ses_template" "CompanyMicroserviceWarningTemplate" {
  name    = "tcm-${var.env}-companymicroservice-warning"
  subject = "TCM ${var.env} Company Microservice Data Extraction - Successful Execution with WARNING: DateTime Parameter unsucessfully updated"
  html    = "<p>The following <strong>{{totalfiles}}</strong> files have been dropped and validated into S3 Bucket including confirmation token file:<br />{{filenameshtml}}<br />Execution times:</p><ul><li><code>Start time:&nbsp;{{dataexecutionstarttime}}</code></li><li><code>End time:&nbsp;&nbsp;&nbsp;{{dataexecutionendtime}}</code></li></ul><p><br />Elapsed time: {{elapsedtime}} (s)</p><p>Data Push Process <strong>{{executiontimestamp}}</strong>&nbsp;fails to update DateTime execution parameter:</p><h2><strong><code>{{datetimeparameter}}</code></strong></h2><p>Please take corresponding manual intervention to update the parameter for next execution.</p><p>Details of the error:</p><p><strong>Error type:</strong><br />{{exceptiontype}}</p><p><strong>Error message:</strong><br />{{exceptionmessage}}</p><p><strong>Stack trace:</strong><br />{{exceptiontrace}}</p>"
  text    = "The following {{totalfiles}} files have been dropped and validated into S3 Bucket including confirmation token file:\r\n{{filenameshtml}}\r\nExecution times:\r\n\r\n\t- Start time: {{dataexecutionstarttime}}\r\n\t- End time:   {{dataexecutionendtime}}\r\n\r\nElapsed time: {{elapsedtime}} (s)\r\n\r\nData Push Process {{executiontimestamp}} fails to update DateTime execution parameter:\r\n\r\n{{datetimeparameter}}\r\n\r\nPlease take corresponding manual intervention to update the parameter for next execution.\r\n\r\nDetails of the error:\r\n\r\nError type:\r\n{{exceptiontype}}\r\n\r\nError message:\r\n{{exceptionmessage}}\r\n\r\nStack trace:\r\n{{exceptiontrace}}"
}

resource "aws_ssm_parameter" "CompanyMicroserviceWarningTemplateConfig" {
  name  = "/tcm/${var.env}/companymicroservice/ses-warning-template-config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"Destination":{"ToAddresses":["lii-dataops@livingstonintl.com"],"BccAddresses":["stasovac@livingstonintl.com","JRios@livingstonintl.com"]},"Source":"noreply@${local.prefix}tcm.livingston.com","Template":"tcm-${var.env}-companymicroservice-warning","TemplateData":"{\"totalfiles\": \"{}\", \"filenameshtml\": \"{}\",  \"filenamestxt\": \"{}\", \"dataexecutionstarttime\": \"{}\", \"dataexecutionendtime\": \"{}\", \"elapsedtime\": \"{}\", \"executiontimestamp\": \"{}\", \"datetimeparameter\": \"{}\", \"exceptiontype\": [{}],\"exceptionmessage\": [{}],\"exceptiontrace\": [{}]\\}"})
}

resource "aws_ses_template" "CompanyMicroserviceFailureTemplate" {
  name    = "tcm-${var.env}-companymicroservice-failure"
  subject = "TCM ${var.env} Company Microservice Data Extraction - Unsuccessful Execution"
  html    = "<p>State Machine Name: <strong>{{statemachinename}}</strong></p><p>Data Push process <strong>{{executiontimestamp}}</strong> fails with following error:</p><p><strong>Error type:</strong><br />{{exceptiontype}}</p><p><strong>Error message:</strong><br />{{exceptionmessage}}</p><p><strong>Stack trace:</strong><br />{{exceptiontrace}}</p><p>Executon Event History: <a title=\"Execution Event History\" href=\"https://console.aws.amazon.com/states/home?region=us-east-1#/executions/details/{{executionid}}\"><strong>{{executionname}}</strong></a></p>"
  text    = "State Machine Name: {{statemachinename}}\r\n\r\nData Push process {{executiontimestamp}} fails with following error:\r\n\r\nError type:\r\n{{exceptiontype}}\r\n\r\nError message:\r\n{{exceptionmessage}}\r\n\r\nStack trace:\r\n{{exceptiontrace}}\r\n\r\nExecuton Event History: https://console.aws.amazon.com/states/home?region=us-east-1#/executions/details/{{executionid}}"
}

resource "aws_ssm_parameter" "CompanyMicroserviceFailureTemplateConfig" {
  name  = "/tcm/${var.env}/companymicroservice/ses-failure-template-config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"Destination":{"ToAddresses":["lii-dataops@livingstonintl.com"],"BccAddresses":["stasovac@livingstonintl.com","JRios@livingstonintl.com"]},"Source":"noreply@${local.prefix}tcm.livingston.com","Template":"tcm-${var.env}-companymicroservice-failure","TemplateData":"\\{\"statemachinename\": \"{}\", \"executionname\": \"{}\", \"executionid\": \"{}\", \"executiontimestamp\": \"{}\", \"exceptiontype\": [{}],\"exceptionmessage\": [{}],\"exceptiontrace\": [{}]\\}"})
}

resource "aws_ses_template" "CompanyMicroserviceValidationTemplate" {
  name    = "tcm-${var.env}-companymicroservice-validation"
  subject = "TCM ${var.env} Company Microservice Data Extraction - File Validation Failure"
  html    = "<p>The following <strong>{{totalfiles}}</strong> files have been dropped and validated into S3 Bucket but fail internal JSON template validation:<br />{{filenameshtml}}<br />Execution times:</p><ul><li><code>Start time:&nbsp;{{dataexecutionstarttime}}</code></li><li><code>End time:&nbsp;&nbsp;&nbsp;{{dataexecutionendtime}}</code></li></ul><p><br />Elapsed time: {{elapsedtime}} (s)</p><p>&nbsp;</p><p><strong>Error message:</strong><br />{{exceptionmessage}}</p><p><strong>Stack trace:</strong><br />{{exceptiontrace}}</p><p>State Machine Name: <strong>{{statemachinename}}</strong></p><p>Executon Event History: <a title=\"Execution Event History\" href=\"https://console.aws.amazon.com/states/home?region=us-east-1#/executions/details/{{executionid}}\"><strong>{{executionname}}</strong></a></p>"
  text    = "The following {{totalfiles}} files have been dropped and validated into S3 Bucket but fail internal JSON template validation:\r\n{{filenamestxt}}\r\n\r\nExecution times:\r\n\t- Start time: {{dataexecutionstarttime}}\r\n\t- End time:   {{dataexecutionendtime}}\r\n\r\nElapsed time: {{elapsedtime}} (s)\r\n\r\nError message:\r\n{{exceptionmessage}}\r\n\r\nStack trace:\r\n{{exceptiontrace}}\r\n\r\nState Machine Name: {{statemachinename}}\r\n\r\nExecution Event History: https://console.aws.amazon.com/states/home?region=us-east-1#/executions/details/{{executionid}}"
}

resource "aws_ssm_parameter" "CompanyMicroserviceValidationTemplateConfig" {
  name  = "/tcm/${var.env}/companymicroservice/ses-validation-template-config"
  type  = "String"
  data_type = "text"
  tier = "Standard"
  value = jsonencode({"Destination":{"ToAddresses":["lii-dataops@livingstonintl.com"],"BccAddresses":["stasovac@livingstonintl.com","JRios@livingstonintl.com"]},"Source":"noreply@${local.prefix}tcm.livingston.com","Template":"tcm-${var.env}-companymicroservice-validation","TemplateData":"\\{\"statemachinename\": \"{}\", \"executionname\": \"{}\", \"executionid\": \"{}\", \"totalfiles\": \"{}\", \"filenameshtml\": \"{}\",  \"filenamestxt\": \"{}\", \"dataexecutionstarttime\": \"{}\", \"dataexecutionendtime\": \"{}\",\"elapsedtime\": \"{}\",\"exceptionmessage\": [{}],\"exceptiontrace\": [{}]\\}"})
}
