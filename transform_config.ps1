Function XMLConfigTransform
{
    param(
    [string] $File_To_Set,
    [hashtable] $Variables_To_Set
    )

    If ($File_To_Set -ieq $null)
    {
        throw "Err. File Not Found - $File_To_Set";
    }

    ForEach ($Pair in $Variables_To_Set.GetEnumerator())
    {
        Write-Host "Setting" $Pair.Key "on $File_To_Set`n"
        (Get-Content $File_To_Set).replace($Pair.Key, $Pair.Value) | Set-Content $File_To_Set
    }
}

#Setting Target Environment & Preparing list of Files to Transform
$Build_Environment = (${env:System_PullRequest_TargetBranch}.Split("/"))[-1]

Write-Host "Targeting Environment: $Build_Environment"

$Files = Get-ChildItem -Path ${env:Build_SourcesDirectory}\deployment\* -Include 'workspace_variables.txt',"appsettings.json" -Recurse -ErrorAction SilentlyContinue

#Gathering Environment Values
#Generating Temporary Credentials & Assuming Appropriate Role

If ($Build_Environment -ieq "dev")
{
    $Account_ARN_REPO = "xxx"
    $STS_CREDS_REPO = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN_REPO`:role/project-shared-repo-deployment-role" -RoleSessionName "ldi-$Build_Environment-repo-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials

    $Account_ARN = "yyy"
    $STS_CREDS = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role" -RoleSessionName "lii-$Build_Environment-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials
  

    $TF_Org = (Get-SECSecretValue -SecretID "/shared/tf_org/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $TF_Team = (Get-SECSecretValue -SecretID "/shared/tf_team/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $Shared_ADO_Conn = (Get-SECSecretValue -SecretID "shared/ado_service_connection" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json

    $TF_Org_Key = $TF_Org.key
    $TF_Team_Key = $TF_Team.key

    Write-Host ("##vso[task.setvariable variable=TF_Org;isOutput=true;isSecret=true]$TF_Org_Key")
    Write-Host ("##vso[task.setvariable variable=TF_Team;isOutput=true;isSecret=true]$TF_Team_Key")
    Write-Host ("##vso[task.setvariable variable=Build_Environment;isOutput=true;isSecret=true]$Build_Environment")

    $ECR_Endpoint = "$Account_ARN.dkr.ecr.us-east-1.amazonaws.com"
    $Target_Repository = (Get-SSMParameterValue -Name "/dev/project/ecr/name" -Credential $STS_CREDS).Parameters.Value
    $VPCID = (Get-SSMParameterValue -Name "/vpc/dev/id" -Credential $STS_CREDS).Parameters.Value
    $VPCE = (Get-SSMParameterValue -Name "/ldi/dev/apig/vpce" -Credential $STS_CREDS).Parameters.Value
    $Data1 = (Get-SSMParameterValue -Name "/vpc/dev/subnet/datasubnet1/id" -Credential $STS_CREDS).Parameters.Value
    $Data2 = (Get-SSMParameterValue -Name "/vpc/dev/subnet/datasubnet2/id" -Credential $STS_CREDS).Parameters.Value
    
    $Image = "$ECR_Endpoint/$Target_Repository`:project-process--$Build_Environment-${env:Build_BuildID}"
    Write-Host $Image

    Write-Host ("##vso[task.setvariable variable=ECR_Endpoint;isOutput=true]$ECR_Endpoint")
    Write-Host ("##vso[task.setvariable variable=Target_Repository;isOutput=true]$Target_Repository")
    Write-Host ("##vso[task.setvariable variable=BuildEnvironment;isOutput=true]$Build_Environment")

    $AccessKeyExport = $STS_CREDS.AccessKeyId
    $SecretAccessKeyExport = $STS_CREDS.SecretAccessKey
    $SessionTokenExport = $STS_CREDS.SessionToken
    
    Write-Host ("##vso[task.setvariable variable=AccessKey;isOutput=true;issecret=true]$AccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SecretKey;isOutput=true;issecret=true]$SecretAccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SessionToken;isOutput=true;issecret=true]$SessionTokenExport")

    $Env_Var = @{}
    $Env_Var.Add("{aws_region}", "us-east-1")
    $Env_Var.Add("{environment}", $Build_Environment)
    $Env_Var.Add("{aws_access_key}", $Shared_ADO_Conn.AccessKeyID)
    $Env_Var.Add("{aws_secret_key}", $Shared_ADO_Conn.SecretAccessKey)
    $Env_Var.Add("{aws_role_arn}", "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role")
    $Env_Var.Add("{vpcid}", $VPCID)
    $Env_Var.Add("{vpce}", $VPCE)
    $Env_Var.Add("{Data1}", $Data1)
    $Env_Var.Add("{Data2}", $Data2)
    $Env_Var.Add("{bucket_id}", $S3Bucket)
    $Env_Var.Add("{Image}", $Image)
}

