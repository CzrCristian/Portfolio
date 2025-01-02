output "jump_ip_enterprise_net" {
  value = docker_container.jump.network_data[0].ipv4_address
}
output "jump_ip_jump_net" {
  value = docker_container.jump.network_data[1].ipv4_address
}
output "enterprise_ubuntu_ip" {
  value = docker_container.ubuntu.network_data[0].ipv4_address
}