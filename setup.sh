#!/usr/bin/env bash

# setup.sh – Installer Script for sinaSub Dependencies v1.7.0

# ========================= Colors & Formatting =========================
green="\e[32m"
red="\e[31m"
end="\e[0m"

# ========================= Function to Install Golang =========================
GOlang() {
    echo -e "[+] Installing Go..."
    sys=$(uname -m)
    if [ "$sys" = "x86_64" ]; then
        wget -q https://go.dev/dl/go1.17.13.linux-amd64.tar.gz -O golang.tar.gz
    else
        wget -q https://go.dev/dl/go1.17.13.linux-386.tar.gz -O golang.tar.gz
    fi

    sudo tar -C /usr/local -xzf golang.tar.gz
    rm golang.tar.gz

    grep -qxF 'export GOROOT=/usr/local/go' ~/.bashrc || echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
    grep -qxF 'export GOPATH=$HOME/go' ~/.bashrc    || echo 'export GOPATH=$HOME/go'    >> ~/.bashrc
    grep -qxF 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' ~/.bashrc \
      || echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.bashrc

    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

    echo -e "[+] ${green}Golang Installed!${end}"
    echo "    (Added to ~/.bashrc; run 'source ~/.bashrc' or reopen shell.)"
}

# ========================= Package Installs =========================
ensure_apt_pkg() {
    sudo apt-get update -qq
    sudo apt-get install -y "$@" &>/dev/null
}

# ========================= Function to Install Findomain =========================
Findomain_install() {
    echo -e "[+] Installing Findomain..."
    wget -q https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip
    unzip -qq findomain-linux.zip && chmod +x findomain
    sudo mv findomain /usr/local/bin/ && rm findomain-linux.zip
    echo -e "[+] ${green}Findomain Installed!${end}"
}

# ========================= Install Go‑based Tools =========================
install_go_tool() {
    name="$1"; pkg="$2"
    echo -e "[+] Installing $name..."
    if ! command -v go &>/dev/null; then
        echo -e "${red}[-] Go not found. Run setup.sh again after Go install.${end}"
        exit 1
    fi
    GO111MODULE=on go install -v "$pkg"@latest &>/dev/null
    echo -e "[+] ${green}$name Installed!${end}"
}

# ========================= Python & Others =========================
Python_install() {
    echo -e "[+] Ensuring Python3, pip3, jq are installed..."
    ensure_apt_pkg python3 python3-pip jq
    echo -e "[+] ${green}Python3, pip3, jq Installed!${end}"
}

# ========================= pipx & Sublist3r =========================
Pipx_install() {
    echo -e "[+] Ensuring pipx is installed..."
    ensure_apt_pkg pipx
    pipx ensurepath &>/dev/null || true
    echo -e "[+] ${green}pipx Installed!${end}"
}

Sublist3r_install() {
    echo -e "[+] Installing Sublist3r via pipx..."
    if command -v pipx &>/dev/null; then
        pipx install sublist3r &>/dev/null
    else
        pip3 install sublist3r &>/dev/null
    fi
    echo -e "[+] ${green}Sublist3r Installed!${end}"
}

# ========================= Anew & Parallel =========================
Anew_install() { install_go_tool "anew" github.com/tomnomnom/anew; }
Parallel_install() { ensure_apt_pkg parallel; echo -e "[+] ${green}GNU parallel Installed!${end}"; }

# ========================= Main Dependency Check =========================
echo "=== Checking and Installing Dependencies for sinaSub v1.7 ==="

hash go         2>/dev/null || GOlang
hash findomain  2>/dev/null || Findomain_install

install_go_tool "Subfinder"        github.com/projectdiscovery/subfinder/cmd/subfinder
install_go_tool "Amass"            github.com/owasp-amass/amass/v4/... 
install_go_tool "Assetfinder"      github.com/tomnomnom/assetfinder
install_go_tool "dnsx"             github.com/projectdiscovery/dnsx/cmd/dnsx
Anew_install
Parallel_install

Python_install
Pipx_install
Sublist3r_install
ensure_apt_pkg gobuster

# ========================= Summary =========================
echo -e "\n=== Installation Summary ==="
for t in go findomain subfinder amass assetfinder dnsx parallel anew python3 pip3 pipx sublist3r gobuster jq; do
    if command -v $t &>/dev/null; then
        printf "[%s] %bDone%b\n" "$t" "$green" "$end"
    else
        printf "[%s] %bFailed%b\n" "$t" "$red" "$end"
    fi
done

echo -e "\n[+] ${green}All dependencies installed!${end}"
echo "    Run 'source ~/.bashrc' or restart shell to update PATH."
