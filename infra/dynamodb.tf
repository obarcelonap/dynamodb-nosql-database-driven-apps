resource "aws_dynamodb_table" "dragons_table" {
  name         = "dragons"
  hash_key     = "dragon_name"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "dragon_name"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "dragon_1" {
  table_name = aws_dynamodb_table.dragons_table.name
  hash_key   = aws_dynamodb_table.dragons_table.hash_key

  item = <<ITEM
{
  "dragon_name": { "S": "sparky" },
  "dragon_type": { "S": "green" },
  "description": { "S": "breaths acid" },
  "attack": { "N": "10" },
  "defense": { "N": "7"}
}
ITEM
}

resource "aws_dynamodb_table_item" "dragon_2" {
  table_name = aws_dynamodb_table.dragons_table.name
  hash_key   = aws_dynamodb_table.dragons_table.hash_key

  item = <<ITEM
{
  "dragon_name": { "S": "tallie" },
  "dragon_type": { "S": "red" },
  "description": { "S": "breaths fire" },
  "attack": { "N": "7" },
  "defense": { "N": "10" }
}
ITEM
}
