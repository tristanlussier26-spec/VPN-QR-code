# VPN-QR-code

Petite page web qui génère des **cartes de licence WireGuard** à donner à tes amis : un code QR, les infos de connexion et les instructions d'installation pour **iPhone** et **Android**. Chaque carte s'exporte en **PDF** (une carte par page Letter, avec un trait de coupe).

**En ligne :** https://tristanlussier26-spec.github.io/VPN-QR-code/

Pensé pour un serveur [wg-easy](https://github.com/wg-easy/wg-easy), mais ça marche avec n'importe quel fichier `.conf` WireGuard.

## Installer sur un Raspberry Pi (accès par IP)

Sur le Pi, un petit serveur Python (sans dépendance) sert la page et **enregistre les cartes** dans un fichier JSON. Tu les retrouves donc depuis n'importe quel appareil de ton réseau. Les librairies sont dans `vendor/` : pas besoin d'Internet.

### Option A : Docker

```bash
git clone https://github.com/tristanlussier26-spec/VPN-QR-code.git
cd VPN-QR-code
docker compose up -d --build
```

Les cartes sont gardées dans `VPN-QR-code/data/cards.json`.

### Option B : sans Docker (service systemd)

```bash
git clone https://github.com/tristanlussier26-spec/VPN-QR-code.git
cd VPN-QR-code
sudo ./install-pi.sh 8080
```

Les cartes sont gardées dans `/var/lib/cartes-vpn/cards.json`. Si tu avais l'ancienne version avec nginx, le script la retire tout seul.

Ouvre ensuite `http://IP-DU-PI:8080`.

### Mettre à jour (les cartes sont gardées)

```bash
cd VPN-QR-code && git pull
docker compose up -d --build      # option A
sudo ./install-pi.sh 8080         # option B
```

### Sécurité

Les cartes contiennent les clés privées WireGuard de tes amis. N'ouvre **pas** ce port sur Internet : la page n'a pas de mot de passe. Garde-la sur ton réseau local (ou accessible seulement par le VPN), et sauvegarde `cards.json` comme un fichier de mots de passe.

## Cartes enregistrées

- Chaque carte créée est enregistrée tout de suite : sur le serveur du Pi, ou dans le navigateur si la page est ouverte sans serveur (GitHub Pages, fichier local).
- Tu les vois toutes à droite, avec une recherche par nom ou par numéro.
- Pour chaque carte : PDF, fichier `.conf`, message texte à copier.
- « Retirer » demande une confirmation, puis supprime la carte pour de bon.

## Personnaliser la carte

Dans la section « Personnaliser la carte » : nom du VPN, couleur, vitesse affichée (vide = cachée), ton contact (nom, téléphone ou courriel) et les règles (une par ligne). Tout est retenu dans ton navigateur et s'applique aux cartes, au PDF et au message texte. Le bouton « Remettre par défaut » remet les valeurs d'origine.

## Utilisation

1. Ouvre la page : sur ton Pi (`http://IP-DU-PI:8080`), sur GitHub Pages, ou `index.html` directement dans ton navigateur.
2. Choisis le **nom de ton VPN** (retenu dans ton navigateur).
3. Dans wg-easy, télécharge le fichier `.conf` du client, puis **importe-le** dans la page (ou glisse-le dessus).
   Un nom de fichier comme `license-n001.conf` remplit le numéro de licence tout seul.
4. Écris le nom de l'ami, choisis son appareil (iPhone, Android ou les deux), une date de fin si tu veux.
5. **Créer la carte**, puis **Télécharger en PDF** ou **Copier le message texte**.

## Confidentialité

Tout se passe dans ton navigateur : aucune config n'est envoyée ni enregistrée, et les cartes disparaissent quand tu fermes la page.
Le code QR contient la **clé privée** du client : traite chaque carte comme un mot de passe.
Pour retirer un accès, désactive ou supprime le client dans wg-easy.

## Technique

Un fichier HTML et un petit serveur Python (`server.py`, bibliothèque standard seulement), sans build ni base de données. Les librairies sont incluses dans `vendor/` (licences MIT, fichiers de licence à côté) :
[qrcode-generator](https://github.com/kazuhikoarase/qrcode-generator) 1.4.4 et [jsPDF](https://github.com/parallax/jsPDF) 2.5.1.
La police vient de Google Fonts quand Internet est disponible ; sinon, la police du système prend le relais.

## Licence

MIT
