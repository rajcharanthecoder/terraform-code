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
