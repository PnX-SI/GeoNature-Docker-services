SHELL := /bin/bash
include Makefile.dev
include Makefile.debug

.PHONY: build

launch:
	docker compose up -d

dev_init:
	./init-config.sh
	jq '.projects.geonature.architect.build.configurations.development += {"baseHref": "/geonature/"}' sources/GeoNature/frontend/angular.json > angular.json.tmp && mv angular.json.tmp sources/GeoNature/frontend/angular.json # Pas une super pratique mais pas d'autre solution pour le moment
	source .env; echo "{\"API_ENDPOINT\":\"//$${GEONATURE_BACKEND_HOSTPORT}$${GEONATURE_BACKEND_PREFIX}\"}" > sources/GeoNature/frontend/src/assets/config.json

submodule_init:
	# So the config is right even for a fork
	git config submodule.GeoNature.url https://github.com/PnX-SI/GeoNature/
	git config submodule.UsersHub.url https://github.com/PnX-SI/UsersHub/
	git config submodule.gn_module_export.url https://github.com/PnX-SI/gn_module_export/
	git config submodule.gn_module_dashboard.url https://github.com/PnX-SI/gn_module_dashboard/
	git config submodule.gn_module_monitoring.url https://github.com/PnX-SI/gn_module_monitoring/
	git submodule update --init --recursive --depth 1

build_images:
	build/build.sh

dev: dev_init
	COMPOSE_FILE=essential.yml:traefik.yml:docker-compose.dev.yml docker compose up -d --force-recreate
	source .env; echo "Services de developpement lancés, vous pouvez y acceder sur : https://$${HOSTPORT}$${GEONATURE_FRONTEND_PREFIX}"

prod:
	./init-config.sh
	COMPOSE_FILE=docker-compose.yml docker compose up -d
	source .env; echo "Services de production lancés, vous pouvez y acceder sur : $${BASE_PROTOCOL}://$${HOST}$${GEONATURE_FRONTEND_PREFIX}"

cypress:
	source .env; cd sources/GeoNature/frontend; CYPRESS_baseUrl="https://$${HOSTPORT}$${GEONATURE_FRONTEND_PREFIX}/" API_ENDPOINT="https://$${HOSTPORT}$${GEONATURE_BACKEND_PREFIX}/" URL_APPLICATION="https://$${HOSTPORT}$${GEONATURE_FRONTEND_PREFIX}/" cypress run --headed --spec cypress/e2e/homepage-spec.js

lint_frontend:
	docker compose exec geonature-frontend bash -c "cd /sources/GeoNature/frontend; npm run format"

lint_backend:
	docker compose exec geonature-backend bash -c "source /sources/GeoNature/backend/venv/bin/activate && black /sources/GeoNature/backend"

cypress:
	source .env; cd sources/GeoNature/frontend; CYPRESS_baseUrl="$${BASE_PROTOCOL}://$${HOST}$${GEONATURE_FRONTEND_PREFIX}/" API_ENDPOINT="$${BASE_PROTOCOL}://$${HOST}$${GEONATURE_BACKEND_PREFIX}/" URL_APPLICATION="$${BASE_PROTOCOL}://$${HOST}$${GEONATURE_FRONTEND_PREFIX}/" cypress run

-include Makefile.local