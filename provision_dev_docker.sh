#!/usr/bin/env bash

sudo echo "Welcome to the setup. \n\n"
read -p 'reset env (used to apply new images or updates)? (y/n) ' reset_env
read -p 'restart compose (used to apply updates)? (y/n) ' restart
read -p 'git pull actual branch? (y/n) ' git_pull
read -p 'run packages? (webpack, yarn, etc) (y/n) ' run_packages

# Completely clean docker env.
case ${reset_env:0:1} in y|Y )
	docker stop $(docker container ls -a -q)

	# Maintain and clean the env.
	if [ -d "~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/" ]; then
	  > ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/log/docker.log
	  rm -f ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2
	fi

	docker system prune -a -f
	docker system info
	docker network create dev

	# Allow XDebuger to work properly.
	sudo ifconfig lo0 alias 10.254.254.254
esac

# Pull latest code from actual branch.
case ${git_pull:0:1} in y|Y )
	gitBranch=`git symbolic-ref --short -q HEAD`
	branch="${gitBranch//[[:space:]]/}"		
	if [[ $branch = *[!\ ]* ]]; then
		git pull origin $branch
		git status
	else
		printf "\n There is no branch to work on!!! \n\n $branch"
	fi
esac

# Clean any actual cache.
rm -Rf ./application/var/cache/*

cd ./environment

# Refresh docker containers.
case ${restart:0:1} in y|Y )
	docker-compose stop 
	echo y | docker-compose rm -f
esac

# Start docker env.
docker-compose up -d --build --remove-orphans --quiet && sleep 180s

# Execute scripts and install packages.
case ${run_packages:0:1} in y|Y )
	docker exec -it signature sh -c "yarn && npx webpack && echo y | php bin/console doctrine:migrations:migrate" && sleep 180s
	docker exec -id signature sh -c "composer install" && sleep 120s
	rm -Rf ./../application/var/cache/*
esac

# Wait to have the build finished the open app to cache dev.
open http://dev.loan.co.uk/app_dev.php
printf "\n\n\n Ready! enjoy your day."