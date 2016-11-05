# Random Status Codes

Simple HTTP server that returns random HTTP status code, written in Go.
- Builds two networked Docker containers
- First container is running NGINX
- Second container is running the HTTP server
- Docker expects ports `8000`, `8080`, and `8443` to be available
- NGINX container proxies all requests to `localhost:8080/status`, to the HTTP server container
- HTTP server returns a random HTTP status code (i.e. `HTTP/1.1 304 Not Modified`)
- Go source code contains two ways to return codes
  - Common codes, with weighted results (default)
  - All code, evenly distributed results

## Quick Start
Clone, build, and test locally
```bash
git clone https://github.com/garystafford/nginx-log-parser.git
cd nginx-log-parser
docker-compose up -d
curl http localhost:8080/status
```

## Details
Build and run server locally
```bash
go run go-server.go
go build random-status.go
```

Build binary for Linux
```bash
GOOS=linux GOARCH=amd64 go build random-status.go
```

Grab default NGINX configuration files
```bash
docker cp random-status-nginx:/etc/nginx/conf.d/default.conf default.conf
docker cp random-status-nginx:/etc/nginx/nginx.conf nginx.conf
```

Create Docker images and containers, start server
```bash
docker-compose up -d
```

Manual Method without Docker Compose: Create Docker images and containers, start server
```bash
docker rm -f random-status-nginx
docker build -t random-status-nginx -f NGINX/Dockerfile .
docker run --name random-status-nginx -d -p 8080:80 -p 8443:443 random-status-nginx

docker rm -f random-status-server
docker build -t random-status-server -f Server/Dockerfile .
docker run --name random-status-server -d -p 8000:8000 random-status-server
```

Generate server traffic
```bash
for i in {1..10}; do http localhost:8080/status; done
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log
```
Analyze log
```bash
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
  cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
  sed -n '/05\/Nov\/2016:15:07:02/,/05\/Nov\/2016:15:07:07/ p' | \
  cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn
```


Misc Commands
```bash
docker exec -it random-status-nginx nohup ./usr/local/bin/random-status &
docker exec -it random-status-nginx bash
apt-get update -y && apt-get install wget
nginx -v -s reload
cd /tmp && ./random-status
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
```