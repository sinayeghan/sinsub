#!/usr/bin/env bash

# sinaSub: Customized Subdomain Enumeration Tool v1.0.0

# ========================= Large ASCII Logo =========================
bold="\e[1m"
Underlined="\e[4m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="1.0.0"

cat << "EOF"
  _____ _           _   _____       _     
 / ____| |         | | |  __ \     | |    
| (___ | | ___  ___| |_| |  | |_ __| |__  
 \___ \| |/ _ \/ __| __| |  | | '__| '_ \ 
 ____) | |  __/ (__| |_| |__| | |  | | | |
|_____/|_|\___|\___|\__|_____/|_|  |_| |_|


      Customized Subdomain Enumeration Tool
                  sinsub v1.0
EOF

# ========================= Colors & Version =========================
bold="\e[1m"
Underlined="\e[4m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="1.0.0"

# ========================= Show Usage Instructions =========================
Usage(){
    while read -r line; do
        printf "%b\n" "$line"
    done <<-EOF

    \r# ${bold}${blue}Options${end}:
    \r    -d, --domain       - Domain to enumerate
    \r    -l, --list         - File containing domains (one per line)
    \r    -u, --use          - Comma-separated tools to **include**
    \r                        (e.g. Findomain,Subfinder,Amass,Assetfinder,Sublist3r,GobusterDNS,wayback,crt,abuseipdb)
    \r    -e, --exclude      - Comma-separated tools to **exclude**
    \r    -o, --output       - Custom output file name
    \r                        (Default: sinsub-<domain>-YYYY-MM-DD.txt)
    \r    -s, --silent       - Silent mode: only print found subdomains
    \r                        (Output saved as subenum-<domain>.txt)
    \r    -k, --keep         - Keep TMP files (default behavior deletes them)
    \r    -r, --resolve      - Probe for live subdomains via dnsx (HTTP/HTTPS)
    \r                        (Output saved as resolved-<domain>.txt)
    \r    -t, --thread       - Number of threads for dnsx/httpx (Default: 40)
    \r    -p, --parallel     - Use GNU parallel for faster enumeration
    \r                        (Cannot be combined with -e/--exclude or -u/--use)
    \r    -h, --help         - Show this help message and exit
    \r    -v, --version      - Show version and exit

    \r# ${bold}${blue}Available Tools${end}:
    \r    wayback, crt, abuseipdb, Findomain, Subfinder, Amass,
    \r    Assetfinder, Sublist3r, GobusterDNS

    \r# ${bold}${blue}Examples${end}:
    \r    # Run all tools on a single domain:
    \r    ./sinaSub.sh -d hackerone.com
    \r
    \r    # Only use specific tools:
    \r    ./sinaSub.sh -d hackerone.com -u Findomain,Subfinder,Sublist3r
    \r
    \r    # Exclude specific tools:
    \r    ./sinaSub.sh -d hackerone.com -e Amass,Assetfinder
    \r
    \r    # Enumerate multiple domains in parallel:
    \r    ./sinaSub.sh -l domains.txt -p
    \r
    \r    # Silent mode + resolve live subdomains:
    \r    ./sinaSub.sh -d example.com -s -r
EOF
    exit 1
}

# ========================= Spinner for Loading =========================
spinner(){
    processing="${1}"
    while true; do
        dots=("/" "-" "\\" "|")
        for dot in "${dots[@]}"; do
            printf "[${dot}] ${processing} \U1F50E"
            printf "                                    \r"
            sleep 0.3
        done
    done
}

# ========================= Subdomain Enumeration Functions =========================

# 1) Wayback Machine (cURL + awk)
wayback() {
    if [ "$silent" == True ]; then
        curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey" \
            | awk -F/ '{gsub(/:.*/, "", $3); print $3}' \
            | sort -u \
            | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}WaybackMachine${end}" & PID="$!"; }
        curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey" \
            | awk -F/ '{gsub(/:.*/, "", $3); print $3}' \
            | sort -u > tmp-wayback-$domain
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] WaybackMachine${end}: $(wc -l < tmp-wayback-$domain)"
    fi
}

# 2) crt.sh (SSL Certificate Transparency)
crt() {
    if [ "$silent" == True ]; then
        curl -sk "https://crt.sh/?q=%.$domain&output=json" \
            | tr ',' '\n' \
            | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4); print $4}' \
            | sort -u \
            | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}crt.sh${end}" & PID="$!"; }
        curl -sk "https://crt.sh/?q=%.$domain&output=json" \
            | tr ',' '\n' \
            | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4); print $4}' \
            | sort -u > tmp-crt-$domain
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] crt.sh${end}: $(wc -l < tmp-crt-$domain)"
    fi
}

