#----------------------------------------------------------
# This file contains the Terraform code to create the 
# Docker containers and networks for the enterprise 
# infrastructure.
#----------------------------------------------------------
# The Terraform code in this file creates the following
# resources:
#----------------------------------------------------------
# - A local variables
#----------------------------------------------------------
locals {
    root_path = "/${replace(abspath(path.root), ":", "")}"
}
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

    ports {
        internal = 22
        external = 27022
    }

    ports {
        internal = 80
        external = 27080
    }

    ports {
        internal = 443
        external = 27443
    }

    networks_advanced {
        name = docker_network.jump_net.name
        ipv4_address = "192.168.1.2"
    }

    networks_advanced {
        name = docker_network.enterprise_net.name
        ipv4_address = "10.1.1.2"
    }
    privileged = true
    #entrypoint = ["/bin/bash", "-c", ""]

    volumes {
        container_path  = "/home/jump/scripts"
        host_path       = "${local.root_path}/Data/Jump/scripts"
        read_only       = true
    }

    provisioner "local-exec" {
        command = "docker exec ${self.name} bash /home/jump/scripts/jump-proxy.sh"
    }

    #provisioner "local-exec" {
    #    command = "docker cp ${path.module}/Data/Jump/scripts/jump-proxy.sh ${self.name}:/home/jump/scripts/jump-proxy.sh && docker exec ${self.name} bash /home/jump/scripts/jump-proxy.sh"
    #}

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
#                     Nginx container
#----------------------------------------------------------

resource "docker_container" "nginx" {
    name  = "nginx"
    image = "nginx:latest"

    networks_advanced {
        name = docker_network.enterprise_net.name
        ipv4_address = "10.1.1.4"
    }

    #volumes {
    #    container_path  = "/etc/nginx"
    #    host_path       = "${path.module}/Data/Nginx/nginx"
    #    read_only       = true
    #}

    provisioner "local-exec" {
        command = "docker exec ${self.name} bash service nginx start"
    }

    entrypoint = ["/bin/bash", "-c", "while true; do sleep 3600; done"]

    depends_on = [
        docker_network.enterprise_net
    ]
}
#----------------------------------------------------------