region = "us-east-1"

vpc_configs = {
  "us-east-1" = {
    cidr_block = "10.0.0.0/16"
    name       = "terraform-vpc-us-east-1-bennyi"
    azs        = ["us-east-1a", "us-east-1b"]
  }
}

yolo5_ami_id = "ami-012d180e09be669db"
yolo5_instance_type = "t2.medium"
#bot_token = "6629220970:AAFUHIrGYAZh8RSvIAAl8HmE3q52JxwKm34"
