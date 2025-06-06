#!/bin/bash
set -e

# 현재 스크립트 위치
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ======== 환경 변수 불러오기 ========

# 1. 운영용 .env
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  echo "📄 .env 불러오는 중..."
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "❌ .env 파일이 없습니다: $ENV_FILE"
  exit 1
fi

# 2. 백업용 .backup.env
BACKUP_ENV_FILE="$SCRIPT_DIR/.backup.env"
if [ -f "$BACKUP_ENV_FILE" ]; then
  echo "📄 .backup.env 불러오는 중..."
  set -a
  source "$BACKUP_ENV_FILE"
  set +a
else
  echo "❌ .backup.env 파일이 없습니다: $BACKUP_ENV_FILE"
  exit 1
fi

# ======== 백업 경로 구성 ========
BACKUP_UPLOAD_LOCATION="$MOUNT_POINT/upload"
BACKUP_DB_DATA_LOCATION="$MOUNT_POINT/pgdata"

echo "📁 지정된 백업 경로 확인"
if [ ! -d "$BACKUP_UPLOAD_LOCATION" ]; then
  echo "📂 생성: $BACKUP_UPLOAD_LOCATION"
  sudo mkdir -p "$BACKUP_UPLOAD_LOCATION"
fi
if [ ! -d "$BACKUP_DB_DATA_LOCATION" ]; then
  echo "📂 생성: $BACKUP_DB_DATA_LOCATION"
  sudo mkdir -p "$BACKUP_DB_DATA_LOCATION"
fi

# ======== 백업 시작 ========
echo "📦 Immich 백업 시작: $(date)"

sudo rsync -a --delete "$UPLOAD_LOCATION/" "$BACKUP_UPLOAD_LOCATION/"
echo "✅ 사진(upload) 백업 완료"

sudo rsync -a --delete "$DB_DATA_LOCATION/" "$BACKUP_DB_DATA_LOCATION/"
echo "✅ DB(pgdata) 백업 완료"

echo "🎉 Immich 백업 완료: $(date)"

# upload 백업 및 로그 저장
sudo rsync -a --delete --itemize-changes "$UPLOAD_LOCATION/" "$BACKUP_UPLOAD_LOCATION/" > /tmp/rsync_upload.log

# 변화 분석
added=$(grep '^>f' /tmp/rsync_upload.log | grep '+++++++++' | wc -l)
deleted=$(grep '^*deleting' /tmp/rsync_upload.log | wc -l)
modified=$(grep '^>f' /tmp/rsync_upload.log | grep -v '+++++++++' | wc -l)

echo "✅ 사진(upload) 백업 완료"
echo "📊 업로드 변화 요약: ➕ $added | 🗑️ $deleted | ✏️ $modified"
