# Containerized provisioning

This repo helps rolling up the provisioning application, including frontend and all integrated services such as sources for development purpose, demo or testing with no extra setup. This repo uses [git-submodules](https://github.blog/2016-02-01-working-with-submodules/) for linking different services all-together as sub directories.

## Setup

```sh
$ git clone https://github.com/RHEnVision/provisioning-compose.git
$ git submodule init
$ git submodule update
```

After cloning, the folder structure should be:
```
   ├── provisioning-compose
   │   ├── backend
   │   ├── frontend
   │   ├── notifications
   │   ├── sources-api-go
   └── 
```

Before use, some images are currently from private quay.io repositories so make sure to login via `docker login quay.io` or `podman login quay.io`.

Copy all services env files - `*.example.env` -> `.env`, you can add or edit your custom variables.

```bash
$ cp backend.example.env backend.env
```

In first use, to run all services locally altogether, including seeding and migration:

```sh
$ COMPOSE_PROFILES=kafka,kafka-init,notifications,notifications-init,backend-dev,sources-dev,frontend-dev docker compose up
```

Alternatively, with podman, to start backend and sources:

```
pip3 install podman-compose
podman-compose --profile sources --profile backend up
```

Make sure to use podman-compose 1.0.7 or newer for profiles feature, install development version if not available yet (as of Summer 2023).

### Seeding

To seed sources database, create configuration file first:

	cp sources_seed/sources.example.conf sources_seed/sources.conf

Edit it, we suggest to create the same account/org id as on stage so you can switch to stage later:

	export ACCOUNT_ID=1234
	export ORG_ID=9876
	export ARN_ROLE=arn:aws:iam::123456789:role/satellite-services-role
	export SUBSCRIPTION_ID=ffd0879a-3149-a750-a10f-8aaf77786ad3
	export PROJECT_ID=provisioning-7832643

When the compose is up, run:

	./sources_seed/seed.sh

### Profiles

A compose profile allows you to run a subset of containers. When no profile is given, 
the provisioning backend, postgres and redis will run by default.

Profiles:
- kafka: run kafka with zookeeper, register topics
- kafka-init: initialize required kafka's topics, run along side kafka at first use
- sources: run latest sources service image from quay
- sources-dev: run local sources with postgres db, on first use notice that you will need to run `/script/sources.seed.sh` for seeding your local sources data.
- backend: migrate and run the provisioning backend, with postgres and redis from the official image
- backend-dev: migrate and run the provisioning backend, with postgres and redis from git
- frontend-dev: run local provisioning frontend
- notifications: running local notification-backend service
- notifications-init: seeds the required provisioning data, required for the first notifications use.


For example, in order to run local sources, kafka, local backend and frontend profiles, run

```sh
$ COMPOSE_PROFILES=frontend-dev,backend-dev,kafka,sources-dev docker compose up 
```

 ### Notifications local setup
 See notifications [section](/notifications_seed/README.md)

### Live reloading for dev
The backend container uses [CompileDaemon](github.com/githubnemo/CompileDaemon) for live reloading, it watches for changes, re-build and run the server when a change occurs. The frontend container uses webpack dev server hot reloading.

### Compose's data
Databases, kafka and redis data and logs are stored under `./data` folder. 
When you use podman as non-root, postgres will change permissions of the directory to container user (random uid) and 600 permissions which makes the directory undeletable for the hosting user, workaround can be:
```sh
$ podman unshare chmod 777 data/*
```
