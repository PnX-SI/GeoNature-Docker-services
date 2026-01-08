#!/bin/bash

echo "Modules to install: $(ls -d /sources/gn_*/ | sort)"
for module in $(ls -d /sources/gn_*/ | sort); do
    [ -d "$module" ] && pip install -e "$module"
done
echo "Dependencies to install: $(ls -d /sources/GeoNature/backend/dependencies/* | sort)"
for dependencies in $(ls -d /sources/GeoNature/backend/dependencies/* | sort); do
    [ -d "$dependencies" ] && pip install -e "$dependencies"
done
echo "Contribs to install: $(ls -d /sources/GeoNature/backend/dependencies/* | sort)"
for contrib in $(ls -d /sources/GeoNature/contrib/* | sort); do
    [ -d "$contrib" ] && pip install -e "$contrib"
done
. /entrypoint.sh