If ($Build_Environment -ieq "qa")
{
    $Account_ARN_REPO = "xxx"
    $STS_CREDS_REPO = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN_REPO`:role/project-shared-repo-deployment-role" -RoleSessionName "ldi-$Build_Environment-repo-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials

    $Account_ARN = "yyy"
    $STS_CREDS = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role" -RoleSessionName "lii-$Build_Environment-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials
  

    $TF_Org = (Get-SECSecretValue -SecretID "/shared/tf_org/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $TF_Team = (Get-SECSecretValue -SecretID "/shared/tf_team/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $Shared_ADO_Conn = (Get-SECSecretValue -SecretID "shared/ado_service_connection" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json

    $TF_Org_Key = $TF_Org.key
    $TF_Team_Key = $TF_Team.key

    Write-Host ("##vso[task.setvariable variable=TF_Org;isOutput=true;isSecret=true]$TF_Org_Key")
    Write-Host ("##vso[task.setvariable variable=TF_Team;isOutput=true;isSecret=true]$TF_Team_Key")
    Write-Host ("##vso[task.setvariable variable=Build_Environment;isOutput=true;isSecret=true]$Build_Environment")

    $ECR_Endpoint = "$Account_ARN.dkr.ecr.us-east-1.amazonaws.com"
    $Target_Repository = (Get-SSMParameterValue -Name "/qa/project/ecr/name" -Credential $STS_CREDS).Parameters.Value
    $VPCID = (Get-SSMParameterValue -Name "/vpc/qa/id" -Credential $STS_CREDS).Parameters.Value
    $VPCE = (Get-SSMParameterValue -Name "/ldi/dev/apig/vpce" -Credential $STS_CREDS).Parameters.Value
    $Data1 = (Get-SSMParameterValue -Name "/vpc/qa/subnet/datasubnet1/id" -Credential $STS_CREDS).Parameters.Value
    $Data2 = (Get-SSMParameterValue -Name "/vpc/qa/subnet/datasubnet2/id" -Credential $STS_CREDS).Parameters.Value
    
    $Image = "$ECR_Endpoint/$Target_Repository`:project-process--$Build_Environment-${env:Build_BuildID}"
    Write-Host $Image

    Write-Host ("##vso[task.setvariable variable=ECR_Endpoint;isOutput=true]$ECR_Endpoint")
    Write-Host ("##vso[task.setvariable variable=Target_Repository;isOutput=true]$Target_Repository")
    Write-Host ("##vso[task.setvariable variable=BuildEnvironment;isOutput=true]$Build_Environment")

    $AccessKeyExport = $STS_CREDS.AccessKeyId
    $SecretAccessKeyExport = $STS_CREDS.SecretAccessKey
    $SessionTokenExport = $STS_CREDS.SessionToken
    
    Write-Host ("##vso[task.setvariable variable=AccessKey;isOutput=true;issecret=true]$AccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SecretKey;isOutput=true;issecret=true]$SecretAccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SessionToken;isOutput=true;issecret=true]$SessionTokenExport")

    $Env_Var = @{}
    $Env_Var.Add("{aws_region}", "us-east-1")
    $Env_Var.Add("{environment}", $Build_Environment)
    $Env_Var.Add("{aws_access_key}", $Shared_ADO_Conn.AccessKeyID)
    $Env_Var.Add("{aws_secret_key}", $Shared_ADO_Conn.SecretAccessKey)
    $Env_Var.Add("{aws_role_arn}", "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role")
    $Env_Var.Add("{vpcid}", $VPCID)
    $Env_Var.Add("{vpce}", $VPCE)
    $Env_Var.Add("{Data1}", $Data1)
    $Env_Var.Add("{Data2}", $Data2)
    $Env_Var.Add("{bucket_id}", $S3Bucket)
    $Env_Var.Add("{Image}", $Image)
}

