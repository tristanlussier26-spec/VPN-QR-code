# VPN-QR-code

Petite page web qui génère des **cartes de licence WireGuard** à donner à tes amis : un code QR, les infos de connexion et les instructions d'installation pour **iPhone** et **Android**. Chaque carte s'exporte en **PDF** (une carte par page Letter, avec un trait de coupe).

**En ligne :** https://tristanlussier26-spec.github.io/VPN-QR-code/

Pensé pour un serveur [wg-easy](https://github.com/wg-easy/wg-easy), mais ça marche avec n'importe quel fichier `.conf` WireGuard.

## Utilisation

1. Ouvre la page (GitHub Pages ou `index.html` directement dans ton navigateur).
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

Un seul fichier HTML, sans serveur ni build.
Librairies chargées depuis cdnjs : [qrcode-generator](https://github.com/kazuhikoarase/qrcode-generator) 1.4.4 et [jsPDF](https://github.com/parallax/jsPDF) 2.5.1.

## Licence

MIT
