
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name (optional). Leave empty to use env credentials."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH (optional)."
  type        = string
  default     = ""
}

variable "allowed_cidr" {
  description = "CIDR allowed to access ports 80/443. If empty, will use your current public IP /32."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "AZ for the private subnet (must exist in the region)"
  type        = string
  default     = "ap-southeast-1a"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project = "tf-ec2-sg-private-subnet"
  }
}