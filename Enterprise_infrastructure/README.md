
How you can start this container, read README.md
docker build -f jump.Dockerfile -t jump .; docker run -d -p 27022:22 --name jump jump; docker exec -it jump /bin/bash

How you can start terraform
terraform init; terraform apply


+--------------------------------------------+
|            Network addr table              |
+--------------------------------------------+
jump-net                    192.168.1.1
enterprise_net              10.1.1.0


+--------------------------------------------+
|            Network IP-Address              |
+--------------------------------------------+
jump        192.168.1.2     10.1.1.2
ubuntu                      10.1.1.3