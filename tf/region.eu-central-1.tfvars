region = "eu-central-1"

vpc_configs = {
  "eu-central-1" = {
    cidr_block = "10.0.0.0/16"
    name       = "terraform-vpc-eu-central-1-bennyi"
    azs        = ["eu-central-1a", "eu-central-1b"]
  }
}
polybot_ami_id = "ami-0161dcac7b8188b87"
yolo5_ami_id = "ami-0078bd30dae23aecd"
yolo5_instance_type = "t2.medium"
telegram_bot_token = "7130082480:AAG9tBYC-eSDQKzxznvIxgseCRoARBUZjvw"
domain_name = "aws-domain-bennyi2.int-devops.click"
secret_id = "Telegram-Secret-Bennyi25"
aws_private_key = ""
certificate_arn   = "arn:aws:acm:eu-central-1:019273956931:certificate/20b019f6-bf17-495a-80c7-125c83ca8560"
