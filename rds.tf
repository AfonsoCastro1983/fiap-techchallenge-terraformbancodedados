provider "aws" {
  region = "us-east-2"

}
# VPC
resource "aws_vpc" "lanchoneteFIAP" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lanchoneteFIAP-vpc"
  }
}

# Subnet A
resource "aws_subnet" "subnetA" {
  vpc_id     = aws_vpc.lanchoneteFIAP.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "lanchoneteFIAP-subnetA"
  }
}

# Subnet B
resource "aws_subnet" "subnetB" {
  vpc_id     = aws_vpc.lanchoneteFIAP.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "lanchoneteFIAP-subnetB"
  }
}

# RDS Database
resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  instance_class       = "db.t3.micro"
  engine               = "postgres"
  name                 = "lanchonete"
  username             = var.db_username
  password             = var.db_password
  publicly_accessible  = true
  skip_final_snapshot  = true
  deletion_protection  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "lanchonete-rds-subnet-group"
  subnet_ids = [aws_subnet.subnetA.id, aws_subnet.subnetB.id]
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.lanchoneteFIAP.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lanchoneteFIAP-rds-sg"
  }
}