# 3) abuseipdb (Web scraping)
abuseipdb() {
    if [ "$silent" == True ]; then
        curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" \
            | grep -E '<li>\w.*</li>' \
            | sed -E 's/<\/?li>//g' \
            | sed -e "s/$/.$domain/" \
            | sed 's/^[[:space:]]*//' \
            | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}abuseipdb${end}" & PID="$!"; }
        curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" \
            | grep -E '<li>\w.*</li>' \
            | sed -E 's/<\/?li>//g' \
            | sed -e "s/$/.$domain/" \
            | sed 's/^[[:space:]]*//' \
            | sort -u > tmp-abuseipdb-$domain
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] abuseipdb${end}: $(wc -l < tmp-abuseipdb-$domain)"
    fi
}

# 4) Findomain
Findomain() {
    if [ "$silent" == True ]; then
        findomain -t $domain -q 2>/dev/null | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}Findomain${end}" & PID="$!"; }
        findomain -t $domain -u tmp-findomain-$domain &>/dev/null
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] Findomain${end}: $(wc -l tmp-findomain-$domain 2>/dev/null | awk '{print $1}')"
    fi
}

# 5) Subfinder
Subfinder() {
    if [ "$silent" == True ]; then
        subfinder -all -silent -d $domain 2>/dev/null | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}Subfinder${end}" & PID="$!"; }
        subfinder -all -silent -d $domain 1> tmp-subfinder-$domain 2>/dev/null
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] Subfinder${end}: $(wc -l < tmp-subfinder-$domain)"
    fi
}

# 6) Amass
Amass() {
    if [ "$silent" == True ]; then
        amass enum -passive -norecursive -noalts -d $domain 2>/dev/null | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}Amass${end}" & PID="$!"; }
        amass enum -passive -norecursive -noalts -d $domain 1> tmp-amass-$domain 2>/dev/null
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] Amass${end}: $(wc -l < tmp-amass-$domain)"
    fi
}

# 7) Assetfinder
Assetfinder() {
    if [ "$silent" == True ]; then
        assetfinder --subs-only $domain | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}Assetfinder${end}" & PID="$!"; }
        assetfinder --subs-only $domain > tmp-assetfinder-$domain
        kill ${PID} 2>/dev/null
        echo -e "$bold[*] Assetfinder${end}: $(wc -l < tmp-assetfinder-$domain)"
    fi
}

# 8) Sublist3r
Sublist3r() {
    if [ "$silent" == True ]; then
        sublist3r -d $domain -o tmp-sublist3r-$domain -q 2>/dev/null
        cat tmp-sublist3r-$domain | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}Sublist3r${end}" & PID="$!"; }
        sublist3r -d $domain -o tmp-sublist3r-$domain 2>/dev/null
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] Sublist3r${end}: $(wc -l < tmp-sublist3r-$domain)"
    fi
}