If ($Build_Environment -ieq "uat")
{
    $Account_ARN_REPO = "xxx"
    $STS_CREDS_REPO = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN_REPO`:role/project-shared-repo-deployment-role" -RoleSessionName "ldi-$Build_Environment-repo-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials

    $Account_ARN = "711237182968"
    $STS_CREDS = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role" -RoleSessionName "lii-$Build_Environment-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials
  

    $TF_Org = (Get-SECSecretValue -SecretID "/shared/tf_org/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $TF_Team = (Get-SECSecretValue -SecretID "/shared/tf_team/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $Shared_ADO_Conn = (Get-SECSecretValue -SecretID "shared/ado_service_connection" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json

    $TF_Org_Key = $TF_Org.key
    $TF_Team_Key = $TF_Team.key

    Write-Host ("##vso[task.setvariable variable=TF_Org;isOutput=true;isSecret=true]$TF_Org_Key")
    Write-Host ("##vso[task.setvariable variable=TF_Team;isOutput=true;isSecret=true]$TF_Team_Key")
    Write-Host ("##vso[task.setvariable variable=Build_Environment;isOutput=true;isSecret=true]$Build_Environment")

    $ECR_Endpoint = "$Account_ARN.dkr.ecr.us-east-1.amazonaws.com"
    $Target_Repository = (Get-SSMParameterValue -Name "/uat/project/ecr/name" -Credential $STS_CREDS).Parameters.Value
    $VPCID = (Get-SSMParameterValue -Name "/vpc/uat/id" -Credential $STS_CREDS).Parameters.Value
    $VPCE = (Get-SSMParameterValue -Name "/ldi/dev/apig/vpce" -Credential $STS_CREDS).Parameters.Value
    $Data1 = (Get-SSMParameterValue -Name "/vpc/uat/subnet/datasubnet1/id" -Credential $STS_CREDS).Parameters.Value
    $Data2 = (Get-SSMParameterValue -Name "/vpc/uat/subnet/datasubnet2/id" -Credential $STS_CREDS).Parameters.Value
    
    $Image = "$ECR_Endpoint/$Target_Repository`:project-process--$Build_Environment-${env:Build_BuildID}"
    Write-Host $Image

    Write-Host ("##vso[task.setvariable variable=ECR_Endpoint;isOutput=true]$ECR_Endpoint")
    Write-Host ("##vso[task.setvariable variable=Target_Repository;isOutput=true]$Target_Repository")
    Write-Host ("##vso[task.setvariable variable=BuildEnvironment;isOutput=true]$Build_Environment")

    $AccessKeyExport = $STS_CREDS.AccessKeyId
    $SecretAccessKeyExport = $STS_CREDS.SecretAccessKey
    $SessionTokenExport = $STS_CREDS.SessionToken
    
    Write-Host ("##vso[task.setvariable variable=AccessKey;isOutput=true;issecret=true]$AccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SecretKey;isOutput=true;issecret=true]$SecretAccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SessionToken;isOutput=true;issecret=true]$SessionTokenExport")

    $Env_Var = @{}
    $Env_Var.Add("{aws_region}", "us-east-1")
    $Env_Var.Add("{environment}", $Build_Environment)
    $Env_Var.Add("{aws_access_key}", $Shared_ADO_Conn.AccessKeyID)
    $Env_Var.Add("{aws_secret_key}", $Shared_ADO_Conn.SecretAccessKey)
    $Env_Var.Add("{aws_role_arn}", "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role")
    $Env_Var.Add("{vpcid}", $VPCID)
    $Env_Var.Add("{vpce}", $VPCE)
    $Env_Var.Add("{Data1}", $Data1)
    $Env_Var.Add("{Data2}", $Data2)
    $Env_Var.Add("{bucket_id}", $S3Bucket)
    $Env_Var.Add("{Image}", $Image)
}

