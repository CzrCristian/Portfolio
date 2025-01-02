
How you can start this container, read README.md
docker build -f jump.Dockerfile -t jump .; docker run -d -p 27022:22 --name jump jump; docker exec -it jump /bin/bash

How you can start terraform
terraform init; terraform apply
