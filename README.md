# Run AIL in a docker container
## Project goal
Quick project to dockerify ail-framework in a single container. It is not perfect but does the job...<br>
This project integrates the lacus crawler as well as a tor socket !<br>
<br>
Projects:<br>
Lacus: https://github.com/ail-project/lacus<br>
Ail-framework: https://github.com/ail-project/ail-framework<br>

## Prerequisites
Ail-framework is a resource intensive project !<br>
Docker image size: ~10GB<br>
Memory: >6GB<br>

## Guide
### Clone ail-framework
git clone https://github.com/ail-project/ail-framework.git

### Build ail docker container
sudo docker-compose build

### Run ail docker container
sudo docker-compose up -d

### Reset admin password
sudo docker exec ail-framework bin/LAUNCH.sh -rp

### Stop ail docker container
sudo docker-compose down

## Useful information
### UI for ail-framework
http://127.0.0.1:7000

### Lacus url for crawler settings
http://127.0.0.1:7100

### Tor proxy
socks5://127.0.0.1:9050
