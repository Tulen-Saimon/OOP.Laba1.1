#!/bin/bash
set -e

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Установка 3proxy через Docker ===${NC}"

# 1. Запрос логина и пароля
read -p "Введите логин: " LOGIN
read -s -p "Введите пароль: " PASSWORD
echo

# Проверка на пустые значения
if [[ -z "$LOGIN" || -z "$PASSWORD" ]]; then
    echo -e "${RED}Ошибка: логин и пароль не могут быть пустыми${NC}"
    exit 1
fi

# 2. Проверка наличия необходимых утилит
for cmd in wget tar docker; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Ошибка: $cmd не найден. Установите его и повторите запуск.${NC}"
        exit 1
    fi
done

# 3. Определение команды Docker Compose
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}Ошибка: Docker Compose не найден. Установите его.${NC}"
    exit 1
fi

# 4. Переход в /home и подготовка рабочей директории
cd /home || { echo -e "${RED}Не удалось перейти в /home${NC}"; exit 1; }

if [[ -d "3proxy" ]]; then
    echo "Директория /home/3proxy уже существует. Удаляем..."
    rm -rf 3proxy
fi
mkdir 3proxy
cd 3proxy || exit 1

# 5. Скачивание и распаковка исходников 3proxy
echo "Скачиваем 3proxy..."
wget -q --show-progress https://github.com/3proxy/3proxy/archive/refs/tags/0.9.5.tar.gz
tar xzf 0.9.5.tar.gz
rm 0.9.5.tar.gz

# 6. Создание конфигурационного файла 3proxy.cfg с подстановкой логина и пароля
echo "Создаём 3proxy.cfg..."
cat > 3proxy.cfg.template <<'EOF'
maxconn 1000
flush
nserver 8.8.8.8
nscache 65536
timeouts 1 5 30 60 180 1800 15 60

log /dev/stdout
logformat "- +_L %h %U %p %E %T"

auth strong
users <LOGIN>:CA:<PASSWORD>

allow <LOGIN>

socks -p1080
EOF

# Замена плейсхолдеров на реальные данные
sed -i "s/<LOGIN>/$LOGIN/g; s/<PASSWORD>/$PASSWORD/g" 3proxy.cfg.template
mv 3proxy.cfg.template 3proxy.cfg

# 7. Создание Dockerfile
echo "Создаём Dockerfile..."
cat > Dockerfile <<'EOF'
FROM debian:12 AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget

COPY 3proxy-0.9.5/ /tmp/3proxy
WORKDIR /tmp/3proxy

RUN make -f Makefile.Linux

FROM debian:12-slim

COPY --from=build /tmp/3proxy/bin/3proxy /usr/local/bin/3proxy

COPY 3proxy.cfg /etc/3proxy/3proxy.cfg

CMD ["3proxy", "/etc/3proxy/3proxy.cfg"]
EOF

# 8. Создание docker-compose.yaml
echo "Создаём docker-compose.yaml..."
cat > docker-compose.yaml <<'EOF'
services:
  3proxy:
    build: .
    ports:
      - "1080:1080"
    restart: "always"
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
EOF

# 9. Сборка и запуск контейнера
echo -e "${GREEN}Собираем и запускаем контейнер...${NC}"
$COMPOSE_CMD up -d --build

# 10. Проверка статуса
echo -e "${GREEN}Готово! Контейнер запущен.${NC}"
echo "Проверить состояние: docker ps"
echo "Логи: docker compose logs 3proxy"
echo "Прокси доступен на порту 1080 с логином $LOGIN"
