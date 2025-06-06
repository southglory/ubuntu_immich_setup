#!/bin/bash
set -e

# 현재 스크립트 위치
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ======== 환경 변수 불러오기 ========
# 백업용 .backup.env
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

# [1] UUID 확인
UUID=$(blkid -s UUID -o value "$DEVICE")
if [ -z "$UUID" ]; then
    echo "❌ UUID를 찾을 수 없습니다: $DEVICE"
    exit 1
fi

# [2] 마운트 포인트 생성
if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
    echo "📁 마운트 디렉토리 생성: $MOUNT_POINT"
fi

# [3] fstab 등록
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID $MOUNT_POINT ext4 defaults 0 2" | sudo tee -a /etc/fstab
    echo "✅ fstab에 자동 마운트 항목 추가 완료"
else
    echo "ℹ️ fstab에 이미 UUID 등록되어 있음"
fi

# [4] 마운트 적용
sudo mount -a && echo "✅ mount -a 완료. 자동 마운트 적용됨."

# [5] 권한 설정 (선택)
if [[ "$1" == "--set-owner" ]]; then
    sudo chown -R 1000:1000 "$MOUNT_POINT"
    echo "✅ 권한 설정 완료 (UID:GID = 1000:1000)"
else
    echo "ℹ️ 권한 설정 생략됨 (컨테이너가 root 실행 중이면 생략해도 무방)"
fi

echo "🎉 자동 마운트 설정이 완료되었습니다."
