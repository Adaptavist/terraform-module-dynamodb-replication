import boto3
import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ['JOB_ENABLED', 'TARGET_DYNAMODB_NAME', 'SOURCE_DYNAMODB_NAME',
                                     'SOURCE_DYNAMODB_REGION', 'TARGET_AWS_ACCOUNT_NUMBER', 'TARGET_ROLE_NAME',
                                     'TARGET_REGION', 'WORKER_TYPE', 'NUM_WORKERS'])

job_enabled = args['JOB_ENABLED']
if job_enabled == 'True':

    print('### Starting the initial load')

    target_aws_account_num = args['TARGET_AWS_ACCOUNT_NUMBER']
    target_role_name = args['TARGET_ROLE_NAME']
    target_ddb_name = args['TARGET_DYNAMODB_NAME']
    region = args['TARGET_REGION']
    source_ddb_name = args['SOURCE_DYNAMODB_NAME']
    source_ddb_region = args['SOURCE_DYNAMODB_REGION']
    worker_type = args['WORKER_TYPE']
    num_workers = args['NUM_WORKERS']

    target_role_arn = "arn:aws:iam::" + target_aws_account_num + ":role/" + target_role_name

    if worker_type == 'G.2X':
        ddb_split = 16 * (int(num_workers) - 1)

    elif worker_type == 'G.1X':
        ddb_split = 8 * (int(num_workers) - 1)
    else:
        num_executers = (int(num_workers) - 1) * 2 - 1
        ddb_split = 4 * num_executers

    print('target aws account: ' + target_aws_account_num)
    print('target region: ' + region)
    print('target table name: ' + target_ddb_name)
    print('target role arn: ' + target_role_arn)
    print('source region: ' + source_ddb_region)
    print('source table name: ' + source_ddb_name)
    print('worker type: ' + worker_type)
    print('number of workers: ' + num_workers)
    print('ddb split: ' + str(ddb_split))

    args = getResolvedOptions(sys.argv, ["JOB_NAME"])
    glue_context = GlueContext(SparkContext.getOrCreate())
    job = Job(glue_context)
    job.init(args["JOB_NAME"], args)

    print('Glue job initialised')

    dyf = glue_context.create_dynamic_frame_from_options(
        connection_type="dynamodb",
        connection_options={
            "dynamodb.region": source_ddb_region,
            "dynamodb.splits": str(ddb_split),
            "dynamodb.throughput.read.percent": "1.2",
            "dynamodb.input.tableName": source_ddb_name
        }
    )
    dyf.show()

    glue_context.write_dynamic_frame_from_options(
        frame=dyf,
        connection_type="dynamodb",
        connection_options={
            "dynamodb.region": region,
            "dynamodb.output.tableName": target_ddb_name,
            "dynamodb.sts.roleArn": target_role_arn
        }
    )
    job.commit()
    print('Glue job committed')
