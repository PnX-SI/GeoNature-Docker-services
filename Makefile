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

build: submodule_init
	buil/build.sh

dev: build
	docker compose -f docker-compose.yml -f docker-compose-dev.yml up -d

prod: submodule_init
	 COMPOSE_FILE=docker-compose.yml docker compose -f docker-compose.yml -f docker-compose-dev.yml up -d