resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "GameScores"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "GameTitle"
  // ********* enabling stream start ************ //
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  // ********* enabling stream end ************ //


  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  attribute {
    name = "TopScore"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

module "dynamodb_replication" {
  source = "../../"

  namespace                  = "test"
  source_table_name          = "GameScores"
  source_table_stream_arn    = aws_dynamodb_table.basic-dynamodb-table.stream_arn
  stage                      = "dev"
  tags                       = var.tags
  target_account             = var.target_account_number
  target_dynamodb_table_name = "GameScores"
  target_region              = "us-west-2"
  target_role_name           = var.target_account_role_name
}