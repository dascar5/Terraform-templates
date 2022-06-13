resource "aws_sfn_state_machine" "main-workflow" {
  name       = "tcm-${var.env}-companymicroservice-export2s3"
  role_arn   = aws_iam_role.iam_for_lambda.arn
  definition = <<EOF
{
	"Comment": "Export JSON formatted data from Company Microservice to S3 bucket",
	"StartAt": "StartState",
	"States": {
		"StartState": {
			"Type": "Pass",
			"Next": "GetParameters"
		},
		"GetParameters": {
			"Type": "Task",
			"Next": "GetDeltaRecordsNumber",
			"Parameters": {
				"Names.$": "$.*"
			},
			"Resource": "arn:aws:states:::aws-sdk:ssm:getParameters",
			"ResultSelector": {
				"lastExecutedDateTime.$": "$.Parameters[1].Value",
				"param_name.$": "$.Parameters[1].Name",
				"DataExecutionStartTime.$": "$$.State.EnteredTime",
				"config.$": "States.StringToJson($.Parameters[0].Value)"
			},
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"Next": "PassExecutionErrorData"
				}
			],
			"Retry": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"BackoffRate": 2,
					"IntervalSeconds": 60,
					"MaxAttempts": 2
				}
			]
		},
		"GetFailureSESParameters": {
			"Type": "Task",
			"Next": "SendFailureNotificationEmail",
			"Parameters": {
				"Names": [
					"/tcm/${var.env}/companymicroservice/ses-failure-template-config"
				]
			},
			"Resource": "arn:aws:states:::aws-sdk:ssm:getParameters",
			"ResultSelector": {
				"failure_config.$": "States.StringToJson($.Parameters[0].Value)"
			},
			"ResultPath": "$.param_name"
		},
		"SendFailureNotificationEmail": {
			"Type": "Task",
			"Next": "Fail",
			"Parameters": {
				"Destination.$": "$.param_name.failure_config.Destination",
				"Source.$": "$.param_name.failure_config.Source",
				"Template.$": "$.param_name.failure_config.Template",
				"TemplateData.$": "States.Format($.param_name.failure_config.TemplateData, $$.StateMachine.Name, $$.Execution.Name, $$.Execution.Id, $$.Execution.StartTime, States.JsonToString($.Cause.errorType), States.JsonToString($.Cause.errorMessage),States.JsonToString($.Cause.stackTrace))"
			},
			"Resource": "arn:aws:states:::aws-sdk:ses:sendTemplatedEmail"
		},
		"GetDeltaRecordsNumber": {
			"Type": "Task",
			"Resource": "arn:aws:states:::lambda:invoke",
			"Parameters": {
				"FunctionName": "${aws_lambda_function.count.arn}",
				"Payload": {
					"lastExecutedDateTime.$": "$.lastExecutedDateTime",
					"param_name.$": "$.param_name",
					"config.$": "$.config"
				}
			},
			"Retry": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"IntervalSeconds": 60,
					"MaxAttempts": 2,
					"BackoffRate": 2
				}
			],
			"Next": "DeltaRecordsNumber",
			"ResultPath": "$.Payload",
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"Next": "PassExecutionErrorData"
				}
			]
		},
		"PassExecutionErrorData": {
			"Type": "Pass",
			"Next": "DetermineErrorType",
			"Parameters": {
				"Cause.$": "States.StringToJson($.Cause)"
			}
		},
		"DetermineErrorType": {
			"Type": "Choice",
			"Choices": [
				{
					"Variable": "$.Cause.errorType",
					"StringMatches": "ValidationError",
					"Next": "GetValidationErrorSESParameters"
				}
			],
			"Default": "GetFailureSESParameters"
		},
		"GetValidationErrorSESParameters": {
			"Type": "Task",
			"Parameters": {
				"Names": [
					"/tcm/${var.env}/companymicroservice/ses-validation-template-config"
				]
			},
			"Resource": "arn:aws:states:::aws-sdk:ssm:getParameters",
			"ResultSelector": {
				"validation_config.$": "States.StringToJson($.Parameters[0].Value)"
			},
			"ResultPath": "$.param_name",
			"Next": "FormatEmailTemplate"
		},
		"SendValidationErrorNotificationEmail": {
			"Type": "Task",
			"Parameters": {
				"Destination.$": "$.param_name.validation_config.Destination",
				"Source.$": "$.param_name.validation_config.Source",
				"Template.$": "$.param_name.validation_config.Template",
				"TemplateData.$": "States.Format($.param_name.validation_config.TemplateData, $$.StateMachine.Name, $$.Execution.Name, $$.Execution.Id, $.FormattedData.Payload.totalfiles, $.FormattedData.Payload.filenameshtml, $.FormattedData.Payload.filenamestxt, $.FormattedData.Payload.dataexecutionstarttime, $.FormattedData.Payload.dataexecutionendtime, $.FormattedData.Payload.elapsedtime, States.JsonToString($.Cause.errorMessage), States.JsonToString($.Cause.stackTrace))"
			},
			"Resource": "arn:aws:states:::aws-sdk:ses:sendTemplatedEmail",
			"Next": "Fail"
		},
		"DeltaRecordsNumber": {
			"Type": "Choice",
			"Choices": [
				{
					"Variable": "$.Payload.Payload.totalRows",
					"NumericEquals": 0,
					"Next": "PassNoData"
				}
			],
			"Default": "Iterator"
		},
		"PassNoData": {
			"Type": "Pass",
			"Next": "PassNewExecutionDateTime",
			"Parameters": {
				"DataExecutionStartTime.$": "$.DataExecutionStartTime",
				"lastExecutedDateTime.$": "$.lastExecutedDateTime",
				"param_name.$": "$.param_name",
				"iterations.$": "$.Payload.Payload.iterations",
				"executedOn.$": "$.Payload.Payload.executedOn",
				"config": {
					"executedFiles": [
						{
							"fileName": "No Data"
						}
					],
					"totalfiles.$": "States.Format('{}', $.Payload.Payload.totalRows)"
				},
				"EndTime": {
					"DataExecutionEndTime.$": "$$.State.EnteredTime"
				},
				"Payload.$": "$.Payload"
			}
		},
		"Iterator": {
			"Type": "Map",
			"Next": "CheckForValidationError",
			"Iterator": {
				"StartAt": "ExecuteSqlQuery",
				"States": {
					"ExecuteSqlQuery": {
						"Type": "Task",
						"Resource": "arn:aws:states:::lambda:invoke",
						"Parameters": {
							"FunctionName": "${aws_lambda_function.query.arn}",
							"Payload.$": "$"
						},
						"End": true,
						"Retry": [
							{
								"ErrorEquals": [
									"States.ALL"
								],
								"BackoffRate": 2,
								"IntervalSeconds": 60,
								"MaxAttempts": 2
							}
						],
						"ResultSelector": {
							"statusCode.$": "$.Payload.statusCode",
							"fileName.$": "States.Format('{}', $.Payload.fileName)",
							"sequenceNumber.$": "$.Payload.sequenceNumber",
							"executedOn.$": "$.Payload.executedOn",
							"totalRows.$": "$.Payload.totalRows",
							"Cause.$": "$.Payload.Cause"
						}
					}
				}
			},
			"ItemsPath": "$.Payload.Payload.iterations",
			"Retry": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"BackoffRate": 2,
					"IntervalSeconds": 60,
					"MaxAttempts": 0
				}
			],
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"Next": "PassExecutionErrorData",
					"ResultPath": "$"
				}
			],
			"ResultPath": "$.config",
			"ResultSelector": {
				"executedFiles.$": "$.*",
				"totalfiles.$": "States.Format('{}', '')"
			}
		},
		"CheckForValidationError": {
			"Type": "Choice",
			"Choices": [
				{
					"Variable": "$.config.executedFiles[0].statusCode",
					"NumericEquals": 500,
					"Next": "PassValidationErrorData"
				}
			],
			"Default": "Wait"
		},
		"PassValidationErrorData": {
			"Type": "Pass",
			"Next": "GetValidationErrorSESParameters",
			"Parameters": {
				"lastExecutedDateTime.$": "$.lastExecutedDateTime",
				"param_name.$": "$.param_name",
				"executedOn.$": "$.Payload.Payload.executedOn",
				"filenames.$": "$.config.executedFiles[*].fileName",
				"totalfiles.$": "States.Format('{}', $.config.totalfiles)",
				"executiontime.$": "States.Format('{}', 'n/a (ms)')",
				"dataexecutionstarttime.$": "$$.Execution.StartTime",
				"dataexecutionendtime.$": "$$.State.EnteredTime",
				"statusCode.$": "$.Payload.StatusCode",
				"Cause.$": "$.config.executedFiles[0].Cause"
			}
		},
		"Wait": {
			"Type": "Wait",
			"Seconds": 5,
			"Next": "PutTokenFileToS3Bucket"
		},
		"PutTokenFileToS3Bucket": {
			"Type": "Task",
			"Next": "PassNewExecutionDateTime",
			"Parameters": {
				"Body": {
					"totalRows.$": "$.Payload.Payload.totalRows"
				},
				"Bucket.$": "$.Payload.Payload.iterations[0].bucket",
				"Key.$": "$.Payload.Payload.tokenFile",
				"Acl": "bucket-owner-full-control"
			},
			"Resource": "arn:aws:states:::aws-sdk:s3:putObject",
			"ResultPath": "$.EndTime",
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"Next": "PassExecutionErrorData"
				}
			],
			"Retry": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"BackoffRate": 2,
					"IntervalSeconds": 60,
					"MaxAttempts": 2
				}
			],
			"ResultSelector": {
				"DataExecutionEndTime.$": "$$.State.EnteredTime"
			}
		},
		"PassNewExecutionDateTime": {
			"Type": "Pass",
			"Next": "StoreNew ExecutionDateTime",
			"Parameters": {
				"lastExecutedDateTime.$": "$.lastExecutedDateTime",
				"param_name.$": "$.param_name",
				"executedOn.$": "$.Payload.Payload.executedOn",
				"filenames.$": "$.config.executedFiles[*].fileName",
				"totalfiles.$": "States.Format('{}', $.config.totalfiles)",
				"executiontime.$": "States.Format('{}', 'n/a (ms)')",
				"dataexecutionstarttime.$": "$$.Execution.StartTime",
				"dataexecutionendtime.$": "$.EndTime.DataExecutionEndTime",
				"statusCode.$": "$.Payload.StatusCode"
			}
		},
		"StoreNew ExecutionDateTime": {
			"Type": "Task",
			"Next": "ValidateStatus",
			"Parameters": {
				"Overwrite": true,
				"Type": "String",
				"Name.$": "$.param_name",
				"Value.$": "$.executedOn"
			},
			"Resource": "arn:aws:states:::aws-sdk:ssm:putParameter",
			"ResultPath": null,
			"Retry": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"BackoffRate": 2,
					"IntervalSeconds": 60,
					"MaxAttempts": 2
				}
			],
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"Next": "GetWarningSESParameters"
				}
			]
		},
		"GetWarningSESParameters": {
			"Type": "Task",
			"Next": "FormatEmailTemplate",
			"Parameters": {
				"Names": [
					"/tcm/${var.env}/companymicroservice/ses-warning-template-config"
				]
			},
			"Resource": "arn:aws:states:::aws-sdk:ssm:getParameters",
			"ResultSelector": {
				"warning_config.$": "States.StringToJson($.Parameters[0].Value)"
			},
			"ResultPath": "$.param_name"
		},
		"SendWarningNotificationEmail": {
			"Type": "Task",
			"Next": "Success",
			"Parameters": {
				"Destination.$": "$.param_name.warning_config.Destination",
				"Source.$": "$.param_name.warning_config.Source",
				"Template.$": "$.param_name.warning_config.Template",
				"TemplateData.$": "States.Format($.param_name.warning_config.TemplateData, $.FormattedData.Payload.totalfiles, $.FormattedData.Payload.filenameshtml, $.FormattedData.Payload.filenamestxt, $.FormattedData.Payload.dataexecutionstarttime, $.FormattedData.Payload.dataexecutionendtime, $.FormattedData.Payload.elapsedtime, $.executedOn, $$.Execution.Input.param_name, States.JsonToString($.Cause.errorType), States.JsonToString($.Cause.errorMessage), States.JsonToString($.Cause.stackTrace))"
			},
			"Resource": "arn:aws:states:::aws-sdk:ses:sendTemplatedEmail"
		},
		"ValidateStatus": {
			"Type": "Choice",
			"Choices": [
				{
					"Not": {
						"Variable": "$.statusCode",
						"NumericEquals": 200
					},
					"Next": "PassExecutionErrorData"
				}
			],
			"Default": "GetSuccessSESParameters"
		},
		"GetSuccessSESParameters": {
			"Type": "Task",
			"Next": "FormatEmailTemplate",
			"Parameters": {
				"Names": [
					"/tcm/${var.env}/companymicroservice/ses-success-template-config"
				]
			},
			"Resource": "arn:aws:states:::aws-sdk:ssm:getParameters",
			"ResultPath": "$.param_name",
			"ResultSelector": {
				"success_config.$": "States.StringToJson($.Parameters[0].Value)"
			}
		},
		"FormatEmailTemplate": {
			"Type": "Task",
			"Resource": "arn:aws:states:::lambda:invoke",
			"Parameters": {
				"FunctionName": "${aws_lambda_function.emailformat.arn}",
				"Payload.$": "$"
			},
			"Retry": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"IntervalSeconds": 60,
					"MaxAttempts": 2,
					"BackoffRate": 2
				}
			],
			"Next": "DetermineTemplateType",
			"ResultPath": "$.FormattedData",
			"Catch": [
				{
					"ErrorEquals": [
						"States.ALL"
					],
					"Next": "GetFailureSESParameters"
				}
			]
		},
		"DetermineTemplateType": {
			"Type": "Choice",
			"Choices": [
				{
					"Variable": "$.param_name.validation_config",
					"IsPresent": true,
					"Next": "SendValidationErrorNotificationEmail"
				},
				{
					"Variable": "$.param_name.warning_config",
					"IsPresent": true,
					"Next": "SendWarningNotificationEmail"
				}
			],
			"Default": "SendSucessNotificationEmail"
		},
		"SendSucessNotificationEmail": {
			"Type": "Task",
			"Next": "Success",
			"Parameters": {
				"Destination.$": "$.param_name.success_config.Destination",
				"Source.$": "$.param_name.success_config.Source",
				"Template.$": "$.param_name.success_config.Template",
				"TemplateData.$": "States.Format($.param_name.success_config.TemplateData, $.FormattedData.Payload.totalfiles, $.FormattedData.Payload.filenameshtml, $.FormattedData.Payload.filenamestxt, $.FormattedData.Payload.dataexecutionstarttime, $.FormattedData.Payload.dataexecutionendtime, $.FormattedData.Payload.elapsedtime)"
			},
			"Resource": "arn:aws:states:::aws-sdk:ses:sendTemplatedEmail",
			"ResultPath": "$.OriginalInput"
		},
		"Fail": {
			"Type": "Fail"
		},
		"Success": {
			"Type": "Succeed"
		}
	},
	"TimeoutSeconds": 9000
}
    EOF

  depends_on = [aws_lambda_function.count, aws_lambda_function.query]

}