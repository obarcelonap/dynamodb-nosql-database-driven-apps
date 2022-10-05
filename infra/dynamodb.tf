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

resource "aws_dynamodb_table" "users_table" {
  name         = "users"
  hash_key     = "user_name"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "user_name"
    type = "S"
  }

  attribute {
    name = "email_address"
    type = "S"
  }

  global_secondary_index {
    name               = "email_index"
    hash_key           = "email_address"
    projection_type    = "INCLUDE"
    non_key_attributes = ["password"]
  }
}

resource "aws_dynamodb_table" "sessions_table" {
  name         = "sessions"
  hash_key     = "session_id"
  range_key    = "user_name"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "user_name"
    type = "S"
  }

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }
}

resource "null_resource" "users_upload_data" {
  depends_on = [aws_dynamodb_table.users_table]
  provisioner "local-exec" {
    command = "npm install aws-sdk bcrypt && node upload_and_hash_passwords.js"
  }
}
