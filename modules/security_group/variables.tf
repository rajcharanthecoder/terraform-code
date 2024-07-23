variable "name_prefix" {
  description = "The name prefix of the security group"
  type        = string
}

variable "description" {
  description = "The description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}
