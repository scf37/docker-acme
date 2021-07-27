# docker-acme

This image is ACME client to manage SSL keys for single web site in dockerized environment.

## Features
- generates SSL certificate for specific domain(s) and puts it to web server directory
- automatically refreshes SSL certificate every two months (letsencrypt certificates expire after 3 months)
- automatically restarts web server when certificates change
- writes logs to file

## Configuration parameters
Configuration parameters must be passed to container via environment variables
- DOMAINS space-separated domain names for this cert. example: 'host.me www.host.me'
- WEBROOT root directory of web server. example: '/data'
- KEYPATH path for ssl cert key. example: '/data/host.pem'
- CERTPATH path for ssl chained certs. example: '/data/host-cert.pem'
- SERVER_CONTAINER web server container name in local docker installation. example: 'cnginx'

Container must be configured to pass docker socket in and (obviously) to have web server root accessible from inside. See example below.

## Example
```bash
docker create --name cacme-host --restart always --net=host \
  -v /data/acme:/data \ #acme data directory - used for logging
  -v /data/nginx:/nginx \ #web server root directory
  -v /var/run/docker.sock:/var/run/docker.sock \ #allow to run docker inside
  -e DOMAINS="host.net www.host.net" \ #first domain will be primary in the cert
  -e WEBROOT=/nginx \ #web server root directory
  -e KEYPATH=/nginx/conf/host.pem \ #web server SSL configuration should point to these
  -e CERTPATH=/nginx/conf/host-cert.pem \
  -e SERVER_CONTAINER=cnginx \ #container to restart on cert change
  scf37/acme:latest
```
ACME uses *HTTP* to validate domain ownership so web server must be configured to serve `http://host.net/.well-known/...` from webroot.
E.g. for nginx:
```
location /.well-known {
    root /data;
}
```
