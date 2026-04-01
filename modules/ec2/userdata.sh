#!/bin/bash
set -e

# ── System update ──────────────────────────────────────────────────────────────
apt-get update -y
apt-get upgrade -y

# ── Install dependencies ───────────────────────────────────────────────────────
apt-get install -y python3.11 python3.11-venv python3-pip nginx mysql-server nodejs npm git curl

# ── Start and secure MySQL ─────────────────────────────────────────────────────
systemctl start mysql
systemctl enable mysql

mysql -u root <<-MYSQL
  CREATE DATABASE IF NOT EXISTS ${db_name};
  CREATE USER IF NOT EXISTS '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
  GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';
  FLUSH PRIVILEGES;
MYSQL

# ── Create app directory ───────────────────────────────────────────────────────
mkdir -p /app/backend
mkdir -p /app/frontend

# ── Write backend .env ─────────────────────────────────────────────────────────
cat > /app/backend/.env <<-ENV
ENVIRONMENT=prod
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
BACKEND_PORT=${backend_port}
ENV

# ── Create deploy scripts ──────────────────────────────────────────────────────
cat > /app/deploy-backend.sh <<-'SH'
#!/bin/bash
cd /app/backend
python3.11 -m venv .venv
.venv/bin/pip install -q -r requirements.txt
.venv/bin/python migrate.py
pkill -f "uvicorn" || true
nohup .venv/bin/python main.py > /var/log/backend.log 2>&1 &
echo "Backend started"
SH

cat > /app/deploy-frontend.sh <<-'SH'
#!/bin/bash
cd /app/frontend
npm install
npm run build
cp -r dist/* /var/www/html/
echo "Frontend deployed"
SH

chmod +x /app/deploy-backend.sh
chmod +x /app/deploy-frontend.sh

# ── Configure nginx ────────────────────────────────────────────────────────────
cat > /etc/nginx/sites-available/default <<-'NGINX'
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health {
        proxy_pass http://127.0.0.1:8000/health;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINX

systemctl restart nginx
systemctl enable nginx

echo "EC2 setup complete"