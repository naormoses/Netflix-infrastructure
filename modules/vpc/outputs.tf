output "subnet_ids" {
  value = [for subnet in aws_subnet.main : subnet.id]
}


output "vpc_ID" {
  value = aws_vpc.main.id
}
