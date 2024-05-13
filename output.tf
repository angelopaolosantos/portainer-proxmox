output "container_password" {
  value     = random_password.container_password.result
  sensitive = true
}

output "private_key" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value = tls_private_key.private_key.public_key_openssh
}
