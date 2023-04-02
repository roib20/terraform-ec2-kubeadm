output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_elastic_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = aws_eip.web.public_ip
}
