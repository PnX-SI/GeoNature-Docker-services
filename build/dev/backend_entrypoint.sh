#!/bin/bash

for module in $(ls -d /sources/gn_*/ | sort);   do \
    [ -d "$module" ] &&  geonature install-gn-module "$module" --build false ; \
done

. /entrypoint.sh