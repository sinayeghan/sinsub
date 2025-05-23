#!/usr/bin/env bash

# setup.sh – Installer Script for sinaSub Dependencies

# ========================= Function to Install Golang =========================
GOlang() {
    sys=$(uname -m)
    if [ "$sys" == "x86_64" ]; then
        wget https://go.dev/dl/go1.17.13.linux-amd64.tar.gz -O golang.tar.gz &>/dev/null
    else
        wget https://go.dev/dl/go1.17.13.linux-386.tar.gz -O golang.tar.gz &>/dev/null
    fi

    sudo tar -C /usr/local -xzf golang.tar.gz
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

    echo "[+] Golang Installed!"
    echo "    Add these lines to your shell rc (~/.bashrc or ~/.zshrc):"
    echo "      export GOROOT=/usr/local/go"
    echo "      export GOPATH=\$HOME/go"
    echo "      export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin"
}

# ========================= Function to Install Findomain =========================
Findomain_install() {
    wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip &>/dev/null
    unzip findomain-linux.zip &>/dev/null
    chmod +x findomain
    sudo mv findomain /usr/local/bin/
    echo "[+] Findomain Installed!"
    rm findomain-linux.zip
}

# ========================= Function to Install subfinder =========================
Subfinder_install() {
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null
    echo "[+] Subfinder Installed!"
}

# ========================= Function to Install Amass =========================
Amass_install() {
    go install -v github.com/owasp-amass/amass/v4/...@master &>/dev/null
    echo "[+] Amass Installed!"
}

# ========================= Function to Install Assetfinder =========================
Assetfinder_install() {
    go install github.com/tomnomnom/assetfinder@latest &>/dev/null
    echo "[+] Assetfinder Installed!"
}

# ========================= Function to Install dnsx =========================
Dnsx_install() {
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest &>/dev/null
    echo "[+] Dnsx Installed!"
}

# ========================= Function to Install GNU parallel =========================
Parallel_install() {
    sudo apt-get update && sudo apt-get install -y parallel
    echo "[+] GNU parallel Installed!"
}

# ========================= Function to Install anew =========================
Anew_install() {
    go install -v github.com/tomnomnom/anew@latest &>/dev/null
    echo "[+] anew Installed!"
}

# ========================= Check & Install Dependencies =========================
hash go 2>/dev/null || GOlang
hash findomain 2>/dev/null || Findomain_install
hash subfinder 2>/dev/null || Subfinder_install
hash amass 2>/dev/null || Amass_install
hash assetfinder 2>/dev/null || Assetfinder_install
hash dnsx 2>/dev/null || Dnsx_install
hash parallel 2>/dev/null || Parallel_install
hash anew 2>/dev/null || Anew_install

# ========================= Status Summary =========================
tools=(go findomain subfinder amass assetfinder dnsx parallel anew)
for t in "${tools[@]}"; do
    hash $t 2>/dev/null && printf "[%s] \e[32mDone\e[0m\n" "$t" \
    || printf "[%s] \e[31mFailed! Please install manually.\e[0m\n" "$t"
done

# ========================= Install Sublist3r & Gobuster (Python/apt) =========================
echo "[+] Installing Sublist3r and Gobuster..."
pipx install sublist3r
sudo apt-get update && sudo apt-get install -y gobuster

# ========================= Add Go Bin to PATH =========================
grep -qxF 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc || \
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
echo "[+] Make sure to run 'source ~/.bashrc' or restart your shell."

echo "[+] All dependencies installed!"
