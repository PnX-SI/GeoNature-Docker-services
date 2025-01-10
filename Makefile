SHELL := /bin/bash

prod:
	docker compose up -d

submodule_init:
	git submodule init
	git submodule update
	pushd sources/GeoNature &&\
	git submodule init &&\
	git submodule update &&\
	popd

dev: submodule_init
	build/build.sh
	docker compose -f docker-compose.yml -f docker-compose-dev.yml up -d