If ($Build_Environment -ieq "prod")
{
    $Account_ARN_REPO = "xxx"
    $STS_CREDS_REPO = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN_REPO`:role/project-shared-repo-deployment-role" -RoleSessionName "ldi-$Build_Environment-repo-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials

    $Account_ARN = "711237182968"
    $STS_CREDS = (Use-STSRole -RoleArn "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role" -RoleSessionName "lii-$Build_Environment-role" -AccessKey ${env:AccessKey} -SecretKey ${env:SecretKey}).Credentials
  

    $TF_Org = (Get-SECSecretValue -SecretID "/shared/tf_org/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $TF_Team = (Get-SECSecretValue -SecretID "/shared/tf_team/api" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json
    $Shared_ADO_Conn = (Get-SECSecretValue -SecretID "shared/ado_service_connection" -Credential $STS_CREDS_REPO).SecretString | ConvertFrom-Json

    $TF_Org_Key = $TF_Org.key
    $TF_Team_Key = $TF_Team.key

    Write-Host ("##vso[task.setvariable variable=TF_Org;isOutput=true;isSecret=true]$TF_Org_Key")
    Write-Host ("##vso[task.setvariable variable=TF_Team;isOutput=true;isSecret=true]$TF_Team_Key")
    Write-Host ("##vso[task.setvariable variable=Build_Environment;isOutput=true;isSecret=true]$Build_Environment")

    $ECR_Endpoint = "$Account_ARN.dkr.ecr.us-east-1.amazonaws.com"
    $Target_Repository = (Get-SSMParameterValue -Name "/uat/project/ecr/name" -Credential $STS_CREDS).Parameters.Value
    $VPCID = (Get-SSMParameterValue -Name "/vpc/uat/id" -Credential $STS_CREDS).Parameters.Value
    $VPCE = (Get-SSMParameterValue -Name "/ldi/dev/apig/vpce" -Credential $STS_CREDS).Parameters.Value
    $Data1 = (Get-SSMParameterValue -Name "/vpc/uat/subnet/datasubnet1/id" -Credential $STS_CREDS).Parameters.Value
    $Data2 = (Get-SSMParameterValue -Name "/vpc/uat/subnet/datasubnet2/id" -Credential $STS_CREDS).Parameters.Value
    
    $Image = "$ECR_Endpoint/$Target_Repository`:project-process--$Build_Environment-${env:Build_BuildID}"
    Write-Host $Image

    Write-Host ("##vso[task.setvariable variable=ECR_Endpoint;isOutput=true]$ECR_Endpoint")
    Write-Host ("##vso[task.setvariable variable=Target_Repository;isOutput=true]$Target_Repository")
    Write-Host ("##vso[task.setvariable variable=BuildEnvironment;isOutput=true]$Build_Environment")

    $AccessKeyExport = $STS_CREDS.AccessKeyId
    $SecretAccessKeyExport = $STS_CREDS.SecretAccessKey
    $SessionTokenExport = $STS_CREDS.SessionToken
    
    Write-Host ("##vso[task.setvariable variable=AccessKey;isOutput=true;issecret=true]$AccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SecretKey;isOutput=true;issecret=true]$SecretAccessKeyExport")
    Write-Host ("##vso[task.setvariable variable=SessionToken;isOutput=true;issecret=true]$SessionTokenExport")

    $Env_Var = @{}
    $Env_Var.Add("{aws_region}", "us-east-1")
    $Env_Var.Add("{environment}", $Build_Environment)
    $Env_Var.Add("{aws_access_key}", $Shared_ADO_Conn.AccessKeyID)
    $Env_Var.Add("{aws_secret_key}", $Shared_ADO_Conn.SecretAccessKey)
    $Env_Var.Add("{aws_role_arn}", "arn:aws:iam::$Account_ARN`:role/project-shared-repo-deployment-role")
    $Env_Var.Add("{vpcid}", $VPCID)
    $Env_Var.Add("{vpce}", $VPCE)
    $Env_Var.Add("{Data1}", $Data1)
    $Env_Var.Add("{Data2}", $Data2)
    $Env_Var.Add("{bucket_id}", $S3Bucket)
    $Env_Var.Add("{Image}", $Image)
}

$Replace_Dict = $Env_Var

$Env_Var.Keys.Clone() | ForEach-Object {
    $Replace = $Env_Var[$_]

    If ($Replace -Match "\<")
    {
        $Replace = $Replace -Replace "<", "&lt;"
    }

    If ($Replace -Match "\>")
    {
        $Replace = $Replace -Replace ">", "&gt;"
    }

    If ($Replace -Match "\&")
    {
        $Replace = $Replace -Replace "&", "&amp;"
    }

    If ($Replace -ine $Env_Var[$_])
    {
        $Replace_Dict[$_] = $Replace 
    }
}
$Env_Var = $Replace_Dict

ForEach ($File in $Files.FullName)
{
    XMLConfigTransform -File_To_Set $File -Variables_To_Set $Env_Var
}

$Base_Path = ".\deployment\base_config"
$Items_To_Stage = Get-ChildItem -Path $Base_Path -Filter appsettings.json -Recurse -File -Name

ForEach ($Item in $Items_To_Stage)
{
    $Target = $Item.Split("\")[0]
    Write-Host $Item
    Copy-Item "$Base_Path\$Item" -Destination ".\$Target" -Force
}