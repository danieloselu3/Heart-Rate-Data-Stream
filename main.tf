# Provider configuration
provider "aws" {
  region = var.region
}

# Security Group
resource "aws_security_group" "data_pipeline_sg" {
  name        = "data-pipeline-sg"
  description = "Security group for data pipeline"
  vpc_id      = var.vpc_id

  # PostgreSQL from anywhere (consider restricting this in production)
  ingress {
    description = "PostgreSQL from anywhere"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from your IP
  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.your_ip}/32"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DataPipelineSecurityGroup"
  }
}

# EC2 Instance
resource "aws_instance" "data_pipeline_ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  vpc_security_group_ids = [aws_security_group.data_pipeline_sg.id]

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = "gp2"
  }

  tags = {
    Name = "DataPipelineEC2"
  }

  iam_instance_profile = aws_iam_instance_profile.data_pipeline_profile.name
}

# RDS Instance
resource "aws_db_instance" "data_pipeline_db" {
  identifier           = "data-pipeline-db"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage
  storage_type         = "gp2"
  username             = var.db_username
  password             = var.db_password
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.data_pipeline_sg.id]

  tags = {
    Name = "DataPipelineDB"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "data_pipeline_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "DataPipelineBucket"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "data_pipeline_bucket_public_access_block" {
  bucket = aws_s3_bucket.data_pipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role
resource "aws_iam_role" "data_pipeline_role" {
  name = "data-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      }
    ]
  })
}

# IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.data_pipeline_role.name
}

resource "aws_iam_role_policy_attachment" "rds_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.data_pipeline_role.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "data_pipeline_profile" {
  name = "data-pipeline-profile"
  role = aws_iam_role.data_pipeline_role.name
}