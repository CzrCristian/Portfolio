output "jump_ip_enterprise_net" {
  value = [
    for network in docker_container.jump.networks_advanced :
    network.ipv4_address if network.name == "enterprise-net"
  ][0]
}

output "jump_ip_jump_net" {
  value = [
    for network in docker_container.jump.networks_advanced :
    network.ipv4_address if network.name == "jump-net"
  ][0]
}

output "enterprise_ubuntu_ip" {
  value = [
    for network in docker_container.ubuntu.networks_advanced :
    network.ipv4_address if network.name == "enterprise-net"
  ][0]
}

output "enterprise_nginx_ip" {
  value = [
    for network in docker_container.nginx.networks_advanced :
    network.ipv4_address if network.name == "enterprise-net"
  ][0]
}

