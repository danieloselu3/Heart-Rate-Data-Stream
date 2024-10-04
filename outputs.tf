output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.data_pipeline_ec2.public_ip
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.data_pipeline_ec2.id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.data_pipeline_db.endpoint
}

output "s3_bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.data_pipeline_bucket.id
}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.data_pipeline_sg.id
}

output "iam_role_arn" {
  description = "The ARN of the created IAM role"
  value       = aws_iam_role.data_pipeline_role.arn
}
