#!/usr/bin/env bash
set -euo pipefail

# Valeurs par défaut si non passées par l'env
: "${IMPORT_ALTI:=false}"
: "${ALTI_URL:=https://geonature.fr/data/ign/BDALTIV2_2-0_250M_ASC_LAMB93-IGN69_FRANCE_2017-06-21.zip}"
: "${ALTI_SCHEMA:=ref_geo}"
: "${ALTI_TABLE:=dem}"
: "${ALTI_SRID:=2154}"

if [ "${IMPORT_ALTI}" != "true" ]; then
  echo "[alti-loader] IMPORT_ALTI != true, rien à faire."
  exit 0
fi


echo "[alti-loader] Préparation…"
mkdir -p /work /tmp/alti
cd /work

URL="${ALTI_URL}"
FILE="$(basename "$URL")"

if [ ! -f "$FILE" ]; then
  echo "[alti-loader] Téléchargement $URL…"
  curl -L "$URL" -o "$FILE"
else
  echo "[alti-loader] Zip déjà présent, on réutilise: $FILE"
fi

echo "[alti-loader] Décompression…"
rm -rf /tmp/alti/*
unzip -o "$FILE" -d /tmp/alti >/dev/null

ASC_PATH="$(find /tmp/alti -type f -name "*.asc" | head -n1)"
if [ -z "${ASC_PATH}" ]; then
  echo "[alti-loader] ERREUR: aucun .asc trouvé."
  exit 1
fi
echo "[alti-loader] ASC: $ASC_PATH"


echo "[alti-loader] Import raster → ${ALTI_SCHEMA}.${ALTI_TABLE} (SRID=${ALTI_SRID})…"
#Ajuste -t si besoin (carrelage). 5x5 peut être très fragmenté.
raster2pgsql -s "${ALTI_SRID}" -c -C -I -M -d -t 5x5 \
  "${ASC_PATH}" "${ALTI_SCHEMA}.${ALTI_TABLE}" \
  | PGPASSWORD="${POSTGRES_PASSWORD}" psql \
      -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" \
      -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"

# --- REINDEX optionnel ---------------------------------------------------------
if [ "${ALTI_REINDEX:-false}" = "true" ]; then
  echo "[alti-loader] REINDEX de l’index de convex hull…"
  IDX_NAME="${ALTI_SCHEMA}.${ALTI_TABLE}_st_convexhull_idx"

  # Teste l'existence de l'index (retourne 't' ou 'f')
    EXISTS="$(
    PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
        -At -c "SELECT to_regclass('${IDX_NAME}') IS NOT NULL;"
    )"


  if [ "${EXISTS}" = "t" ]; then
    if [ "${ALTI_REINDEX_CONCURRENTLY:-false}" = "true" ]; then
      # CONCURRENTLY interdit dans une transaction implicite -> commande dédiée
      PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
        -v ON_ERROR_STOP=1 \
        -c "REINDEX INDEX CONCURRENTLY ${IDX_NAME};"
    else
      PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
        -v ON_ERROR_STOP=1 \
        -c "REINDEX INDEX ${IDX_NAME};"
    fi
    echo "[alti-loader] REINDEX OK."
  else
    echo "[alti-loader] Index ${IDX_NAME} introuvable (peut-être pas d’option -I à l’import ?)."
  fi
fi
# ------------------------------------------------------------------------------

echo "[alti-loader] Terminé ✔"
