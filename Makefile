SHELL := /bin/bash

launch:
	docker compose up -d

dev_init:
	source .env; echo "{\"API_ENDPOINT\":\"//localhost$${GEONATURE_BACKEND_PREFIX}\"}" > sources/GeoNature/frontend/src/assets/config.json
	jq '.projects.geonature.architect.build.configurations.development += {"baseHref": "/geonature/"}' sources/GeoNature/frontend/angular.json > angular.json.tmp && mv angular.json.tmp sources/GeoNature/frontend/angular.json # Pas une super pratique mais pas d'autre solution pour le moment

submodule_init:
	git submodule update --init --recursive

build:
	build/build.sh

dev: dev_init
	COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml docker compose up -d

prod:
	COMPOSE_FILE=docker-compose.yml docker compose up -d
