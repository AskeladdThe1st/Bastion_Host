output "bastion_public_ip" {
    description = "The public IP address of the Bastion Host."
    value       = aws_instance.bastion_host.public_ip
}

output "app_server_private_ip" {
    description = "The private IP address of the Application Server."
    value       = aws_instance.app_server.private_ip
}

output "deployer_key_name" {
    description = "The name of the deployer key pair."
    value       = aws_key_pair.deployer.key_name
}