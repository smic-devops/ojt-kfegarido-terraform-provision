variable "region" {
  description = "AWS region sydney"
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_type" {
  type        = string
  description = "Ubuntu AMI ID"
  default     = "ami-0c55b15978a20471d"
}