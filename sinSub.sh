#!/usr/bin/env bash

# sinaSub: Customized Subdomain Enumeration Tool v1.6.0

# ========================= Large ASCII Logo =========================
bold="\e[1m"
underlined="\e[4m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="1.6.0"

cat << "EOF"
      ____ ___       ____        _           
     / ___|_ _|_ __ / ___| _   _| |__        
 ____\___ \| || '_ \\___ \| | | | '_ \ _____ 
|_____|__) | || | | |___) | |_| | |_) |_____|
     |____/___|_| |_|____/ \__,_|_.__/       

      Customized Subdomain Enumeration Tool
                  sinsub v1.6
EOF

# ========================= Usage =========================
Usage() {
  cat <<-EOM

  Usage: $0 [options]

  Options:
    -d, --domain       Domain to enumerate
    -l, --list         File containing domains (one per line)
    -u, --use          Comma-separated tools to include
    -e, --exclude      Comma-separated tools to exclude
    -o, --output       Custom output file name (Default: sinsub-<domain>-YYYY-MM-DD.txt)
    -s, --silent       Silent mode: only print found subdomains
    -k, --keep         Keep tmp files (default: delete)
    -r, --resolve      Probe live subdomains via dnsx
    -t, --thread       Threads for dnsx/httpx (Default: 40)
    -p, --parallel     Use GNU parallel for enumeration
    -h, --help         Show this help and exit
    -v, --version      Show version and exit

  Available Tools:
    wayback, crt, abuseipdb, Findomain, Subfinder, Amass,
    Assetfinder, Sublist3r, GobusterDNS, PyCrt, PyShodan,
    jonlu, bevigil, rapiddns

  Examples:
    $0 -d example.com
    $0 -d example.com -u jonlu,bevigil,crt
    $0 -l domains.txt -p

EOM
  exit 1
}

# ========================= Spinner =========================
spinner() {
  local msg="$1"
  while :; do
    for c in '/' '-' '\\' '|'; do
      printf "[%s] %s\r" "$c" "$msg"
      sleep 0.3
    done
  done
}

# ========================= Functions =========================
# 1) Wayback
wayback() {
  curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey" \
    | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u > tmp-wayback-$domain
  echo "[wayback] $(wc -l < tmp-wayback-$domain)"
}

# 2) crt.sh
crt() {
  curl -sk "https://crt.sh/?q=%.$domain&output=json" \
    | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); print $4}' \
    | sort -u > tmp-crt-$domain
  echo "[crt] $(wc -l < tmp-crt-$domain)"
}

# 3) abuseipdb
abuseipdb() {
  curl -s "https://www.abuseipdb.com/whois/$domain" -H "User-Agent: curl" \
    | grep -E '<li>[^<]+</li>' | sed -E 's/<\/?li>//g' | sed "s/\$/.${domain}/" \
    | sort -u > tmp-abuseipdb-$domain
  echo "[abuseipdb] $(wc -l < tmp-abuseipdb-$domain)"
}

# 4) Findomain
Findomain() {
  findomain -t $domain -q | sort -u > tmp-findomain-$domain
  echo "[Findomain] $(wc -l < tmp-findomain-$domain)"
}

# 5) Subfinder
Subfinder() {
  subfinder -d $domain -silent | sort -u > tmp-subfinder-$domain
  echo "[Subfinder] $(wc -l < tmp-subfinder-$domain)"
}

# 6) Amass
Amass() {
  amass enum -passive -d $domain | sort -u > tmp-amass-$domain
  echo "[Amass] $(wc -l < tmp-amass-$domain)"
}

# 7) Assetfinder
Assetfinder() {
  assetfinder --subs-only $domain | sort -u > tmp-assetfinder-$domain
  echo "[Assetfinder] $(wc -l < tmp-assetfinder-$domain)"
}

# 8) Sublist3r
Sublist3r() {
  sublist3r -d $domain -o - | sed 1d | sort -u > tmp-sublist3r-$domain
  echo "[Sublist3r] $(wc -l < tmp-sublist3r-$domain)"
}

# 9) GobusterDNS
GobusterDNS() {
  gobuster dns -d $domain -w /usr/share/wordlists/subdomains.txt -q \
    | sort -u > tmp-gobuster-$domain
  echo "[GobusterDNS] $(wc -l < tmp-gobuster-$domain)"
}

# 10) PyCrt
PyCrt() {
  python3 - << 'PYCRTSCRIPT' | sort -u > tmp-pycrt-$domain
import sys, requests
from bs4 import BeautifulSoup

domain = sys.argv[1]
url = f"https://crt.sh/?q=%25.{domain}"
resp = requests.get(url)
soup = BeautifulSoup(resp.text, 'html.parser')
subs = set()
for td in soup.find_all('td'):
    text = td.text.strip()
    if text.endswith(domain) and '*' not in text:
        subs.add(text)
for s in sorted(subs): print(s)
PYCRTSCRIPT
  echo "[PyCrt] $(wc -l < tmp-pycrt-$domain)"
}

# 11) PyShodan
PyShodan() {
  python3 - << 'PYSHODANSCRIPT' | sort -u > tmp-pyshodan-$domain
import sys
import shodan
API_KEY = 'YOUR_SHODAN_API_KEY'
domain = sys.argv[1]
api = shodan.Shodan(API_KEY)
try:
    results = api.search(f"hostname:{domain}")
    subs = set()
    for m in results.get('matches', []):
        subs |= set([h for h in m.get('hostnames', []) if h.endswith(domain)])
    for s in sorted(subs): print(s)
except:
    pass
PYSHODANSCRIPT
  echo "[PyShodan] $(wc -l < tmp-pyshodan-$domain)"
}

# 12) jonlu.ca/anubis
jonlu() {
  curl -s "https://jonlu.ca/anubis/subdomains/$domain" \
    | jq -r '.domains[]' | sort -u > tmp-jonlu-$domain
  echo "[jonlu] $(wc -l < tmp-jonlu-$domain)"
}

# 13) bevigil.com OSINT API
bevigil() {
  curl -s "https://bevigil.com/osint-api?query=$domain&criteria=domain" \
    | jq -r '.data[].name' | sed 's/\\"//g' | sort -u > tmp-bevigil-$domain
  echo "[bevigil] $(wc -l < tmp-bevigil-$domain)"
}

# 14) rapiddns.io
rapiddns() {
  curl -s "https://rapiddns.io/subdomain/$domain?full=1" \
    | grep -Eo "[A-Za-z0-9._-]+\.$domain" | sort -u > tmp-rapiddns-$domain
  echo "[rapiddns] $(wc -l < tmp-rapiddns-$domain)"
}

# ========================= Output & Resolve =========================
OUT() {
  local final="${output:-sinsub-$domain-$(date +'%Y-%m-%d').txt}"
  cat tmp-* 2>/dev/null | sort -u > "$final"
  echo -e "${green}[+] Final results: $(wc -l < "$final")${end}"
  if [[ $resolve == True ]]; then
    cat "$final" | dnsx -silent -threads $thread > resolved-$domain.txt
    echo -e "${green}[+] Resolved: $(wc -l < resolved-$domain.txt)${end}"
  fi
  $delete && rm tmp-* 2>/dev/null
}

# ========================= Main Logic =========================
# Defaults
