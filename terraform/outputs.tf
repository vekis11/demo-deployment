output "web_url" {
  description = "URL to access the WellSpan welcome page"
  value       = "http://${aws_instance.web.public_ip}"
}

output "public_ip" {
  description = "EC2 instance public IP address"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}
