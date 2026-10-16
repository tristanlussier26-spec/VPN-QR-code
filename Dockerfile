# Sert la page avec nginx. Marche sur Raspberry Pi (arm64/armv7) et sur PC (amd64).
FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
COPY vendor/ /usr/share/nginx/html/vendor/
EXPOSE 80
