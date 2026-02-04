output "ec2_ip" {
  description = " ip of EC2 instance"
  value       = aws_instance.web.private_ip
}