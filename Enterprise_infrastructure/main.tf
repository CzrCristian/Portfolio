#----------------------------------------------------------
# This file contains the Terraform code to create the 
# Docker containers and networks for the enterprise 
# infrastructure.
#----------------------------------------------------------
# The Terraform code in this file creates the following
# resources:
#----------------------------------------------------------
# - A provider resouces
#----------------------------------------------------------

terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "2.15.0"
        }
    }
}

provider "docker" {
    host = "npipe:////./pipe/docker_engine" # For Windows
}

#----------------------------------------------------------
# - Network resources
#----------------------------------------------------------
#                   jump_net network
#----------------------------------------------------------
resource "docker_network" "jump_net" {
    name = "jump-net"
    internal = false
    ipam_config {
        subnet  = "192.168.1.0/24"
        gateway = "192.168.1.1"
    }
}

#----------------------------------------------------------
#                   enterprise_net network
#----------------------------------------------------------
resource "docker_network" "enterprise_net" {
    name = "enterprise-net"
    internal = true
    ipam_config {
        subnet  = "10.1.1.0/24"
        gateway = "10.1.1.1"
    }
}

#----------------------------------------------------------
# - Dockerfile resources
#----------------------------------------------------------
resource "docker_image" "jump_image" {
    name = "jump:latest"
    build {
      path = "${path.module}/DockerFiles"
      dockerfile = "jump.Dockerfile"
    }
}

#----------------------------------------------------------
# - Container resources
#----------------------------------------------------------
#                   Jump container
#----------------------------------------------------------

resource "docker_container" "jump" {
    name  = "jump"
    image = docker_image.jump_image.name

    networks_advanced {
        name = docker_network.jump_net.name
        ipv4_address = "192.168.1.2"
    }

    networks_advanced {
        name = docker_network.enterprise_net.name
        ipv4_address = "10.1.1.2"
    }
    privileged = true
    entrypoint = ["/bin/bash", "-c", "while true; do sleep 3600; done"]
    provisioner "local-exec" {
        command = "docker cp jump-proxy.sh ${self.name}:/root/jump-proxy.sh && docker exec ${self.name} bash /root/jump-proxy.sh"
    }

    depends_on = [
        docker_network.enterprise_net,
        docker_network.jump_net,
        docker_image.jump_image
    ]
}
#----------------------------------------------------------
#                     Ubuntu container
#----------------------------------------------------------

resource "docker_container" "ubuntu" {
    name  = "enterprise-ubuntu"
    image = "ubuntu:22.04"

    networks_advanced {
        name = docker_network.enterprise_net.name
        ipv4_address = "10.1.1.3"
    }

    entrypoint = ["/bin/bash", "-c", "while true; do sleep 3600; done"]

    depends_on = [
        docker_network.enterprise_net
    ]
}
#----------------------------------------------------------