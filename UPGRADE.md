# Guide for upgrade your flarum container

### Upgrade to latest from v1.3.0

:warning: Backup your database, config.php, composer.lock and assets folder  
:warning: Disable all 3rd party extensions prior to upgrading in panel admin.

1 - Update your docker-compose file, see an example [here](https://github.com/mondediefr/docker-flarum/tree/master#2---docker-composeyml)

```yml
version: "3"

services:
  flarum:
    image: janethan/flarum:latest
    ...


```

2 - Pull the last docker images

```sh
docker build -t janethan/flarum:latest https://github.com/janethan/docker-flarum.git
docker compose up -d flarum    # The current folder where docker-compose.yml is located
```

3 - Updating your database and removing old assets & extensions

```sh
docker exec -ti flarum php /flarum/app/flarum migrate
docker exec -ti flarum php /flarum/app/flarum cache:clear
```

After that your upgrade is finish. :tada: :tada:


