docker build -f Dockerfile-geonature-frontend -t ghcr.io/pnx-si/geonature-frontend:develop .

docker build -f Dockerfile-geonature-backend -t ghcr.io/pnx-si/geonature-backend:develop .

docker-compose --env-file=.env.dev up