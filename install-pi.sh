#!/usr/bin/env bash
# Installe la page sur un Raspberry Pi (ou n'importe quel Debian/Ubuntu) avec nginx, sans Docker.
# Usage : sudo ./install-pi.sh [port]     (port par défaut : 8080)
set -euo pipefail
PORT="${1:-8080}"
DIR=/var/www/cartes-vpn
SRC="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then echo "Lance-le avec sudo : sudo $0 $PORT"; exit 1; fi

apt-get update -qq
apt-get install -y -qq nginx >/dev/null

mkdir -p "$DIR/vendor"
cp "$SRC/index.html" "$DIR/"
cp "$SRC"/vendor/*.js "$DIR/vendor/"

cat > /etc/nginx/sites-available/cartes-vpn <<NGINX
server {
    listen ${PORT};
    listen [::]:${PORT};
    root ${DIR};
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
}
NGINX
ln -sf /etc/nginx/sites-available/cartes-vpn /etc/nginx/sites-enabled/cartes-vpn
nginx -t
systemctl enable --now nginx >/dev/null
systemctl reload nginx

IP="$(hostname -I | awk '{print $1}')"
echo
echo "C'est prêt : http://${IP}:${PORT}"
