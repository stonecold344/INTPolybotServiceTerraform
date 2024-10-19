variable "base_bucket_name" {
  description = "Base name for S3 bucket"
  type        = string
  default     = "bennyi-aws-s3-bucket"  # Default value to avoid prompts
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}

variable "yolo5_instance_type" {
  description = "EC2 instance type for Yolo5"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Yolo5"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the VPC"
  type        = list(string)
}

variable "vpc_configs" {
  description = "VPC configuration for each region"
  type        = map(object({
    name       = string
    cidr_block = string
    azs        = list(string)
  }))
}

variable "region" {
  description = "The AWS region where the resources will be created"
  type        = string
}

variable "role_name" {
  description = "The IAM role name for the EC2 instance"
  type        = string
}

variable "polybot_ami_id" {
  description = "The AMI ID for Yolo5 instance"
  type        = string
}

variable "yolo5_ami_id" {
  description = "The AMI ID for Yolo5 instance"
  type        = string
}

variable "telegram_bot_token" {
  type        = string
  description = "Telegram bot token for Polybot"
}

variable "secret_id" {
  type        = string
  description = "Telegram bot token for Polybot"
}

variable "aws_private_key" {
  description = "The private key for SSH access"
  type        = string
}

variable "certificate_arn" {
  description = "The private key for SSH access"
  type        = string
}