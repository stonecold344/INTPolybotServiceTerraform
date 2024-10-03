resource "aws_instance" "polybot_instance" {
  ami                    = "ami-0790b8d7f381d845d"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]

  tags = {
    Name = "polybot-instance-bennyi"
  }
}
