SHELL := /bin/bash

launch: submodule_init
	docker compose up -d

submodule_init:
	git submodule update --init --recursive

build:
	build/build.sh

dev: submodule_init
	COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml docker compose up -d

prod: submodule_init
	COMPOSE_FILE=docker-compose.yml docker compose up -d
