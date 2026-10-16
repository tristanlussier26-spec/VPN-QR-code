#!/usr/bin/env bash
# Installe la page sur un Raspberry Pi (ou n'importe quel Debian/Ubuntu), sans Docker.
# Un petit service Python sert la page et garde les cartes dans /var/lib/cartes-vpn.
# Usage : sudo ./install-pi.sh [port]     (port par défaut : 8080)
# Relance la même commande après un « git pull » pour mettre à jour : les cartes sont gardées.
set -euo pipefail
PORT="${1:-8080}"
DIR=/opt/cartes-vpn
DATA=/var/lib/cartes-vpn
SRC="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then echo "Lance-le avec sudo : sudo $0 $PORT"; exit 1; fi
command -v python3 >/dev/null || { apt-get update -qq && apt-get install -y -qq python3 >/dev/null; }

# Ancienne version (nginx) : on libère le port
if [ -e /etc/nginx/sites-enabled/cartes-vpn ]; then
  rm -f /etc/nginx/sites-enabled/cartes-vpn /etc/nginx/sites-available/cartes-vpn
  systemctl reload nginx 2>/dev/null || true
fi

id cartes-vpn >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin cartes-vpn
mkdir -p "$DIR/vendor" "$DATA"
cp "$SRC/index.html" "$SRC/server.py" "$DIR/"
cp "$SRC"/vendor/*.js "$DIR/vendor/"
chown -R cartes-vpn:cartes-vpn "$DATA"
chmod 700 "$DATA"

cat > /etc/systemd/system/cartes-vpn.service <<UNIT
[Unit]
Description=Cartes de licence VPN
After=network-online.target

[Service]
User=cartes-vpn
ExecStart=/usr/bin/python3 ${DIR}/server.py --port ${PORT} --data ${DATA}
Restart=on-failure
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=${DATA}
ProtectHome=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable cartes-vpn >/dev/null 2>&1
systemctl restart cartes-vpn

IP="$(hostname -I | awk '{print $1}')"
echo
echo "C'est prêt : http://${IP}:${PORT}"
echo "Les cartes sont gardées dans ${DATA}/cards.json"
