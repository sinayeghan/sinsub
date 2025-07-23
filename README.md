# sinsub (Customized Subdomain Enumeration Tool)

A powerful, modular Bash script aggregating subdomains from multiple sources—now with **CertSpotter API** integration.

**Version:** v1.7.0
**Author:** sina (@sinayeghan)

---

## 🛠️ Prerequisites

* **Bash**
* **Go** ≥ 1.15
* **Python 3.8+**, **pip3**
* **pipx** (optional, for Sublist3r)
* **GNU parallel** (for `-p/--parallel`)
* **dnsx** (live-host resolution)
* **anew** (atomic append)
* **gobuster** (DNS brute-force)
* **jq** (parsing CertSpotter JSON)

---

## 🚀 Installation & Setup

1. **Clone & Make Executable**

   ```bash
   git clone https://github.com/sinayeghan/sinsub.git
   cd sinsub
   chmod +x setup.sh sinaSub.sh
   ```
2. **Run Installer**

   ```bash
   ./setup.sh
   ```
3. **Reload Shell**

   ```bash
   source ~/.bashrc
   ```

---

## 🎯 Quick Usage

```bash
./sinaSub.sh -d example.com
```

* **Available Tools:**
  wayback, crt, **certspotter**, abuseipdb, Findomain, Subfinder, Amass,
  Assetfinder, Sublist3r, GobusterDNS, PyCrt, PyShodan, jonlu, bevigil, rapiddns

### Common Options

* `-d domain` : target domain
* `-l file`   : list of domains
* `-u tools`  : include (e.g. `-u certspotter,crt`)
* `-e tools`  : exclude
* `-r`        : resolve live subdomains via dnsx
* `-p`        : parallel (requires GNU parallel)
* `-o file`   : custom output
* `-s`        : silent (stdout only)

---

## 🔧 Examples

1. **All sources + CertSpotter**

   ```bash
   ./sinaSub.sh -d target.com
   ```
2. **Only CertSpotter + crt.sh**

   ```bash
   ./sinaSub.sh -d target.com -u certspotter,crt
   ```
3. **Exclude Amass & PyShodan**

   ```bash
   ./sinaSub.sh -d target.com -e Amass,PyShodan
   ```
4. **Parallel enumeration**

   ```bash
   ./sinaSub.sh -d target.com -p
   ```
5. **Resolve live**

   ```bash
   ./sinaSub.sh -d target.com -r
   ```

---

## 📂 Output

* `sinsub-<domain>-YYYY-MM-DD.txt` → final unique subdomains
* `resolved-<domain>.txt`        → live subdomains (if `-r`)

---

> ⭐️ Happy hunting with **sinsub v1.7.0**! ⭐️
