resource "aws_instance" "yolo5_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]
  iam_instance_profile   = "aws-polybot-bennyi"

  tags = {
    Name = "yolo5-instance-bennyi"
  }
}
