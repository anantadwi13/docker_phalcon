# Docker Phalcon

### Running Container
```bash
docker pull anantadwi13/docker_phalcon

docker run -dit -p 8080:80 --name=docker_phalcon -v "$(pwd)"/data:/var/www anantadwi13/docker_phalcon
```
It will run apache2 on port 8080