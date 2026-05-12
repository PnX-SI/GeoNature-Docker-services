#!/bin/bash

if [ "${GEONATURE_SKIP_POPULATE_DB}" != "true" ]; then
    echo "Modules to install: $(ls -d /sources/gn_*/ | sort)"
    for module in $(ls -d /sources/gn_*/ | sort); do
        [ -d "$module" ] && pip install -e "$module"
    done
fi

. /entrypoint.sh