# 9) Gobuster (DNS brute-force)
GobusterDNS() {
    if [ "$silent" == True ]; then
        gobuster dns -d $domain -w /usr/share/wordlists/subdomains.txt -q 2>/dev/null | anew subenum-$domain.txt
    else
        [[ ${PARALLEL} == True ]] || { spinner "${bold}Gobuster-DNS${end}" & PID="$!"; }
        gobuster dns -d $domain -w /usr/share/wordlists/subdomains.txt -q 2>/dev/null > tmp-gobuster-$domain
        [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
        echo -e "$bold[*] Gobuster-DNS${end}: $(wc -l < tmp-gobuster-$domain)"
    fi
}

# ========================= Helper Functions =========================
OUT(){
    if [ "$silent" == False ]; then
        if [ -n "$1" ]; then
            output="$1"
        else
            output="sinsub-$domain-$(date +'%Y-%m-%d').txt"
        fi
        result=$(sort -u tmp-* 2>/dev/null | wc -l)
        sort -u tmp-* >> "$output"
        echo -e "${green}[+] The Final Results:${end} ${result}"
        if [ "$resolve" == True ]; then
            ALIVE "$output" "$domain"
        fi
        if [ "$delete" == True ]; then
            rm tmp-* 2>/dev/null
        fi
    fi
}

ALIVE(){
    if [ "$silent" == False ]; then
        printf "${bold}[+] Resolving${end}"
    fi
    printf "                        \r"
    cat "$1" | dnsx -silent -threads $thread > "resolved-$2.txt"
    if [ "$silent" == False ]; then
        echo -e "${green}[+] Resolved:${end} $(wc -l < resolved-$2.txt)"
    fi
}

LIST() {
    lines=$(wc -l < "$hosts")
    count=1
    while read -r domain; do
        if [ "$silent" == False ]; then
            echo -e "\n${Underlined}${bold}${green}[+] Domain ($count/$lines):${end} ${domain}"
        fi
        if [ "$prv" == "a" ]; then
            if [ "${PARALLEL}" == True ]; then
                spinner "Reconnaissance" &
                PID="$!"
                export -f wayback crt abuseipdb Findomain Subfinder Amass Assetfinder Sublist3r GobusterDNS spinner
                export domain silent bold end
                parallel -j7 ::: wayback crt abuseipdb Findomain Subfinder Amass Assetfinder Sublist3r GobusterDNS
                kill ${PID}
                OUT "$out"
            else
                wayback
                crt
                abuseipdb
                Findomain
                Subfinder
                Amass
                Assetfinder
                Sublist3r
                GobusterDNS
                OUT "$out"
            fi
        fi
        if [ "$prv" == "e" ]; then
            EXCLUDE
        fi
        if [ "$prv" == "u" ]; then
            USE
        fi
        count=$((count + 1))
    done < "$hosts"
}

# ========================= Main Logic =========================
domain=False
hosts=False
use=False
exclude=False
silent=False
delete=True
out=False
resolve=False
thread=40
PARALLEL=False

list=(
    wayback
    crt
    abuseipdb
    Findomain
    Subfinder
    Amass
    Assetfinder
    Sublist3r
    GobusterDNS
)

USE() {
    for i in $lu; do
        $i
    done
    OUT "$out"
}

EXCLUDE() {
    for i in "${list[@]}"; do
        if [[ " ${le[@]} " =~ " ${i} " ]]; then
            continue
        else
            $i
        fi
    done
    OUT "$out"
}

while [ -n "$1" ]; do
    case $1 in
        -d|--domain)
            domain=$2; shift ;;
        -l|--list)
            hosts=$2; shift ;;
        -u|--use)
            use=$2; lu=${use//,/ }
            for i in $lu; do
                if [[ ! " ${list[@]} " =~ " ${i} " ]]; then
                    echo -e "${red}${Underlined}[-] Unknown Tool: $i${end}"
                    Usage
                fi
            done
            shift ;;
        -e|--exclude)
            exclude=$2; le=${exclude//,/ }
            for i in $le; do
                if [[ ! " ${list[@]} " =~ " ${i} " ]]; then
                    echo -e "${red}${Underlined}[-] Unknown Tool: $i${end}"
                    Usage
                fi
            done
            shift ;;
        -o|--output)
            out=$2; shift ;;
        -s|--silent)
            silent=True ;;
        -k|--keep)
            delete=False ;;
        -r|--resolve)
            resolve=True ;;
        -t|--thread)
            thread=$2; shift ;;
        -p|--parallel)
            PARALLEL=True ;;
        -h|--help)
            Usage ;;
        -v|--version)
            echo "sinsub Version: $VERSION"; exit 0 ;;
        *)
            echo "[-] Unknown Option: $1"; Usage ;;
    esac
    shift
done

if [ "$domain" == False ] && [ "$hosts" == False ]; then
    echo -e "${red}[-] Argument -d/--domain OR -l/--list is Required!${end}"
    Usage
fi

if [ "$domain" != False ]; then
    if [ "$use" == False ] && [ "$exclude" == False ]; then
        if [ "${PARALLEL}" == True ]; then
            spinner "Reconnaissance" &
            PID="$!"
            export -f wayback crt abuseipdb Findomain Subfinder Amass Assetfinder Sublist3r GobusterDNS spinner
            export domain silent bold end
            parallel -j7 ::: wayback crt abuseipdb Findomain Subfinder Amass Assetfinder Sublist3r GobusterDNS
            kill ${PID}
            OUT "$out"
        else
            wayback
            crt
            abuseipdb
            Findomain
            Subfinder
            Amass
            Assetfinder
            Sublist3r
            GobusterDNS
            OUT "$out"
        fi
    else
        if [ "$use" != False ]; then USE; fi
        if [ "$exclude" != False ]; then EXCLUDE; fi
    fi
fi

if [ "$hosts" != False ]; then
    prv="a"
    if [ "$use" != False ]; then prv="u"; fi
    if [ "$exclude" != False ]; then prv="e"; fi
    LIST
fi
