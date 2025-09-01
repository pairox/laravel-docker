#!/bin/sh
set -e

T_HTTP="/etc/nginx/templates/default.http.template"
T_SSL="/etc/nginx/templates/default.ssl.template"
T_TARGET="/etc/nginx/templates/default.conf.template"
CERT="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"

echo "[switch] DOMAIN=${DOMAIN}"

if [ -n "${DOMAIN}" ] && [ -f "${CERT}" ]; then
  echo "[switch] cert found: ${CERT} -> use SSL template"
  cp -f "${T_SSL}" "${T_TARGET}"
else
  echo "[switch] cert not found -> use HTTP template"
  cp -f "${T_HTTP}" "${T_TARGET}"
fi
