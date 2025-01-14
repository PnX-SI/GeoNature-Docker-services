SHELL := /bin/bash

launch: submodule_init
	docker compose up -d

submodule_init:
	git submodule init
	git submodule update
	pushd sources/GeoNature &&\
	git submodule init &&\
	git submodule update &&\
	popd

build:
	build/build.sh

dev: submodule_init
	COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml docker compose up -d

prod: submodule_init
	COMPOSE_FILE=docker-compose.yml docker compose up -d
