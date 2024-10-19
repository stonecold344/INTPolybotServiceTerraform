region = "us-east-1"

vpc_configs = {
  "us-east-1" = {
    cidr_block = "10.0.0.0/16"
    name       = "terraform-vpc-us-east-1-bennyi"
    azs        = ["us-east-1a", "us-east-1b"]
  }
}
polybot_ami_id = "ami-062cdc7aed1a19ee0"
yolo5_ami_id = "ami-012d180e09be669db"
yolo5_instance_type = "t2.medium"
telegram_bot_token = "6629220970:AAFUHIrGYAZh8RSvIAAl8HmE3q52JxwKm34"
domain_name = "aws-domain-bennyi.int-devops.click"
aws_private_key = var.aws_private_key
secret_id = var.secret_id
