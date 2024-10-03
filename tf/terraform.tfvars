yolo5_ami_id = "ami-0d5eff06f840b45e9"
ssh_key_name = "aws-bennyi"
region = "us-east-1"
instance_type = "t2.medium"
public_subnet_ids = ["subnet-12345abcde", "subnet-67890fghij"]
role_name = "aws-polybot-bennyi"

vpc_configs = {
  region1 = {
    name       = "primary-vpc"
    cidr_block = "10.0.0.0/16"
    azs        = ["us-east-1a", "us-east-1b"]
  }
}
