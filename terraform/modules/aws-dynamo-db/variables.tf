variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "musicTable"
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PROVISIONED"
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity"
  type        = number
  default     = 1
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity"
  type        = number
  default     = 1
}

variable "dynamodb_hash_key" {
  description = "DynamoDB hash key"
  type        = string
  default     = "artist"
}

variable "dynamodb_attribute_name" {
  description = "DynamoDB attribute name"
  type        = string
  default     = "artist"
}

variable "dynamodb_attribute_type" {
  description = "DynamoDB attribute type"
  type        = string
  default     = "S"
}
