import os
import boto3
from datetime import datetime

def lambda_handler(event, context):
    # Environment Variables
    replication_function_name = os.environ['ONGOING_REPLICATION_FUNCTION_NAME']
    ssm_event_source_mapping_uuid = os.environ['SSM_EVENT_SOURCE_MAPPING_UUID']
    ssm_workflow_status = os.environ['SSM_WORKFLOW_STATUS']

    ssm_param_started_date = ssm_workflow_status.replace('workflow_status', 'started_date')

    # This function is performing one of the following actions:
    # get workflow status (SSM param)
    # update workflow status (SSM param)
    # enable ongoing replication (lambda)

    action = event['parameters']['action']

    ssm_client = boto3.client('ssm')

    if action == 'enable_ongoing_replication':
        started_date = ssm_client.get_parameter(
            Name=ssm_param_started_date,
            WithDecryption=False
        )

        max_age = (datetime.strptime(started_date['Parameter']['Value'], '%Y-%m-%d %H:%M:%S.%f') - datetime.now())\
            .total_seconds()

        enable_ongoing_replication(ssm_event_source_mapping_uuid,
                                   replication_function_name, max_age)
    else:
        if action == 'get_workflow_status':
            workflow_status = ssm_client.get_parameter(
                Name=ssm_workflow_status,
                WithDecryption=False
            )
            ws_value = workflow_status['Parameter']['Value']
            if ws_value == 'enabled':
                ssm_client.put_parameter(
                    Name=ssm_param_started_date,
                    Value=datetime.now(),
                    Overwrite=True,
                    Type='String'
                )
            return {
                'workflow_status': ws_value
            }
        else:
            if action == 'update_workflow_status':
                value = event['parameters']['value']
                ssm_client.put_parameter(
                    Name=ssm_workflow_status,
                    Value=value,
                    Overwrite=True,
                    Type='String'
                )
            else:
                return {
                    'status': 'unknown_action'
                }


def enable_ongoing_replication(ssm_client, ssm_event_source_mapping_uuid, replication_function_name, max_age):
    uuid = ssm_client.get_parameter(
        Name=ssm_event_source_mapping_uuid,
        WithDecryption=False
    )

    lambda_client = boto3.client('lambda')
    lambda_client.update_event_source_mapping(
        Enabled=True,
        MaximumRecordAgeInSeconds=max_age,
        FunctionName=replication_function_name,
        UUID=uuid['Parameter']['Value']
    )
