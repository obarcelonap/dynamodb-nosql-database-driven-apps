resource "aws_dynamodb_table" "dragons_stats_table" {
  name         = "dragon_stats"
  hash_key     = "dragon_name"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "dragon_name"
    type = "S"
  }
}

resource "aws_dynamodb_table" "dragons_current_power_table" {
  name         = "dragon_current_power"
  hash_key     = "game_id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "game_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "dragons_bonus_attack_table" {
  name         = "dragon_bonus_attack"
  hash_key     = "breath_attack"
  range_key    = "range"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "breath_attack"
    type = "S"
  }
  attribute {
    name = "range"
    type = "N"
  }
}

resource "aws_dynamodb_table" "dragons_family_table" {
  name         = "dragon_family"
  hash_key     = "family"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "family"
    type = "S"
  }
}

resource "null_resource" "dragons_upload_tables_data" {
  depends_on = [
    aws_dynamodb_table.dragons_stats_table,
    aws_dynamodb_table.dragons_bonus_attack_table,
    aws_dynamodb_table.dragons_current_power_table,
    aws_dynamodb_table.dragons_family_table,
  ]
  provisioner "local-exec" {
    command = "npm install aws-sdk && node seed_dragons.js"
  }
}
