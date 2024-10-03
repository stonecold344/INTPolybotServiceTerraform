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

variable "yolo5_ami_id" {
  description = "The AMI ID for Yolo5 instance"
  type        = string
}

variable "bot_token" {
  description = "Telegram bot token"
  type        = string
}