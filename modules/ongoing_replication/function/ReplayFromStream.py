import os
import boto3


def lambda_handler(event, context):
    print('Replication triggered')

    # Environment Variables
    target_aws_account_num = os.environ['TARGET_AWS_ACCOUNT_NUMBER']
    target_role_arn = os.environ['TARGET_ROLE_ARN']
    target_ddb_name = os.environ['TARGET_DYNAMODB_NAME']
    target_ddb_region = os.environ['TARGET_REGION']

    print('target aws account: ' + target_aws_account_num)
    print('target region: ' + target_ddb_region)
    print('target table name: ' + target_ddb_name)
    print('target role arn: ' + target_role_arn)

    sts_response = get_credentials(target_role_arn)

    dynamodb = boto3.client('dynamodb', region_name=target_ddb_region,
                            aws_access_key_id = sts_response['AccessKeyId'],
                            aws_secret_access_key = sts_response['SecretAccessKey'],
                            aws_session_token = sts_response['SessionToken'])

    records = event['Records']

    for record in records:
        event_name = record['eventName']
        try:
            if event_name == 'REMOVE':
                dynamodb.delete_item(TableName=target_ddb_name,Key=record['dynamodb']['Keys'])
            else:
                dynamodb.put_item(TableName=target_ddb_name,Item=record['dynamodb']['NewImage'])
        except Exception as exc:
            print('ERROR', exc)
    print('finished all records')


def get_credentials(role_arn):
    # create an STS client object that represents a live connection to the
    # STS service
    sts_client = boto3.client('sts')

    # Call the assume_role method of the STSConnection object and pass the role
    # ARN and a role session name.
    assumed_role_object=sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName="cross_acct_lambda"
    )

    # From the response that contains the assumed role, get the temporary
    # credentials that can be used to make subsequent API calls
    sts_response=assumed_role_object['Credentials']
    return sts_response
