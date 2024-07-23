#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Enable debugging
set -x

echo "Starting Terraform setup..."

# Define directories
BASE_DIR="/home/ec2-user/ownmodule"
MODULES_DIR="$BASE_DIR/modules"
VPC_MODULE_DIR="$MODULES_DIR/vpc"
SUBNET_MODULE_DIR="$MODULES_DIR/subnet"
SECURITY_GROUP_MODULE_DIR="$MODULES_DIR/security_group"
S3_BUCKET_MODULE_DIR="$MODULES_DIR/s3_bucket"
EC2_MODULE_DIR="$MODULES_DIR/ec2"
ALB_MODULE_DIR="$MODULES_DIR/alb"
USER_DATA_DIR="$BASE_DIR/user_data"

# Create necessary directories
echo "Creating directories..."
mkdir -p $VPC_MODULE_DIR $SUBNET_MODULE_DIR $SECURITY_GROUP_MODULE_DIR $S3_BUCKET_MODULE_DIR $EC2_MODULE_DIR $ALB_MODULE_DIR $USER_DATA_DIR
echo "Directories created."

# Verify directory creation
echo "Current directory structure:"
ls -R $BASE_DIR

# Create user_data scripts
echo "Creating user_data scripts..."
cat <<EOT > $USER_DATA_DIR/userdata.sh
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello, World from \$(hostname -f)" > /var/www/html/index.html
EOT

cat <<EOT > $USER_DATA_DIR/userdata1.sh
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello, World from \$(hostname -f)" > /var/www/html/index.html
EOT
echo "user_data scripts created."

# Verify user_data files
echo "Contents of $USER_DATA_DIR:"
ls -l $USER_DATA_DIR

# Create main.tf for vpc module
echo "Creating VPC module files..."
cat <<EOT > $VPC_MODULE_DIR/main.tf
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "route_table_id" {
  value = aws_route_table.RT.id
}
EOT

# Create variables.tf for vpc module
cat <<EOT > $VPC_MODULE_DIR/variables.tf
variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
EOT

echo "VPC module files created."

# Verify VPC module files
echo "Contents of $VPC_MODULE_DIR:"
ls -l $VPC_MODULE_DIR

# Create main.tf for subnet module
echo "Creating Subnet module files..."
cat <<EOT > $SUBNET_MODULE_DIR/main.tf
resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.this.id
  route_table_id = var.route_table_id
}

output "subnet_id" {
  value = aws_subnet.this.id
}
EOT

# Create variables.tf for subnet module
cat <<EOT > $SUBNET_MODULE_DIR/variables.tf
variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
}

variable "route_table_id" {
  description = "The route table ID"
  type        = string
}
EOT

echo "Subnet module files created."

# Verify Subnet module files
echo "Contents of $SUBNET_MODULE_DIR:"
ls -l $SUBNET_MODULE_DIR

# Create main.tf for security group module
echo "Creating Security Group module files..."
cat <<EOT > $SECURITY_GROUP_MODULE_DIR/main.tf
resource "aws_security_group" "this" {
  name_prefix = var.name_prefix
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SecurityGroupForTerraform"
  }
}

output "security_group_id" {
  value = aws_security_group.this.id
}
EOT

# Create variables.tf for security group module
cat <<EOT > $SECURITY_GROUP_MODULE_DIR/variables.tf
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
EOT

echo "Security Group module files created."

# Verify Security Group module files
echo "Contents of $SECURITY_GROUP_MODULE_DIR:"
ls -l $SECURITY_GROUP_MODULE_DIR

# Create main.tf for s3 bucket module
echo "Creating S3 Bucket module files..."
cat <<EOT > $S3_BUCKET_MODULE_DIR/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}
EOT

# Create variables.tf for s3 bucket module
cat <<EOT > $S3_BUCKET_MODULE_DIR/variables.tf
variable "bucket" {
  description = "The name of the S3 bucket"
  type        = string
}
EOT

echo "S3 Bucket module files created."

# Verify S3 Bucket module files
echo "Contents of $S3_BUCKET_MODULE_DIR:"
ls -l $S3_BUCKET_MODULE_DIR

# Create main.tf for ec2 instance module
echo "Creating EC2 Instance module files..."
cat <<EOT > $EC2_MODULE_DIR/main.tf
resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  subnet_id              = var.subnet_id
  user_data              = base64encode(file(var.user_data))
}

output "instance_id" {
  value = aws_instance.this.id
}
EOT

# Create variables.tf for ec2 instance module
cat <<EOT > $EC2_MODULE_DIR/variables.tf
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
EOT

echo "EC2 Instance module files created."

# Verify EC2 Instance module files
echo "Contents of $EC2_MODULE_DIR:"
ls -l $EC2_MODULE_DIR

# Create main.tf for alb module
echo "Creating ALB module files..."
cat <<EOT > $ALB_MODULE_DIR/main.tf
resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
    Name = var.tags_name
  }
}

resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    path = var.health_check_path
    port = var.health_check_port
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}

output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
EOT

# Create variables.tf for alb module
cat <<EOT > $ALB_MODULE_DIR/variables.tf
variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "security_groups" {
  description = "The security groups associated with the load balancer"
  type        = list(string)
}

variable "subnets" {
  description = "The subnets to attach to the load balancer"
  type        = list(string)
}

variable "tags_name" {
  description = "Tag name for the load balancer"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port of the target group"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol of the target group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "health_check_path" {
  description = "Path for the health check"
  type        = string
}

variable "health_check_port" {
  description = "Port for the health check"
  type        = number
}

variable "listener_port" {
  description = "Port for the listener"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol for the listener"
  type        = string
}
EOT

echo "ALB module files created."

# Verify ALB module files
echo "Contents of $ALB_MODULE_DIR:"
ls -l $ALB_MODULE_DIR

# Initialize Terraform
echo "Initializing Terraform..."
cd $BASE_DIR

