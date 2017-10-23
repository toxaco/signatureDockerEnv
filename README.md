# Signature Docker Env
Simple docker structure to run Signature app.

# Instructions:

- Download and install docker:
``` 
https://store.docker.com/search?type=edition&offering=community 
```

- Git clone this repo.
	- Don't forget to add your SSH key (github): https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

- Git clone your application inside the folder "application" (the "space" and the "dot" at the end of your git command is important!).
```
git clone ___pastYourUrlHere___ .
```

- Execute this commands from your terminal (this will create your basic structure with proxy, mysql, etc. and start the app): 
```
sudo ./provision_dev_docker.sh
```

- Add the code bellow to your local hosts file (Location for Mac users: /etc/hosts).
```
127.0.0.1       dev.loan.co.uk
```

- Set up your MySql database using a previous dump.
	- In you parameters.yml (signature app) the mysql_host should be: mysql (as it's pointing to the mysql container)
	- Local Dabase access:
		- user: root
		- Pass: root

- Finnaly don't forget to run from your command line Composer and NPM:
	- Todo: Improve and automate this step in the future. [23/10/2017]
```

# Install all the composer dependencies.
docker exec -i -t signature composer install -o

# Install all NPM modules.
docker exec -i -t signature y|npm i -g webpack && y|npm i -g typescript && y|npm i -g yarn 

# Ssh inside the machine.
docker exec -i -t signature bash

# Install all NPM modules
yarn && webpack --watch
```

Obs: If you need to access the machine (a.k.a SSH) for some reason, just type:
```
docker exec -it signature bash
```

- Now you can open your browser and type dev.loan.co.uk to start using the app.

# Info
- Docker will sync any changes from your local files to your virtual machine (containers) automaticaly.
- By default I set all the "docker-file" files to use a different type of caching that ONLY WORKS ON Mac. If you are going to use it on Linux or Windows then please, update that file by removing all instances of ":cached".

# Monitoring and debugging

- From your borwser you can access: localhost:9900/ to open a docker management panel (Portainer). 
	- The User is: admin 
	- The pass is: uhCg2Q9VXsCU
	
- To use XDebugger you only need to set your IDE to listen to the domain dev.loan.co.uk from port 80 and set the absolute path on the server. (see image bellow for PHPStorm).

![PHPStorm Xdebugger setup](https://user-images.githubusercontent.com/13979220/31448225-d36886a0-ae9b-11e7-8ead-cc0c3b2e37aa.png)
