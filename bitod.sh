#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

display_header() {
    clear
    echo -e "${BLUE}"
    curl -s --fail https://raw.githubusercontent.com/xxchoxx/soudness/main/logo.sh || echo "Failed to load logo"
    echo -e "${NC}"
    sleep 1
}

get_seed_phrase() {
    echo -e "${YELLOW}"
    echo -e "\nMasukkan seed phrase wallet Anda inget jangan kontolu yang dimasukin:"
    read -rp "> " seed_phrase
    while [ $(wc -w <<< "$seed_phrase") -lt 12 ]; do
        echo -e "${RED}input salah kontol! Harus 12/24 kata:${YELLOW}"
        read -rp "> " seed_phrase
    done
    echo -e "${NC}"
}

cleanup() {
    echo -e "${RED}Instalasi dibatalkan!${NC}"
    exit 1
}
trap cleanup SIGINT

display_header
get_seed_phrase

echo -e "${GREEN}Memulai proses instalasi...${NC}"

export PATH="$HOME/.cargo/bin:$HOME/.local/share/solana/install/active_release/bin:$PATH"

echo -e "${BLUE}[1/8] Memperbarui paket sistem...${NC}"
apt-get update -q > /dev/null

echo -e "${BLUE}[2/8] Menginstall dependensi...${NC}"
apt-get install -yq curl screen > /dev/null

if ! command -v rustc &> /dev/null; then
    echo -e "${BLUE}[3/8] Menginstall Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    echo -e "${BLUE}[3/8] Rust sudah terinstall${NC}"
fi

if ! command -v solana &> /dev/null; then
    echo -e "${BLUE}[4/8] Menginstall Solana CLI...${NC}"
    curl -sSfL https://solana-install.solana.workers.dev | bash -s - v1.17.21
    echo 'export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc
    solana --version
else
    echo -e "${BLUE}[4/8] Solana CLI sudah terinstall${NC}"
fi

echo -e "${BLUE}[5/8] Memulihkan wallet...${NC}"
echo "$seed_phrase" | solana-keygen recover -o "$HOME/.config/solana/id.json" --force
echo -e "${GREEN}Wallet berhasil dipulihkan${NC}"

echo -e "${BLUE}[6/8] Mengkonfigurasi RPC...${NC}"
solana config set --url https://eclipse.helius-rpc.com

echo -e "${BLUE}[7/8] Setup screen...${NC}"
if ! command -v screen &> /dev/null; then
    apt-get install -yq screen > /dev/null
fi

echo -e "${BLUE}[8/8] Menjalankan bitz collector...${NC}"
screen -S bit -dm bash -c "bitz collect; exec bash"

echo -e "${GREEN}\nSelamat anjing instalasi selesai!${NC}"
echo -e "\nUntuk mengakses session screen jalankan perintah:"
echo -e "${YELLOW}screen -Rd bit${NC}"
echo -e "\nKalau crot dalam tekan CTRL+A kemudian tekan D buat balik keluar screen njeng"