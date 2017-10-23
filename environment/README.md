Dev Toys
========


Docker containers
-----------------

It requires a user defined network with `dev` name. Create it with:

```bash
docker network create dev
docker network ls
```

Run dev container from this project directory, with a command

```bash
docker-compose up
```

You should get proxy and redis containers:

```bash
docker ps
```

```
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                           NAMES
c727071e498e        redis:latest             "docker-entrypoint.sh"   26 minutes ago      Up 26 minutes       6379/tcp                        redis
553003db8f43        jwilder/nginx-proxy      "/app/docker-entrypoi"   26 minutes ago      Up 26 minutes       0.0.0.0:80->80/tcp, 443/tcp     proxy
```

### Proxy

Proxy allows to easily set up domains. Every new container with application has to populate
environmental variable `VIRTUAL_HOST` with its host name, e.g.: `VIRTUAL_HOST=gdm.dev`.

Mind that container with the application must be in the same docker network `dev`.

In `docker-compose.yml` it would look like:

```yml
version: '2'

networks:
    default:
        external:
            name: dev

services:
    nginx:
        image: nginx
        container_name: gdm.nginx
        environment:
            - VIRTUAL_HOST=gdm.dev
        volumes:
            - ./:/var/www/symfony
            - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
        links:
            - fpm

```

Then you set up in you HOST machine `/etc/hosts`:

```bash
127.0.0.1   gdm.vm
```

Sources:
* http://www.yannmoisan.com/docker.html
* https://github.com/jwilder/nginx-proxy


### Redis

You can connect `redis` container to application conteiner through external link, e.g.:

```yml
varsion: '2'

services:
    fpm:
        # ...
        external_links:
            - redis

```

### XDebug

Bind artificial IP to your machine on every restart:

MacOS
```bash
sudo ifconfig lo0 alias 10.254.254.254
```

Ubuntu
```bash
sudo ifconfig lo:0 10.254.254.254 up
```

Use the IP `10.254.254.254` on xdebug configuration among containers.

Read more: 
* https://forums.docker.com/t/ip-address-for-xdebug/10460/22
* https://gist.github.com/ralphschindler/535dc5916ccbd06f53c1b0ee5a868c93



