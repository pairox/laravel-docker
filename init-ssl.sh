#!/usr/bin/env bash
set -euo pipefail

COMPOSE_CMD="docker compose"
ENV_FILE=".env"

# Load DOMAIN/EMAIL from .env if present
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC2046
  export $(grep -E '^(DOMAIN|EMAIL)=' "$ENV_FILE" | xargs -d'\n' -I{} echo {})
fi

: "${DOMAIN:=}"; : "${EMAIL:=}"
if [[ -z "${DOMAIN}" ]]; then read -rp "Enter DOMAIN (e.g. example.com): " DOMAIN; fi
if [[ -z "${EMAIL}" ]]; then read -rp "Enter EMAIL for Let's Encrypt: " EMAIL; fi
export DOMAIN EMAIL

echo "==> Up services (db, php, nginx:80)"
$COMPOSE_CMD up -d db php nginx

echo "==> Prepare ACME probe"
$COMPOSE_CMD exec -T nginx sh -lc 'mkdir -p /var/www/certbot/.well-known/acme-challenge && echo ok >/var/www/certbot/.well-known/acme-challenge/ping'

echo "==> switch-template"
$COMPOSE_CMD exec  -it nginx sh /docker-entrypoint.d/40-switch-template.sh

echo "==> Restart nginx"
$COMPOSE_CMD restart nginx

echo "==> Wait for http://${DOMAIN}/.well-known/acme-challenge/ping"
for i in {1..30}; do
  if curl -fsS "http://${DOMAIN}/.well-known/acme-challenge/ping" >/dev/null 2>&1; then
    echo "   OK"
    break
  fi
  sleep 2
  if [[ "$i" -eq 30 ]]; then
    echo "ERROR: http not reachable. Check DNS/80 port/firewall/CF proxy."
    exit 1
  fi
done

echo "==> Issue certificate (webroot)"
$COMPOSE_CMD run --rm --entrypoint certbot certbot certonly --webroot -w /var/www/certbot -d "${DOMAIN}" --email "${EMAIL}" --agree-tos --no-eff-email --non-interactive -v

$COMPOSE_CMD restart nginx

echo "==> switch-template"
$COMPOSE_CMD exec  -it nginx sh /docker-entrypoint.d/40-switch-template.sh

echo "==> Restart nginx to enable SSL"
$COMPOSE_CMD restart nginx

echo "==> init"
$COMPOSE_CMD run --rm init

echo "==> chown"
$COMPOSE_CMD exec php sh -lc 'chown -R www-data:www-data storage bootstrap/cache && chmod -R ug+rw storage bootstrap/cache'

echo "==> Done: https://${DOMAIN}"


