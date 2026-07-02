#!/bin/bash

cd /dist/atlas/static && npm ci --omit=dev

gunicorn -b 0.0.0.0:8080 "atlas.app:create_app()" --reload --reload-extra-file="/dist/atlas/configuration/config.py"