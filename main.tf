module "vpc" {
  source = "./modules/vpc"
  cidr   = var.cidr
}

module "subnet1" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  route_table_id    = module.vpc.route_table_id
}

module "subnet2" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  route_table_id    = module.vpc.route_table_id
}

module "security_group" {
  source      = "./modules/security_group"
  name_prefix = "web-sg-"
  description = "SecurityGroupForTerraform"
  vpc_id      = module.vpc.vpc_id
}

module "s3_bucket" {
  source = "./modules/s3_bucket"
  bucket = "s3bucketrajcharan"
}

module "ec2_instance1" {
  source               = "./modules/ec2"
  ami                  = "ami-07d7e3e669718ab45"
  instance_type        = "t2.micro"
  security_group_ids   = [module.security_group.security_group_id]
  iam_instance_profile = "cwsmrole"
  subnet_id            = module.subnet1.subnet_id
  user_data            = "userdata.sh"
}

module "ec2_instance2" {
  source               = "./modules/ec2"
  ami                  = "ami-07d7e3e669718ab45"
  instance_type        = "t2.micro"
  security_group_ids   = [module.security_group.security_group_id]
  iam_instance_profile = "cwsmrole"
  subnet_id            = module.subnet2.subnet_id
  user_data            = "userdata1.sh"
}

module "alb" {
  source                = "./modules/alb"
  target_group_name     = "my-target-group"
  target_group_port     = 80
  target_group_protocol = "HTTP"
  health_check_path     = "/"
  health_check_port     = 80
  tags_name             = "web"
  vpc_id                = module.vpc.vpc_id
  security_group_ids    = [module.security_group.security_group_id]
  subnet_ids            = [module.subnet1.subnet_id, module.subnet2.subnet_id]
}
