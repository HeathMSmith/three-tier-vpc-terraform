#!/bin/bash
set -euo pipefail

dnf -y update
dnf -y install httpd

cat >/var/www/html/index.html <<'EOF'
<!doctype html>
<html>
<head><title>Three-Tier VPC</title></head>
<body>
  <h1>It works ✅</h1>
  <p><b>Instance:</b> __HOST__</p>
  <p><b>Time:</b> __TIME__</p>
</body>
</html>
EOF

HOSTNAME_VAL="$(hostname)"
TIME_VAL="$(date -Is)"
sed -i "s/__HOST__/${HOSTNAME_VAL}/g" /var/www/html/index.html
sed -i "s/__TIME__/${TIME_VAL}/g" /var/www/html/index.html

systemctl enable httpd
systemctl restart httpd