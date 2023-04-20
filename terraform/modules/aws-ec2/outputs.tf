output "bastion_instance_dns" {
  value = aws_instance.bastion-instance.public_dns
}
