variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 Key pair"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for YOLOv5"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM Certificate for ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the Polybot service will be deployed"
  type        = string
}
