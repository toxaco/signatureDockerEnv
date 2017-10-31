#!/usr/bin/env bash

# $1 = Branch name
# $2 = Merge with branch (give branch name)?
# $3 = Commit Message (to commit)
# $4 = true to Stash actual changes.
# $5 = false to not run scripts.

if [ "$(ls | grep app)" == "app" ]; then

	# Just stash changes.
	if [ ${4:-false} == 'true' ]; then
		git stash
		git pull origin `git symbolic-ref --short -q HEAD`
	fi

	# Add all and commit using message.
	if [ "${3:-false}" != false ]; then
		gitBranch=`git symbolic-ref --short -q HEAD`
		branch="${gitBranch//[[:space:]]/}"

		if [[ $branch = *[!\ ]* ]]; then
			git status
			git add -A
			git commit -am "$3"
			git pull origin $branch

			# Merge origin to develop
			if [ ${2:-false} != false ]; then
				git checkout $2
				git pull origin $2
				git checkout $branch
				git merge origin $2
				printf "\n\n Branch $branch is now merge with $2 \n\n"
			fi

			git push origin $branch
			printf "\n\n Congratulations! Your code has been pushed to $branch \n\n"
		else
			printf "\n\n There is no branch to work on!!! \n\n $branch"
		fi
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
			printf "\n\n Branch $1 is now merge with $2 \n\n"

		else
			git checkout $1
			git pull origin $1
		fi
		
		if [ ${5:-true} != true ]; then
			rm -Rf ./var/cache/dev
			rm -Rf ./var/cache/prod

			docker exec -it signature bash -c 'composer install -o && echo y | php bin/console doctrine:migrations:migrate'

			# Keep watching for changes with Webpack.
			docker exec -i -d signature bash -c 'yarn --emoji=true -s && webpack --watch'

			rm -Rf ./var/cache/dev
			rm -Rf ./var/cache/prod

			# Release memory and CPU by killing all process.
			docker restart -t 30 signature
		fi

		printf "\n\n Welcome to branch: $1 \n\n"
		sleep 30s
		
		# Try to access to warm up the cache.
		open http://dev.loan.co.uk/app_dev.php/case
	fi

	git status
	git branch

	printf "\n Available arguments:"
	printf "\n 1. branch_name (checkout)"
	printf "\n 2. branch_name (merge with first branch)"
	printf "\n 3. commit message (to commit current branch)"
	printf "\n 4. true to stash changes on current branch. \n"
	printf "\n 5. false to not run scripts. \n"
	
else
	printf "Error: app (symfony) folder is not in this directory (try: ls -al | grep app):" 
	echo pwd
fi


