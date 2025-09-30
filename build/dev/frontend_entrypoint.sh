#!/bin/bash
npm install

# We need to install external modules dependencies
if [ -d "external_modules" ]; then
  for dir in external_modules/*; do
    if [ -d "$dir" ]; then
      echo "Installation of dependencies $dir"
      (cd "$dir" && npm install)
    fi
  done
fi
npm run start -- --host 0.0.0.0 --port 80