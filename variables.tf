variable "region" {
  description = "AWS region sydney"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_type" {
  type        = string
  description = "Linux AMI ID"
  default     = "ami-0249e9b9816d90e03"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-05596861f4ecffdeb"
  description = "main"
}

variable "public_subnet1" {
  type        = string
  default     = "subnet-09c8dbaa942884f5d"
  description = "public subnet 1"
}

variable "public_subnet2" {
  type        = string
  default     = "subnet-02f95b7899e8bed30"
  description = "public subnet 2"
}

variable "private_subnet1" {
  type        = string
  default     = "subnet-0ee426ba08e9643d9"
  description = "private subnet 1"
}
