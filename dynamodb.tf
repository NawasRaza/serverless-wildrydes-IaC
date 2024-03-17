resource "aws_dynamodb_table" "Rides" {
  name           = "Rides"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  point_in_time_recovery {
    enabled = false
  }

  server_side_encryption {
    enabled = true
  }

  hash_key       = "RideId"

  attribute {
    name = "RideId"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}