output "vpc_id" {
  description = "The ID of the generated VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "The ID of the instance security group"
  value       = aws_security_group.app_sg.id
}

output "ec2_public_ip" {
  description = "The public IP address assigned to the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "s3_bucket_name" {
  description = "The globally unique name of the created S3 storage bucket"
  value       = aws_s3_bucket.storage.id
}
