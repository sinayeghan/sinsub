#!/usr/bin/env bash

# setup.sh – Installer Script for sinaSub Dependencies v1.5.0

# ========================= Colors & Formatting =========================
green="\e[32m"
red="\e[31m"
end="\e[0m"

# ========================= Function to Install Golang =========================
GOlang() {
    echo -e "[+] Installing Go..."
    sys=$(uname -m)
    if [ "$sys" == "x86_64" ]; then
        wget https://go.dev/dl/go1.17.13.linux-amd64.tar.gz -O golang.tar.gz &>/dev/null
    else
        wget https://go.dev/dl/go1.17.13.linux-386.tar.gz -O golang.tar.gz &>/dev/null
    fi

    sudo tar -C /usr/local -xzf golang.tar.gz
    rm golang.tar.gz

    if ! grep -q "export GOROOT=/usr/local/go" ~/.bashrc; then
        echo "export GOROOT=/usr/local/go" >> ~/.bashrc
    fi
    if ! grep -q "export GOPATH=\$HOME/go" ~/.bashrc; then
        echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    fi
    if ! grep -q "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" ~/.bashrc; then
        echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" >> ~/.bashrc
    fi

    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

    echo -e "[+] ${green}Golang Installed!${end}"
    echo "    (Added to ~/.bashrc; run 'source ~/.bashrc' or reopen shell.)"
}

# ========================= Function to Install Findomain =========================
Findomain_install() {
    echo -e "[+] Installing Findomain..."
    wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip &>/dev/null
    unzip findomain-linux.zip &>/dev/null
    chmod +x findomain
    sudo mv findomain /usr/local/bin/
    rm findomain-linux.zip
    echo -e "[+] ${green}Findomain Installed!${end}"
}

# ========================= Function to Install subfinder =========================
Subfinder_install() {
    echo -e "[+] Installing Subfinder..."
    if ! command -v go &>/dev/null; then
        echo -e "${red}[-] Go not found. Install Go first.${end}"
        return
    fi
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null
    echo -e "[+] ${green}Subfinder Installed!${end}"
}

# ========================= Function to Install Amass =========================
Amass_install() {
    echo -e "[+] Installing Amass..."
    if ! command -v go &>/dev/null; then
        echo -e "${red}[-] Go not found. Install Go first.${end}"
        return
    fi
    go install -v github.com/owasp-amass/amass/v4/...@master &>/dev/null
    echo -e "[+] ${green}Amass Installed!${end}"
}

# ========================= Function to Install Assetfinder =========================
Assetfinder_install() {
    echo -e "[+] Installing Assetfinder..."
    if ! command -v go &>/dev/null; then
        echo -e "${red}[-] Go not found. Install Go first.${end}"
        return
    fi
    go install github.com/tomnomnom/assetfinder@latest &>/dev/null
    echo -e "[+] ${green}Assetfinder Installed!${end}"
}

# ========================= Function to Install dnsx =========================
Dnsx_install() {
    echo -e "[+] Installing dnsx..."
    if ! command -v go &>/dev/null; then
        echo -e "${red}[-] Go not found. Install Go first.${end}"
        return
    fi
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest &>/dev/null
    echo -e "[+] ${green}dnsx Installed!${end}"
}

# ========================= Function to Install GNU parallel =========================
Parallel_install() {
    echo -e "[+] Installing GNU parallel..."
    sudo apt-get update &>/dev/null
    sudo apt-get install -y parallel &>/dev/null
    echo -e "[+] ${green}GNU parallel Installed!${end}"
}

# ========================= Function to Install anew =========================
Anew_install() {
    echo -e "[+] Installing anew..."
    if ! command -v go &>/dev/null; then
        echo -e "${red}[-] Go not found. Install Go first.${end}"
        return
    fi
    go install -v github.com/tomnomnom/anew@latest &>/dev/null
    echo -e "[+] ${green}anew Installed!${end}"
}

# ========================= Function to Install Python & Pip =========================
Python_install() {
    echo -e "[+] Ensuring Python3 and pip are installed..."
    sudo apt-get update &>/dev/null
    sudo apt-get install -y python3 python3-pip &>/dev/null
    echo -e "[+] ${green}Python3 and pip Installed!${end}"
}

# ========================= Function to Install pipx (for Sublist3r) =========================
Pipx_install() {
    echo -e "[+] Ensuring pipx is installed..."
    sudo apt-get install -y pipx &>/dev/null
    sudo pipx ensurepath &>/dev/null || true
    echo -e "[+] ${green}pipx Installed!${end}"
}

# ========================= Function to Install Sublist3r =========================
Sublist3r_install() {
    echo -e "[+] Installing Sublist3r via pipx..."
    # If pipx not found, fallback to pip3
    if command -v pipx &>/dev/null; then
        pipx install sublist3r &>/dev/null
    else
        pip3 install sublist3r &>/dev/null
    fi
    echo -e "[+] ${green}Sublist3r Installed!${end}"
}

# ========================= Function to Install Gobuster =========================
Gobuster_install() {
    echo -e "[+] Installing Gobuster..."
    sudo apt-get update &>/dev/null
    sudo apt-get install -y gobuster &>/dev/null
    echo -e "[+] ${green}Gobuster Installed!${end}"
}

# ========================= Function to Install Python Libraries =========================
PyDeps_install() {
    echo -e "[+] Installing Python3 libraries for PyCrt and PyShodan..."
    sudo apt-get update &>/dev/null
    sudo apt-get install -y python3-requests python3-bs4 &>/dev/null
    pip3 install --upgrade requests beautifulsoup4 shodan &>/dev/null
    echo -e "[+] ${green}Python dependencies Installed!${end}"
}

# ========================= Check & Install All Dependencies =========================
echo "=== Checking and Installing Dependencies for sinaSub ==="

hash go 2>/dev/null || GOlang
hash findomain 2>/dev/null || Findomain_install
hash subfinder 2>/dev/null || Subfinder_install
hash amass 2>/dev/null || Amass_install
hash assetfinder 2>/dev/null || Assetfinder_install
hash dnsx 2>/dev/null || Dnsx_install
hash parallel 2>/dev/null || Parallel_install
hash anew 2>/dev/null || Anew_install

Python_install
Pipx_install
Sublist3r_install
Gobuster_install
PyDeps_install

# ========================= Status Summary =========================
echo -e "\n=== Installation Summary ==="
tools=(go findomain subfinder amass assetfinder dnsx parallel anew python3 pip3 pipx sublist3r gobuster)
for t in "${tools[@]}"; do
    if command -v $t &>/dev/null; then
        printf "[%s] %bDone%b\n" "$t" "$green" "$end"
    else
        printf "[%s] %bFailed! Please install manually.%b\n" "$t" "$red" "$end"
    fi
done

# ========================= Add Go Bin and Pipx Bin to PATH =========================
if ! grep -qxF 'export PATH=$PATH:$HOME/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
fi
if ! grep -qxF 'export PATH=$PATH:$HOME/.local/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
fi

echo -e "\n[+] ${green}All dependencies installed!${end}"
echo "    Make sure to run 'source ~/.bashrc' or restart your shell to update PATH."
