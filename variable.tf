variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
variable "user_data" {
  description = "Path to the user data file"
  type        = string
  default     = "user_data/userdata.sh"
}
