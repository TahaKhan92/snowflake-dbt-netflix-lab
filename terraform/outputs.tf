output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.project_ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.project_ec2.public_dns
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.project_bucket.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.project_bucket.arn
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_instance.project_ec2.public_ip}"
}