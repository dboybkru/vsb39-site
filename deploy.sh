#!/bin/bash
# Деплой главного сайта vsb39.ru:
#  - git pull
#  - копирование файлов из репо в продакшн
#  - перезагрузка nginx (если конфиг менялся)
#  - копирование rules.md в Smeta_app
set -e
cd /opt/vsb39-site

# Не теряем локальные правки случайно
git fetch origin
CHANGES=$(git status --short)
if [ -n "$CHANGES" ]; then
  echo "WARN: рабочая директория грязная — пропускаю git pull"
  echo "$CHANGES"
else
  git pull origin main
fi

CHANGED=0

# Главная страница
if ! cmp -s web/index.html /var/www/vsb39/html/index.html; then
  cp web/index.html /var/www/vsb39/html/index.html
  echo "✓ index.html обновлён"
  CHANGED=1
fi

# Доп. статика
for f in vsb39-to.html robots.txt sitemap.xml; do
  if [ -f web/$f ] && ! cmp -s web/$f /var/www/vsb39/html/$f 2>/dev/null; then
    cp web/$f /var/www/vsb39/html/$f
    echo "✓ $f обновлён"
    CHANGED=1
  fi
done

# rules.md → Smeta_app
if ! cmp -s backend-rules/rules.md /opt/Smeta_app/backend/rules.md; then
  cp backend-rules/rules.md /opt/Smeta_app/backend/rules.md
  echo "✓ rules.md обновлён в Smeta_app"
  CHANGED=1
fi

# nginx
NGINX_RELOADED=0
if ! cmp -s nginx/vsb39.conf /etc/nginx/sites-enabled/vsb39; then
  cp nginx/vsb39.conf /etc/nginx/sites-enabled/vsb39
  if nginx -t 2>&1 | tail -2; then
    systemctl reload nginx
    echo "✓ nginx-конфиг обновлён и перезагружен"
    NGINX_RELOADED=1
  else
    echo "✗ nginx -t failed — откатываю"
    cd /opt/vsb39-site && git checkout HEAD -- nginx/vsb39.conf
    cp nginx/vsb39.conf /etc/nginx/sites-enabled/vsb39
    exit 1
  fi
  CHANGED=1
fi

if [ "$CHANGED" -eq 0 ]; then
  echo "Нечего деплоить, всё актуально."
else
  echo "Деплой завершён."
fi
