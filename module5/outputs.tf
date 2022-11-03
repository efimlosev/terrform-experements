output "public_ip" {
  value = aws_instance.module5-instance.public_ip
}
  
output "public_dns" {
  value = aws_instance.module5-instance.public_dns
}
  