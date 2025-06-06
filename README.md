# Immich One-Click Ubuntu Setup with HDD Backup

This project provides a one-click setup experience for [immich-app/immich](https://github.com/immich-app/immich), designed specifically for Ubuntu environments. It supports automatic Docker-based deployment, external HDD mounting, and secure photo/database backup using `rsync`.

---

## 📦 Features

- Official Immich deployment using Docker Compose
- `.env` auto-generation during installation
- External HDD mount and `/etc/fstab` registration automation
- Photo and DB backup using `rsync`
- Idempotent script structure (safe to re-run)

---

## 🚀 How to Use

1. **Grant execute permission to scripts**

   ```bash
   chmod +x install_immich.sh setup_mount_immich.sh backup_immich.sh
    ````

2. **Install Immich and generate `.env`**

   ```bash
   ./install_immich.sh
   ```

   This will download the official Docker Compose file, create upload/pgdata folders, and auto-generate the `.env` file.

3. **Create your own `.backup.env` based on your system**

   Example:

   ```env
   DEVICE=/dev/sda3
   MOUNT_POINT=/mnt/immich-backups
   ```

4. **Mount and register the external HDD**

   ```bash
   ./setup_mount_immich.sh
   ```

   This script will:

   * Retrieve UUID of your device
   * Append it to `/etc/fstab`
   * Mount the disk
   * (Optionally) set ownership with `--set-owner`

5. **Run backup**

   ```bash
   ./backup_immich.sh
   ```

   This backs up:

   * `UPLOAD_LOCATION` (from `.env`) to `$MOUNT_POINT/upload`
   * `DB_DATA_LOCATION` (from `.env`) to `$MOUNT_POINT/pgdata`

---

## 📝 Notes

* This repository does **not** contain Immich source code. It downloads the latest [official Docker Compose file](https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml) on installation.
* `.env` is generated automatically; `.backup.env` must be created manually to fit your hardware setup.
* Scripts use `sudo` for mount, mkdir, and `rsync` where required.

---

> ⚠️ **Important Security Note:**  
> This server **must be connected behind a router**.  
> Do **not** port-forward port `2283` under any circumstances.  
> Use a VPN (e.g., WireGuard) or Cloudflare Tunnel for remote access instead.

---

## 🙌 Contributions

Feel free to open an issue or pull request if you'd like to improve or extend this setup.

```

