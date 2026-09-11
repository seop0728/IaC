output "instance_public_ip_a" {
  description = "인스턴스 A의 공인 IP"
  value       = aws_instance.instance_a.public_ip
}

output "instance_public_ip_b" {
  description = "인스턴스 B의 공인 IP"
  value       = aws_instance.instance_b.public_ip
}
