SHELL := /bin/bash

lint_frontend:
	docker compose exec geonature-frontend bash -c "cd /sources/GeoNature/frontend; npm run format"

lint_backend:
	docker compose exec geonature-backend bash -c "black /sources/GeoNature/backend"

cypress:
	source .env; cd sources/GeoNature/frontend; CYPRESS_baseUrl="$${GEONATURE_URL_APPLICATION}" API_ENDPOINT="$${GEONATURE_API_ENDPOINT}/" URL_APPLICATION="$${GEONATURE_URL_APPLICATION}" npm run cypress:open

install_monitoring_module:
	@if [ -z "$(MODULE_PATH)" ]; then \
		echo "Error : Specify MODULE_PATH=<path> example: make install_monitoring_module MODULE_PATH=sources/gn_module_monitoring/contrib/sites_group_aside/"; \
		exit 1; \
	fi; \
	MODULE_NAME=$$(basename "$${MODULE_PATH}"); \
	cp -r $(MODULE_PATH) data/geonature/media/monitorings/${MODULE_NAME} && \
	docker compose exec geonature-backend geonature monitorings install "$${MODULE_NAME}"


-include Makefile.local
