#!/bin/bash

curl -s https://raw.githubusercontent.com/anggasec28/logo/refs/heads/main/logo.sh | bash
sleep 5

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'


show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

show "Menginstall Rust..." "progress"
if ! source <(wget -O - https://raw.githubusercontent.com/anggasec28/modul/refs/heads/main/rust.sh); then
    show "Gagal install Rust." "error"
    exit 1
fi

show "Memperbarui package list..." "progress"
if ! sudo apt update; then
    show "Gagal update package list." "error"
    exit 1
fi

if ! command -v git &> /dev/null; then
    show "Git tidak terinstall. Memulai install git..." "progress"
    if ! sudo apt install git -y; then
        show "Failed to install git." "error"
        exit 1
    fi
else
    show "Git sudah terinstall."
fi

if [ -d "$HOME/network-api" ]; then
    show "Membersihkan repository tidak terpakai..." "progress"
    rm -rf "$HOME/network-api"
fi

sleep 3

show "Cloning repo API Nexus.xyz..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
    show "Failed to clone the repository." "error"
    exit 1
fi

cd $HOME/network-api/clients/cli

show "Menginstal dependensi yang diperlukan..." "progress"
if ! sudo apt install pkg-config libssl-dev -y; then
    show "Gagal menginstall depensi." "error"
    exit 1
fi

if systemctl is-active --quiet nexus.service; then
    show "nexus.service sedang berjalan. Menghentikan dan menonaktifkannya..."
    sudo systemctl stop nexus.service
    sudo systemctl disable nexus.service
else
    show "nexus.service tidak berjalan."
fi

show "Membuat systemd service..." "progress"
if ! sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=Nexus XYZ Prover Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/network-api/clients/cli
Environment=NONINTERACTIVE=1
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.cargo/bin
ExecStart=$HOME/.cargo/bin/cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"; then
    show "Gagal membuat systemd servive file." "error"
    exit 1
fi

show "Memuat ulang systemd dan memulai service..." "progress"
if ! sudo systemctl daemon-reload; then
    show "Gagal memuat ulang systemd." "error"
    exit 1
fi

if ! sudo systemctl start $SERVICE_NAME.service; then
    show "Gagal memulai service." "error"
    exit 1
fi

if ! sudo systemctl enable $SERVICE_NAME.service; then
    show "Gagal mengaktifkan service." "error"
    exit 1
fi

show "Service status:" "progress"
if ! sudo systemctl status $SERVICE_NAME.service; then
    show "Gagal mengambil status service." "error"
fi

show "Sukses ! Semua terinstall dengan baik!"
