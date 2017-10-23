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

# Start the env.
cd ./environment
docker-compose up -d --build

# Start the application.
cd ./../docker
docker-compose up -d --build

cd ./../
# Clone Java jython in jython dir
if [ -z "$(ls -A ./jython)" ]; then
	git clone git@gitlab.com:dataconnect/app.loan.co.uk-sigde.git ./jython
fi

# Clone App in Application dir
if [ -z "$(ls -A ./application)" ]; then
	git clone git@gitlab.com:dataconnect/app.loan.co.uk-symfony.git ./application
fi

echo "----------------------> Dev Ready to work!"