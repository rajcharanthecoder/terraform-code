variable "ami" {
  description = "The AMI ID"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "The IAM instance profile"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID"
  type        = string
}

variable "user_data" {
  description = "Path to the user data script"
  type        = string
}
