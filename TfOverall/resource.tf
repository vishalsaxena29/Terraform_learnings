resource "aws_instance" "My-Ubuntu-Instance" {
  ami           = "ami-07ffb2f4d65357b42"
  instance_type = "t2.micro"
  key_name = "NewKeypair"
  user_data     = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install nginx -y
  echo "Hi I am Vishal Saxena" >/var/www/html/index.nginx-debian.html
  EOF
}

#VPC resource configuration
resource "aws_vpc" "MyVpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MyVpc"
  }
}

#Subnet for VPC
resource "aws_subnet" "MySubnet" {
  vpc_id     = aws_vpc.MyVpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "MySubnet"
  }
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "MyIgw" {
  vpc_id = aws_vpc.MyVpc.id

  tags = {
    Name = "MyIgw"
  }
}

#Elastic Ip for VPC
resource "aws_eip" "MyElasticIplb" {
  instance = aws_instance.My-Ubuntu-Instance.id
  vpc      = true
}

#Private NAT Gateway for VPC
resource "aws_nat_gateway" "MyPrivateNatGateway" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.MySubnet.id
}
resource "aws_egress_only_internet_gateway" "MyInternetGateway_engress" {
  vpc_id = aws_vpc.MyVpc.id

  tags = {
    Name = "MyInternetGateway_engress"
  }
}

#Route Table for VPC
resource "aws_route_table" "MyRouteTable" {
  vpc_id = aws_vpc.MyVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIgw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.MyInternetGateway_engress.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.MyVpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.MyVpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_s3_bucket" "mybuckettf-vishal" {
  bucket = "mybuckettf-vishal29"
  tags = {
    Name        = "mybuckettf-vishal"
    Environment = "Dev"
  }
}

