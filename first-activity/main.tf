
# --- Detect your public IP if allowed_cidr not provided ---
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  caller_cidr = trim(var.allowed_cidr) != "" ? var.allowed_cidr : "${chomp(data.http.my_ip.response_body)}/32"
}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "vpc-main" })
}

# --- Private Subnet (no public IPs assigned on launch) ---
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "subnet-private" })
}

# --- Private Route Table (no route to internet) ---
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "rtb-private" })
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# --- Latest Amazon Linux 2 AMI (x86_64) ---
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- Security Group: allows HTTP/HTTPS from your IP (still private, no public reachability) ---
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP/HTTPS from caller IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from caller"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.caller_cidr]
  }

  ingress {
    description = "HTTPS from caller"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.caller_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# --- EC2 instance in PRIVATE subnet ---
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false   # private subnet = no public IP

  # optional SSH key
  key_name = var.key_name != "" ? var.key_name : null

  tags = merge(var.tags, { Name = "web-ec2-private" })
}