# Terraform module that manages DynamoDB data migration and ongoing replication 

Based on:
- https://aws.amazon.com/blogs/database/cross-account-replication-with-amazon-dynamodb/
- https://github.com/aws-samples/cross-account-amazon-dynamodb-replication

## Pre-requisites
* Enable dynamoDB streams on the source dynamoDB table
* Create an IAM role in the target account that has full access to the target dynamoDB table. 
This role will be assumed by the glue job during the initial migration and the lambda 
during the ongoing replication.

## Post-migration
All resources should be deleted once the dynamoDB replication is no longer required. 
* Perform terraform destroy on this module (or just dereference it from your stack and 
let terraform tidy the resources up)
* Disable the source table dynamoDB stream
* Remove the role created as part of pre-req 
