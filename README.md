# Random HTTP Status Code Generator

Dockerized HTTP server, written in Go, that returns random HTTP status code. Useful for testing how an application responds to unexpected HTTP status codes.

### Highlights
- Builds two networked Docker containers
- First container is running latest NGINX
- Second container is running the HTTP server
- Docker expects ports `8000`, `8080`, and `8443` to be available
- NGINX container proxies all requests to `localhost:8080/status`, to the HTTP server container
- HTTP server returns a random HTTP status code (i.e. `HTTP/1.1 304 Not Modified`)
- Go source code contains two ways to return codes
  - Common codes, with weighted results (default)
  - All code, evenly distributed results
- NGINX logs are written to disk for analysis vs. to stdout/stderr
- NGINX access log can be analyzed using simple bash commands

### Quick Start
Clone, build, and test locally
```bash
git clone https://github.com/garystafford/nginx-log-parser.git
cd $_
docker-compose up -d
for i in {1..100}; do curl -I localhost:8080/status; done
sh ./analyzer.sh
```
Sample distribution of status codes
```text
95 200
62 404
60 500
33 503
12 300
11 403
11 304
11 301
10 410
10 302
 9 400
 8 401
 8 307
 6 550
 4 501
350 Total
```

### Developer Details
Build and run HTTP server locally
```bash
go run go-server.go
go build random-status.go
```

Build binary for Linux (Busybox Docker container)
```bash
GOOS=linux GOARCH=amd64 go build random-status.go
```

Grab the default NGINX configuration files
```bash
docker run --name nginx-tmp nginx
docker cp nginx-tmp:/etc/nginx/conf.d/default.conf default.conf
docker cp nginx-tmp:/etc/nginx/nginx.conf nginx.conf
```

Create Docker images and containers, start server
```bash
docker-compose up -d
```

Manual Method without Docker Compose  
Create Docker images and containers, start server
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
for i in {1..100}; do curl -I localhost:8080/status; done
```

Analyze logs with script or manually
```bash
# run script
sh ./analyze.sh

# log
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log

# status code counts, sorted
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
  cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

# status code counts, sorted, within date range
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
  sed -n '/05\/Nov\/2016:15:07:02/,/05\/Nov\/2016:15:07:07/ p' | \
  cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

# status code counts total
docker exec -it random-status-nginx cat /var/log/nginx/random_status_access.log | \
cut -d '"' -f3 | cut -d ' ' -f2 | echo $(wc -l) Total
```

### References
- [Go HTTP Status Reference](https://golang.org/src/net/http/status.go)
- [Configuring the Nginx Error Log and Access Log](https://www.keycdn.com/support/nginx-error-log/)
- [Parsing NGINX Logs](https://easyengine.io/tutorials/nginx/log-parsing/)
- [NGINX Reverse Proxy](http://www.ubuntugeek.com/using-nginx-as-a-reverse-proxy-to-get-the-most-out-of-your-vps.html)
- [Returning Status Codes In Golang](http://learntogoogleit.com/post/63098708081/returning-status-codes-in-golang)
- [Cross Compile Your Go Programs](https://www.goinggo.net/2013/10/cross-compile-your-go-programs.html)
- [Cross Compiling Go](http://golangcookbook.com/chapters/running/cross-compiling/)
