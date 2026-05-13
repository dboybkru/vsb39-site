# vsb39.ru — сайт интегратора систем безопасности

Основной сайт ВСБ39 (Калининград). Single-page приложение на чистом HTML/CSS/JS.

## Структура репозитория

```
web/
  index.html        — главный SPA сайта (продается через nginx из /var/www/vsb39/html/)
  vsb39-to.html     — заглушка для ТО (на проде /to/ обрабатывает React-приложение)
  robots.txt        — снимок (в проде генерируется бэкендом /opt/Smeta_app/backend)
  sitemap.xml       — снимок (в проде генерируется бэкендом)

nginx/
  vsb39.conf        — конфиг nginx (`/etc/nginx/sites-enabled/vsb39`)

backend-rules/
  rules.md          — правила подбора оборудования (CCTV / СКУД / ОПС / СКС / Питание)
                      Живёт в smeta-backend и подмешивается в системный промпт AI.
```

## Связанные репозитории

- [Smeta_app](https://github.com/dboybkru/Smeta_app) — FastAPI-бэкенд (Smeta, AI, leads,
  site_settings, seo_pages, SCKUD/OS calculator). Картирует `/api/smeta/*`.
- [TO_Claude_Kimi](https://github.com/dboybkru/TO_Claude_Kimi) — React-приложение
  системы ТО (SecureTO). Картирует `/to/*`.

## Архитектура продакшна

```
nginx (хост) — 443/80
├─ /                     → /var/www/vsb39/html/index.html (этот репо, web/)
├─ /sitemap.xml          → proxy → smeta-backend (генерируется из БД)
├─ /robots.txt           → proxy → smeta-backend
├─ /to/                  → proxy → secureto-frontend (Docker, React)
├─ /api/v1/              → proxy → secureto-backend (Docker, FastAPI)
└─ /api/smeta/           → proxy → smeta-backend (Docker, FastAPI + SQLite)
```

## Деплой главного сайта

```bash
ssh root@vsb39.ru
cp web/index.html /var/www/vsb39/html/index.html
nginx -t && systemctl reload nginx  # для конфига
```

## Особенности

- **No-cache** на `/` и `/index.html` (nginx) — клиенты всегда получают свежую страницу.
- **Динамические настройки** через `site_settings` (контакты, ИНН, Yandex.Maps API,
  Метрика, GA, robots.txt, SEO meta для разделов). Редактируются в админке через
  `/api/smeta/site/settings` и `/api/smeta/seo/pages`.
- **AI-консультант** на главной + странице поддержки. Промпт включает каталог,
  историю диалога и `rules.md`.

## Локальная разработка

`index.html` — самодостаточный файл. Для просмотра достаточно `python3 -m http.server`
в `web/`. API-вызовы (`/api/smeta/*`) идут на продовый домен — для локального теста
запустите бэкенд из соседнего репо или поменяйте `vsbAdmin.api` base URL.

## Лицензия

Proprietary © ВСБ39
