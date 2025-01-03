# Jump Container and Terraform Setup

This repository provides setup instructions for running a Docker container as a jump host, as well as a simple Terraform configuration to deploy infrastructure.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Docker Setup](#docker-setup)
- [Terraform Setup](#terraform-setup)
- [Network Configuration](#network-configuration)

## Prerequisites

Before you begin, ensure you have the following tools installed on your machine:
- Docker
- Terraform
- Vagrant
- Kubernetes

## Docker Setup
If you want to run one or more Docker containers independently of the full infrastructure, use the following commands:

To build and run the jump container:

1. Build the Docker image:
    ```bash
    docker build -f jump.Dockerfile -t jump .
    ```

2. Run the Docker container in detached mode with the port 27022 exposed:
    ```bash
    docker run -d -p 27022:22 --name jump jump
    ```

3. Access the container using `docker exec`:
    ```bash
    docker exec -it jump /bin/bash
    ```

## Terraform Setup

To initialize and apply the Terraform configuration:

1. Initialize Terraform:
    ```bash
    terraform init
    ```

2. Apply the Terraform configuration:
    ```bash
    terraform apply
    ```
3. Destroy the Terraform configuration:
    ```bash
    terraform destroy
    ```
4. Restart the Terraform configuration in one line command:
    ```bash
    terraform destroy -auto-approve; terraform init; terraform plan; terraform apply -auto-approve
    ```

## Network Configuration

The following network addresses and IPs are used in this setup:

### Network Addr Table

| Network Name          | IP Address        |
|-----------------------|-------------------|
| jump-net              | 192.168.1.1       |
| enterprise_net        | 10.1.1.0          |

### Network IP-Address Mapping

| Host      | IP Address        | SSH       |
|-----------|-------------------|-----------|
| jump      | LOCALHOST_MACHINE | 27022     |
|           | 192.168.1.2       | 22        |
|           | 10.1.1.2          | 22        |
| ubuntu    | 10.1.1.3          |           |
