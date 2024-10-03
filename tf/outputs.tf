output "vpc_id" {
  value = aws_vpc.polybot_vpc.id
}

output "subnet_id" {
  value = aws_subnet.polybot_subnet.id
}

output "security_group_id" {
  value = aws_security_group.polybot_sg.id
}

output "instance_id" {
  value = aws_instance.polybot_instance.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.polybot_queue.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.polybot_table.name
}

output "polybot_instance_public_ip" {
  value = aws_instance.polybot_instance.public_ip
}

output "yolo5_instance_public_ip" {
  value = aws_instance.yolo5_instance.public_ip
}

output "alb_dns_name" {
  value = aws_alb.polybot_alb.dns_name
}
