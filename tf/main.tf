terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "bennyi-aws-s3-bucket"
    key    = "terraform/state"
    region = "eu-west-3"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "polybot_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "polybot-vpc"
  }
}

resource "aws_internet_gateway" "polybot_igw" {
  vpc_id = aws_vpc.polybot_vpc.id

  tags = {
    Name = "polybot-igw"
  }
}

resource "aws_route_table" "polybot_route_table" {
  vpc_id = aws_vpc.polybot_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.polybot_igw.id
  }

  tags = {
    Name = "polybot-route-table"
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

  tags = {
    Name = "polybot-sg"
  }
}

resource "aws_acm_certificate" "polybot_cert" {
  domain_name              = "aws-domain-bennyi.int-devops.click"
  subject_alternative_names = ["*.aws-domain-bennyi.int-devops.click"]
  validation_method        = "DNS"

  tags = {
    Name = "polybot-cert"
  }
}

resource "aws_alb" "polybot_alb" {
  name               = "polybot-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.polybot_sg.id]
  subnets            = [aws_subnet.polybot_subnet.id, aws_subnet.polybot_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "polybot-alb"
  }
}

resource "aws_alb_target_group" "polybot_target_group" {
  name     = "polybot-target-group"
  port     = 8443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.polybot_vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "polybot-target-group"
  }
}

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.polybot_alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/"
      port        = "8443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "polybot_listener" {
  load_balancer_arn = aws_alb.polybot_alb.id
  port              = 8443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.polybot_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.polybot_target_group.id
  }
}

resource "aws_sqs_queue" "polybot_queue" {
  name = "polybot-queue"

  tags = {
    Name = "polybot-queue"
  }
}

resource "aws_dynamodb_table" "polybot_table" {
  name         = "PolybotData"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"

  tags = {
    Name = "polybot-dynamodb"
  }
}

### Shared IAM Role and Instance Profile ###
resource "aws_iam_role" "common_role" {
  name = "aws-common-polybot-yolo5-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "common_instance_profile" {
  name = "aws-common-polybot-yolo5-profile"
  role = aws_iam_role.common_role.name
}

resource "aws_iam_role_policy_attachment" "common_ec2_policy" {
  role       = aws_iam_role.common_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

### Polybot Instance ###
resource "aws_instance" "polybot_instance" {
  ami                  = "ami-062cdc7aed1a19ee0"
  instance_type        = "t2.micro"
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
                # Add Docker’s official GPG key
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

                # Add Docker’s APT repository
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

                # Update the package index again
                sudo apt update -y

                # Install Docker
                sudo apt install -y docker-ce

                # Start Docker service
                sudo systemctl start docker
                sudo systemctl enable docker

                # Add the ubuntu user to the docker group
                sudo usermod -aG docker ubuntu

                # Install Docker Compose
                DOCKER_COMPOSE_VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
                sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # Install AWS CLI version 2 via snap
                sudo snap install aws-cli --classic

                # Verify AWS CLI installation
                aws --version

                # Retrieve Docker password from AWS Secrets Manager
                SECRET_NAME='DOCKERHUB_PASSWORD'
                SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text)

                # Login to DockerHub
                sudo docker login -u "DOCKER_USERNAME" -p "$SECRET_VALUE"

                # Pull the latest Polybot image
                sudo docker pull "DOCKER_USERNAME/polybot:latest"

                # Run Polybot in Docker
                sudo docker run -d --name polybot -p 8443:8443 --restart always "DOCKER_USERNAME/polybot:latest"
                EOF

  tags = {
    Name = "polybot-instance"
  }
}

### Yolo5 Instance ###
resource "aws_instance" "yolo5_instance" {
  ami                  = "ami-062cdc7aed1a19ee0"
  instance_type        = "t2.medium"
  subnet_id            = aws_subnet.polybot_subnet_2.id
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
                # Add Docker’s official GPG key
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

                # Add Docker’s APT repository
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

                # Update the package index again
                sudo apt update -y

                # Install Docker
                sudo apt install -y docker-ce

                # Start Docker service
                sudo systemctl start docker
                sudo systemctl enable docker

                # Add the ubuntu user to the docker group
                sudo usermod -aG docker ubuntu

                # Install Docker Compose
                DOCKER_COMPOSE_VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
                sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # Install AWS CLI version 2 via snap
                sudo snap install aws-cli --classic

                # Verify AWS CLI installation
                aws --version

                # Retrieve Docker password from AWS Secrets Manager
                SECRET_NAME='DOCKERHUB_PASSWORD'
                SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text)

                # Login to DockerHub
                sudo docker login -u "DOCKER_USERNAME" -p "$SECRET_VALUE"

                # Pull the latest Yolo5 image
                sudo docker pull "DOCKER_USERNAME/yolo5:latest"

                # Run Yolo5 in Docker
                sudo docker run -d --name yolo5 -p 8081:8081 --restart always "DOCKER_USERNAME/yolo5:latest"
                EOF

  tags = {
    Name = "yolo5-instance"
  }
}
