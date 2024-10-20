terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "bennyi-aws-s3-bucket"  # Use a static bucket name
    key    = "terraform/state"
    region = "eu-west-3"               # Specify a static region
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.region
}

# Local variable to construct dynamic S3 bucket name for use elsewhere in the configuration
locals {
  bucket_name = "${var.base_bucket_name}-${var.region}"
}

locals {
  formatted_private_key = replace(var.aws_private_key, "\n", "\n")
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
}

resource "aws_s3_bucket" "dynamic_bucket" {
  bucket = local.bucket_name
  acl    = "private"

  tags = {
    Name        = "Bennyi-S3-Bucket-terraform"
    Environment = "Dev"
  }
}

resource "aws_vpc" "polybot_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "polybot-vpc-bennyi"
  }
}

resource "aws_internet_gateway" "polybot_igw" {
  vpc_id = aws_vpc.polybot_vpc.id

  tags = {
    Name = "polybot-igw-bennyi"
  }
}

resource "aws_route_table" "polybot_route_table" {
  vpc_id = aws_vpc.polybot_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.polybot_igw.id
  }

  tags = {
    Name = "polybot-route-table-bennyi"
  }
}

resource "aws_route_table_association" "polybot_route_association" {
  subnet_id      = aws_subnet.polybot_subnet.id
  route_table_id = aws_route_table.polybot_route_table.id
}

resource "aws_route_table_association" "polybot_route_association_2" {
  subnet_id      = aws_subnet.polybot_subnet_2.id
  route_table_id = aws_route_table.polybot_route_table.id
}

resource "aws_subnet" "polybot_subnet" {
  vpc_id            = aws_vpc.polybot_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "polybot-subnet"
  }
}

resource "aws_subnet" "polybot_subnet_2" {
  vpc_id            = aws_vpc.polybot_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "polybot-subnet-2"
  }
}

resource "aws_security_group" "polybot_sg" {
  vpc_id = aws_vpc.polybot_vpc.id
  // Inbound rules

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Outbound rules
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8444
    to_port     = 8444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "polybot-sg"
  }
}


resource "aws_alb" "polybot_alb" {
  name               = "polybot-alb-bennyi"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.polybot_sg.id]
  subnets            = [aws_subnet.polybot_subnet.id, aws_subnet.polybot_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "polybot-alb"
  }
}

resource "aws_alb_target_group" "http_target_group" {
  name     = "http-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.polybot_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "http-target-group-bennyi"
  }
}

resource "aws_alb_target_group" "https_target_group" {
  name     = "https-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.polybot_vpc.id

  health_check {
    path                = "/"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "https-target-group-bennyi"
  }
}

resource "aws_alb_target_group" "polybot_target_group" {
  name     = "polybot-target-group"
  port     = 8443
  protocol = "HTTP"
  vpc_id   = aws_vpc.polybot_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "polybot-target-group-bennyi"
  }
}



resource "aws_alb_target_group" "yolo5_target_group" {
  name     = "yolo5-target-group"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.polybot_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "yolo5-target-group-bennyi"
  }
}

resource "aws_lb_listener" "http_80_listener" {
  load_balancer_arn = aws_alb.polybot_alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_443_forward" {
  load_balancer_arn = aws_alb.polybot_alb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.polybot_target_group.id
  }
}

resource "aws_lb_listener" "https_8443_listener" {
  load_balancer_arn = aws_alb.polybot_alb.id
  port              = 8443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.polybot_target_group.id
  }
}

resource "aws_lb_listener" "http_8081_listener" {
  load_balancer_arn = aws_alb.polybot_alb.id
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.polybot_target_group.id
  }
}

resource "aws_sqs_queue" "polybot_queue" {
  name = "aws-sqs-image-processing-bennyi"

  tags = {
    Name = "polybot-queue"
  }
}

resource "aws_dynamodb_table" "predictions_table" {
  name         = "AWS-Project-Predictions-bennyi"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "prediction_id"
    type = "S"  # String type for the partition key
  }

  hash_key = "prediction_id"  # Partition key

  tags = {
    Name = "predictions-dynamodb-bennyi"
  }
}


