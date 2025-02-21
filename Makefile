SHELL := /bin/bash

launch:
	docker compose up -d

dev_init:
	source .env; echo "{\"API_ENDPOINT\":\"//localhost$${GEONATURE_BACKEND_PREFIX}\"}" > sources/GeoNature/frontend/src/assets/config.json

submodule_init:
	git submodule update --init --recursive

build:
	build/build.sh

dev: dev_init
	COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml docker compose up -d --force-recreate
	source .env; echo "Services de developpement lancés, vous pouvez y acceder sur : https://$${HOST}$${GEONATURE_FRONTEND_PREFIX}"

prod:
	./init-config.sh
	COMPOSE_FILE=docker-compose.yml docker compose up -d
	source .env; echo "Services de production lancés, vous pouvez y acceder sur : https://$${HOST}$${GEONATURE_FRONTEND_PREFIX}"
