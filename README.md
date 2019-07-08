## Building from local image in `develop branch`

# Signature Docker Env
Simple docker structure to run Signature app.

- Now using SSL (not by default, check provision_dev_docker.sh).

# Instructions:

- Download and install docker:
```
https://store.docker.com/search?type=edition&offering=community
```

- Git clone this repo.
	- Don't forget to add your SSH key (github): https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

- Git clone your application inside the folder "application" (the "space" and the "dot" at the end of your git command is important!).
	- Or just execute next tep.
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

- Set up your MySql/Maria database using a previous dump.
	- In you parameters.yml (signature app) the mysql_host should be: mysql (as it's pointing to the mysql container)
	- Local Dabase access:
		- user: root
		- Pass: root

- Finnaly don't forget to run from your command line Composer and NPM:

Obs: If you need to access the machine (a.k.a SSH) for some reason, just type:
```
docker exec -it signature bash
```

- Now you can open your browser and type dev.loan.co.uk/app_dev.php/ to start using the app.

# Info
- Docker will sync any changes from your local files to your virtual machine (containers) automaticaly.
- By default I set all the "docker-file" files to use a different type of caching that **ONLY WORKS ON Mac**. If you are going to use it on Linux or Windows then please, update that file by removing all instances of **":cached"**.

# Monitoring and debugging

- From your borwser you can access: **http://localhost:9900/** to open a docker management panel (Portainer).
	- The User is: admin
	- The pass is: uhCg2Q9VXsCU
	- Or just set your own.

- To use XDebugger you only need to set your IDE to listen to the domain dev.loan.co.uk from port 80 and set the absolute path on the server. (see image bellow for PHPStorm).

![PHPStorm Xdebugger setup](https://user-images.githubusercontent.com/13979220/31448225-d36886a0-ae9b-11e7-8ead-cc0c3b2e37aa.png)

# Speed Up

Articles that explain how to speed up your docker on MAC:
- https://medium.com/@TomKeur/how-get-better-disk-performance-in-docker-for-mac-2ba1244b5b70
- https://github.com/docker/compose/issues/3419#issuecomment-221793401

# Public Remote Access (for tests)

Using https://ngrok.com/ you can open your port 80 to the world and allow other people to access the main applicantion. Just download the ngrok file, then run the command bellow:

```
./ngrok http dev.loan.co.uk:80 -host-header=dev.loan.co.uk
```
P.S. If you need to secure it, use: '-auth="username:password"'