resource "aws_dynamodb_table" "chat_prediction_state_table" {
  name         = "ChatPredictionState-bennyi"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "chat_id"
    type = "N"  # Number type for the partition key
  }

  hash_key = "chat_id"  # Partition key

  tags = {
    Name = "chat-prediction-state-dynamodb-bennyi"
  }
}

# Reference the existing IAM role
data "aws_iam_role" "common_role" {
  name = "aws-polybot-bennyi"  # Name of the existing role
}

resource "aws_iam_instance_profile" "common_instance_profile" {
  name = "aws-common-polybot-yolo5-profile-${var.region}"
  role = data.aws_iam_role.common_role.name
}

resource "aws_iam_role_policy_attachment" "common_ec2_policy" {
  role       = data.aws_iam_role.common_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


resource "aws_secretsmanager_secret" "telegram_bot_token" {
  name        = "Telegram-Secret-Bennyi24"
  description = "Telegram Bot token for Polybot"

  tags = {
    Name = "telegram-bot-token-secret-bennyi"
  }
}

resource "aws_secretsmanager_secret_version" "telegram_bot_token_version" {
  secret_id     = aws_secretsmanager_secret.telegram_bot_token.id
  secret_string = jsonencode({"Telegram-Secret-Bennyi" = var.telegram_bot_token})
}

resource "aws_instance" "polybot_instance" {
  ami                  = var.polybot_ami_id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.polybot_subnet.id
  security_groups      = [aws_security_group.polybot_sg.id]
  iam_instance_profile = aws_iam_instance_profile.common_instance_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                set -e

                # Update the package index
                sudo apt update -y

                # Install necessary packages
                sudo apt install -y unzip curl snapd

                # Install Docker
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable"
                sudo apt update -y
                sudo apt install -y docker-ce
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker ubuntu

                # Install Docker Compose
                DOCKER_COMPOSE_VERSION=\$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
                sudo curl -L "https://github.com/docker/compose/releases/download/\$DOCKER_COMPOSE_VERSION/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # Install AWS CLI
                sudo snap install aws-cli --classic

                # Retrieve Docker password from AWS Secrets Manager
                SECRET_NAME='DOCKERHUB_PASSWORD'
                SECRET_VALUE=\$(aws secretsmanager get-secret-value --secret-id "\$SECRET_NAME" --query 'SecretString' --output text)

                # Login to DockerHub
                sudo docker login -u "stonecold344" -p "\$SECRET_VALUE"

                # Pull the latest Polybot image
                sudo docker pull "stonecold344/polybot:latest"
                EOF

  # Upload each required file individually
  provisioner "remote-exec" {
    inline = [
      "set -x",  # Enables detailed logging of each command
      "mkdir -p /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/ || true",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/",
      "chmod 755 /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/ || true"
     ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "polybot/"
    destination = "/home/ubuntu/projects/AWSProject-bennyi/polybot/polybot"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ubuntu/projects/AWSProject-bennyi/polybot/.env || true",  # Create .env if not exists
      "sed -i.bak '/TELEGRAM_TOKEN/c\\TELEGRAM_TOKEN='${var.telegram_bot_token}'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/S3_BUCKET_NAME/c\\S3_BUCKET_NAME='${local.bucket_name}'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/TELEGRAM_APP_URL/c\\TELEGRAM_APP_URL='https://${var.domain_name}:8443'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/POLYBOT_IMG_NAME/c\\POLYBOT_IMG_NAME='stonecold344/polybot:latest'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/DYNAMODB_TABLE/c\\DYNAMODB_TABLE='AWS-Project-Predictions-bennyi'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/AWS_REGION/c\\AWS_REGION='${var.region}'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/SQS_URL/c\\SQS_URL=https://sqs.${var.region}.amazonaws.com/019273956931/aws-sqs-image-processing-bennyi' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "sed -i.bak '/SECRET_ID/c\\SECRET_ID='${var.secret_id }'' /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/.env",
      "cd /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/",
      "cat .env"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/projects/AWSProject-bennyi/polybot/polybot/",
      "ls -al",
      "sudo systemctl restart docker",
      "docker system prune -a -f",
      "docker build -t stonecold344/polybot .",
      "docker-compose up -d"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
  }
  tags = {
    Name = "polybot-instance-bennyi"
  }
}

resource "aws_instance" "yolo5_instance" {
  ami                  = var.yolo5_ami_id
  instance_type        = var.yolo5_instance_type
  subnet_id            = aws_subnet.polybot_subnet_2.id
  security_groups      = [aws_security_group.polybot_sg.id]
  iam_instance_profile = aws_iam_instance_profile.common_instance_profile.name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  user_data = <<-EOF
                #!/bin/bash
                set -e

                # Update the package index
                sudo apt update -y

                # Install necessary packages
                sudo apt install -y unzip curl snapd

                # Install Docker
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable"
                sudo apt update -y
                sudo apt install -y docker-ce
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker ubuntu

                # Install Docker Compose
                DOCKER_COMPOSE_VERSION=\$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
                sudo curl -L "https://github.com/docker/compose/releases/download/\$DOCKER_COMPOSE_VERSION/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # Install AWS CLI
                sudo snap install aws-cli --classic

                # Clean up Docker to free space
                docker system prune -a -f

                # Retrieve Docker password from AWS Secrets Manager
                SECRET_NAME='DOCKERHUB_PASSWORD'
                SECRET_VALUE=\$(aws secretsmanager get-secret-value --secret-id "\$SECRET_NAME" --query 'SecretString' --output text)

                # Login to DockerHub
                sudo docker login -u "stonecold344" -p "\$SECRET_VALUE"
                cd yolo5/yolo5
                EOF

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/yolo5/yolo5",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/yolo5/yolo5",
      "sudo chmod -R 755 /home/ubuntu/yolo5/yolo5"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "yolo5/"
    destination = "/home/ubuntu/yolo5/yolo5"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
    on_failure = continue  # Prevent this from stopping all the steps if it fails again
  }


  provisioner "remote-exec" {
    inline = [
      "touch /home/ubuntu/yolo5/yolo5/.env || true",  # Create .env if not exists
      "sed -i.bak '/TELEGRAM_TOKEN/c\\TELEGRAM_TOKEN='${var.telegram_bot_token}'' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/S3_BUCKET_NAME/c\\S3_BUCKET_NAME='${local.bucket_name}'' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/TELEGRAM_APP_URL/c\\TELEGRAM_APP_URL='https://${var.domain_name}:8443'' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/POLYBOT_IMG_NAME/c\\POLYBOT_IMG_NAME='stonecold344/polybot:latest'' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/YOLO5_IMG_NAME/c\\YOLO5_IMG_NAME='stonecold344/yolo5:latest'' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/DYNAMODB_TABLE/c\\DYNAMODB_TABLE='AWS-Project-Predictions-bennyi'' //home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/AWS_REGION/c\\AWS_REGION='${var.region}'' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/SQS_URL/c\\SQS_URL=https://sqs.${var.region}.amazonaws.com/019273956931/aws-sqs-image-processing-bennyi' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/SQS_QUEUE_NAME/c\\SQS_QUEUE_NAME=aws-sqs-image-processing-bennyi' /home/ubuntu/yolo5/yolo5/.env",
      "sed -i.bak '/SCERET_ID/c\\SECRET_ID='${var.secret_id }'' /home/ubuntu/yolo5/yolo5/.env",
      "cd /home/ubuntu/yolo5/yolo5/",
      "cat .env",
      "sudo systemctl restart docker",
      "docker system prune -a -f",
      "docker build -t stonecold344/yolo5 .",
      "docker-compose up -d"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("aws-bennyi.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "yolo5-instance-bennyi"
  }
}


resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_alb_target_group.polybot_target_group.id
  target_id        = aws_instance.polybot_instance.id
  port             = 8443
}

