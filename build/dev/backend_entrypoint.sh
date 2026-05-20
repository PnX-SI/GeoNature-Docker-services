#!/bin/bash

cd /sources/GeoNature/backend && uv pip install --system -r requirements-dev.txt

echo "Modules to install: $(ls -d /sources/gn_*/ | sort)"
for module in $(ls -d /sources/gn_*/ | sort); do
    [ -d "$module" ] && uv pip install --system -e "$module"
done
echo "Contribs to install: $(ls -d /sources/GeoNature/contrib/* | sort)"
for contrib in $(ls -d /sources/GeoNature/contrib/* | sort); do
    [ -d "$contrib" ] && uv pip install --system -e "$contrib"
done
. /entrypoint.sh