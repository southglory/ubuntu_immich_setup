#!/bin/bash
set -e

echo "📦 Immich 공식 설치 시작"

# 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPLOAD_DIR="$SCRIPT_DIR/upload"
PGDATA_DIR="$SCRIPT_DIR/pgdata"
ENV_FILE="$SCRIPT_DIR/.env"

# Docker 설치
if ! command -v docker &> /dev/null; then
  echo "🔧 Docker 설치 중..."
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release docker.io
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
fi

# Docker Compose plugin 설치
if ! docker compose version &> /dev/null; then
  echo "🔧 Docker Compose Plugin 설치 중..."
  COMPOSE_DIR="/usr/libexec/docker/cli-plugins"
  sudo mkdir -p "$COMPOSE_DIR"
  curl -SL https://github.com/docker/compose/releases/download/v2.24.4/docker-compose-linux-x86_64 -o docker-compose
  chmod +x docker-compose
  sudo mv docker-compose "$COMPOSE_DIR/docker-compose"
fi

# 디렉토리 생성
mkdir -p "$UPLOAD_DIR" "$PGDATA_DIR"

# .env 처리
if [ -f "$ENV_FILE" ]; then
  echo "⚠️  기존 .env 파일이 이미 존재합니다."
  read -p "📌 그대로 사용하시겠습니까? (Y/n): " use_existing
  if [[ "$use_existing" =~ ^[Nn]$ ]]; then
    read -p "⚠️  새로 만들까요? (Y/n): " create_new
    if [[ "$create_new" =~ ^[Nn]$ ]]; then
      echo "❌ .env 파일을 변경하지 않고 종료합니다."
      exit 0
    else
      echo "✏️ 기존 파일을 덮어쓰고 새로 생성합니다..."
      cat > "$ENV_FILE" <<EOF
UPLOAD_LOCATION=$UPLOAD_DIR
DB_USERNAME=immich
DB_PASSWORD=immichpass
DB_DATABASE_NAME=immich
DB_DATA_LOCATION=$PGDATA_DIR
EOF
      echo "✅ .env 파일 생성 완료"
    fi
  else
    echo "✅ 기존 파일을 그대로 사용합니다."
    # 아무것도 하지 않고 그대로 진행
  fi
else
  echo "📄 .env 파일이 없으므로 새로 생성합니다..."
  cat > "$ENV_FILE" <<EOF
UPLOAD_LOCATION=$UPLOAD_DIR
DB_USERNAME=immich
DB_PASSWORD=immichpass
DB_DATABASE_NAME=immich
DB_DATA_LOCATION=$PGDATA_DIR
EOF
  echo "✅ .env 파일 생성 완료"
fi

# docker-compose.yml 다운로드
echo "📥 공식 docker-compose.yml 다운로드"
curl -L --retry 3 -o docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml

# Immich 실행
echo "🚀 Immich 실행 중..."
docker compose up -d

# 도커 컨테이너 목록 확인
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 방화벽 설정 (UFW)
if ! command -v ufw &> /dev/null; then
  sudo apt install -y ufw
fi
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 2283/tcp comment 'Immich Web Port'
sudo ufw --force enable
sudo ufw status numbered

echo "✅ 설치 완료: http://<서버IP>:2283 접속"
