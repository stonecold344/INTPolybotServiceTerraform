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
secret_id = "Telegram-Secret-Bennyi100"
aws_private_key = ""
certificate_arn   = "arn:aws:acm:us-east-1:019273956931:certificate/dca2fff4-09a6-4abc-81d6-4a1c7df5f9ba"
