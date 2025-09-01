# Laravel + Docker + Nginx + SSL (Let's Encrypt)

Готовая среда для запуска **Laravel** в Docker с автоматическим выпуском и продлением SSL-сертификатов через **Let's Encrypt**.


## 🚀 Установка и запуск

### 1. Подготовка
Установи:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)

Клонируй проект:
```bash
git clone https://github.com/pairox/laravel-docker.git
cd laravel-docker
```

### 2. Настройка окружения
Скопируй пример `.env`:
```bash
cp .env.example .env
```

Пример конфига:
```dotenv
DOMAIN=example.com
EMAIL=admin@example.com

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
DB_ROOT_PASSWORD=rootpass
```
---

### 3. Первый запуск с SSL
```bash
chmod +x init-ssl.sh
bash init-ssl.sh
```

Скрипт:
- поднимет `nginx` на **80** порту,  
- получит сертификат Let's Encrypt через `certbot`,  
- перезапустит `nginx` с HTTPS.  

---

### 4. Автопродление SSL
Подними сервис `certbot`, который каждые 12 часов проверяет сертификаты:
```bash
docker compose up -d certbot
```
