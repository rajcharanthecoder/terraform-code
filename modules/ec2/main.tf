resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  subnet_id              = var.subnet_id
  user_data              = var.user_data
}

output "instance_id" {
  value = aws_instance.this.id
}
