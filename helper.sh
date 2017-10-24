#!/usr/bin/env bash

# $1 = Branch name
# $2 = Merge with branch (give branch name)?
# $3 = Commit Message (to commit)
# $4 = true to Stash actual changes.

if [ "$(ls | grep app)" == "app" ]; then

	# Just stash changes.
	if [ ${4:-false} == 'true' ]; then
		git stash
		git pull origin `git symbolic-ref --short -q HEAD`
	fi

	# Add all and commit using message.
	if [ "${3:-false}" != false ]; then
		git add -A
		git commit -am "$3"
		git pull origin `git symbolic-ref --short -q HEAD`
		git push origin `git symbolic-ref --short -q HEAD`
		printf "\n\n Congratulations! Your code has been pushed to" `git symbolic-ref --short -q HEAD` "\n\n"
	fi

	# Checkout to another branch.
	if [ ${1:-false} != false ]; then

		# Merge origin to develop
		if [ ${2:-false} != false ]; then
			git checkout $2
			git pull origin $2
			
			git checkout $1
			git pull origin $1
			git merge origin $2
			printf "\n\n Branch" $1 "is now merge with " $2 " \n\n"

		else
			git checkout $1
			git pull origin $1
		fi
		
		rm -Rf ./var/cache/dev
		rm -Rf ./var/cache/prod

		docker exec -it signature composer install -o --no-scripts && yarn --emoji=true -s && webpack --progress --cache
		docker exec -it signature y|php bin/console doctrine:migrations:migrate

		rm -Rf ./var/cache/dev
		rm -Rf ./var/cache/prod

		printf "\n\n Welcome to branch: " $1 " \n\n"
		open http://dev.loan.co.uk/app_dev.php/case
	fi

	printf "\n\n Available arguments:"
	printf "\n 1. branch_name (checkout)"
	printf "\n 2. branch_name (merge with first branch)"
	printf "\n 3. commit message (to commit current branch)"
	printf "\n 4. true to stash changes on current branch. \n"
	
else
	printf "Error: app (symfony) folder is not in this directory (try 'ls -al | grep app'):" `pwd`
fi


