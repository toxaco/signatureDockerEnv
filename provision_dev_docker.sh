#!/usr/bin/env bash

# Maintain and clean the env.
if docker ps --format "{{.Names}}" | grep -q "proxy" ; then
	docker rm -f $(docker stop $(docker ps -aq))
	docker volume rm $(docker volume ls)
	docker rmi $(docker image ls)
	docker system prune -a -f
	
	if [ -d "~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/" ]; then
	  > ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/log/docker.log
	  rm -f ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2
	fi

	docker system df
	docker network create dev
fi

# Allow XDebuger to work properly.
sudo ifconfig lo0 alias 10.254.254.254

# Clone App in Application dir
if [ "$(ls | grep application)" == "application" ]; then
	git clone git@gitlab.com:dataconnect/app.loan.co.uk-symfony.git ./application
fi

# Start the env. and application.
cd ./environment
docker-compose up -d --build

printf "\n\n\n ----------------------> Follow next Steps! (like composer install, etc..."
open http://dev.loan.co.uk/app_dev.php