````markdown
# sinsub (Customized Subdomain Enumeration Tool)

A powerful, modular and user-friendly Bash script for aggregating subdomains from multiple sources.  
`sinsub` integrates Wayback, crt.sh, AbuseIPDB, Findomain, Subfinder, Amass, Assetfinder, Sublist3r, GobusterDNS, plus Python-powered **PyCrt** and **PyShodan** modules—complete with parallel execution, live-host resolution, and a sleek ASCII logo.

**Version:** v1.5.0  
**Author:** sina (@sinayeghan)

---

## 🛠️ Prerequisites

Ensure your system has the following before running `sinaSub.sh`:

- **Bash** (or any compatible shell)  
- **Go** ≥ 1.15 (for Go-based tools)  
- **Python 3.8+** and **pip3**  
- **pipx** (optional, for Sublist3r)  
- **GNU parallel** (if you want `-p/--parallel`)  
- **dnsx** (for live-host resolution)  
- **anew** (for atomic appending)  
- **gobuster** (DNS brute-force)  

---

## 🚀 Installation & Setup

1. **Clone repository**
   ```bash
   git clone https://github.com/sinayeghan/sinsub.git
   cd sinsub
````

2. **Make scripts executable**

   ```bash
   chmod +x setup.sh sinaSub.sh
   ```

3. **Run installer**

   ```bash
   ./setup.sh
   ```

   This will:

   * Install/verify Go, Findomain, Subfinder, Amass, Assetfinder, dnsx, anew
   * Install GNU parallel
   * Install Python 3, pip3, pipx, Sublist3r (via pipx or pip3)
   * Install Gobuster (via apt)
   * Install Python libs: `requests`, `beautifulsoup4`, `shodan`

4. **Reload your shell**

   ```bash
   source ~/.bashrc
   ```

---

## 🎯 Quick Usage

Replace `example.com` with your target domain. All commands assume you are in the `sinsub/` directory.

### 1. Single-domain enumeration

```bash
./sinaSub.sh -d example.com
```

* Temporary `tmp-<tool>-example.com` files appear in cwd
* Final unique list:

  ```
  sinsub-example.com-YYYY-MM-DD.txt
  ```

### 2. Multiple domains from file

```bash
./sinaSub.sh -l domains.txt
```

* Processes each line in `domains.txt`
* Outputs one file per domain

### 3. Include only certain tools

```bash
./sinaSub.sh -d example.com -u Findomain,Subfinder,PyShodan
```

### 4. Exclude specific tools

```bash
./sinaSub.sh -d example.com -e Amass,Assetfinder,PyCrt
```

### 5. Silent mode (stdout only)

```bash
./sinaSub.sh -d example.com -s
```

* Prints subdomains to console
* Saves `subenum-example.com.txt`

### 6. Resolve live hosts

```bash
./sinaSub.sh -d example.com -r
```

* Runs `dnsx` on collected subdomains
* Saves `resolved-example.com.txt`

### 7. Parallel execution

```bash
./sinaSub.sh -d example.com -p
```

* Requires GNU parallel
* **Cannot** combine with `-u` or `-e`

### 8. Custom output file

```bash
./sinaSub.sh -d example.com -o mysubs.txt
```

### 9. Adjust DNS-probe threads

```bash
./sinaSub.sh -d example.com -r -t 100
```

### 10. Help & version

```bash
./sinaSub.sh -h    # detailed usage
./sinaSub.sh -v    # prints “sinsub v1.5.0”
```

---

## 🔧 Troubleshooting

1. **Missing commands**
   Ensure these directories are in your `PATH`:

   ```bash
   echo $PATH
   # should include:
   $HOME/go/bin
   $HOME/.local/bin
   ```

   Add and reload if needed:

   ```bash
   echo 'export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Manual tool install**

   * **findomain**

     ```bash
     wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip
     unzip findomain-linux.zip && sudo mv findomain /usr/local/bin/
     ```
   * **subfinder**

     ```bash
     go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
     ```
   * **amass**

     ```bash
     go install github.com/owasp-amass/amass/v4/...@master
     ```
   * **assetfinder**

     ```bash
     go install github.com/tomnomnom/assetfinder@latest
     ```
   * **dnsx**

     ```bash
     go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
     ```
   * **anew**

     ```bash
     go install github.com/tomnomnom/anew@latest
     ```
   * **Sublist3r** (Python)

     ```bash
     pipx install sublist3r
     ```
   * **Gobuster**

     ```bash
     sudo apt-get update && sudo apt-get install -y gobuster
     ```

3. **WSL users**

   ```bash
   sudo apt-get update
   sudo apt-get install -y wget unzip git pipx golang-go parallel python3-pip dnsx anew gobuster
   echo 'export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

---

<p align="center">
  ⭐️ Happy hunting with <strong>sinsub v1.5.0</strong>! ⭐️
</p>
```
