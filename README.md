# sinsub
a tool for find subdomains
# sinaSub (Customized Subdomain Enumeration Tool)

A powerful and user-friendly tool for collecting and consolidating subdomains.  
Based on [SubEnum](https://github.com/bing0o/SubEnum) by bing0o (@hack1lab), `sinaSub` adds several popular subdomain enumeration tools and a custom ASCII art logo.

**Version:** v1.0.0  
**Author:** sina (@sinayeghan)

---


---

## 🛠️ Prerequisites

Before installing or running `sinaSub`, make sure your system has the following:

- **Bash** (or any shell compatible with Bash)  
- **Zsh** (optional—but some commands in the script assume Zsh is installed)  
- **Go** (version 1.15 or newer)  
- **Python 3** (version 3.8 or newer)  
- **pipx** (for installing Python-based CLI tools like Sublist3r)  
- **GNU `parallel`** (if you plan to use the `--parallel` flag)  

---

## 🚀 Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/sinsub.git
   cd sinsub

2. **Make Installer and Main Script Executable**
   chmod +x setup.sh
   chmod +x sinaSub.sh

3. **Run the Installer Script**
   ./setup.sh
./setup.sh

The setup.sh script will:

    Install or verify:

        Golang

        findomain

        subfinder

        amass

        assetfinder

        dnsx

        GNU parallel

        anew

    Install Python CLI tools via pipx:

        sublist3r

    Install Gobuster via apt:

        gobuster

    Ensure $HOME/go/bin is added to your $PATH so that Go-installed binaries are available.

(Optional) Install sinaSub System-wide

If you want to run sinaSub from anywhere, copy it to /usr/local/bin: 

sudo cp sinaSub.sh /usr/local/bin/sinaSub
sudo chmod +x /usr/local/bin/sinaSub

    udo chmod +x /usr/local/bin/sinaSub

🎯 Usage
1) Enumerate a Single Domain

# If you are still inside the sinsub/ folder:
./sinaSub.sh -d example.com

# If you copied it to /usr/local/bin:
sinsub -d example.com

    Temporary files (tmp-*.example.com) will be created in the current directory for each tool’s output.

    At the end, all unique subdomains are consolidated into:

    sinsub-example.com-YYYY-MM-DD.txt

2) Enumerate Multiple Domains from a File

# domains.txt is a plain text file with one domain per line:
./sinaSub.sh -l domains.txt

    The script processes each domain in sequence.

    For each domain, a separate output file will be generated.

3) Specify Tools to Use

# Only run Findomain, Wayback, and Subfinder:
./sinaSub.sh -d example.com -u Findomain,wayback,Subfinder

4) Exclude Specific Tools

# Run all tools except Amass and Assetfinder:
./sinaSub.sh -d example.com -e Amass,Assetfinder

5) Silent Mode (Only Print Subdomains)

./sinaSub.sh -d example.com -s

    Only the list of subdomains is printed.

    Results are saved into subenum-example.com.txt (one per line, unique).

6) Resolve for Live Subdomains

./sinaSub.sh -d example.com -r

    After collecting subdomains, dnsx will probe each one to check if it resolves.

    Working subdomains are saved in resolved-example.com.txt.

7) Run in Parallel for Faster Enumeration

./sinaSub.sh -d example.com -p

    Uses GNU parallel to run each tool simultaneously.

    Speeds up enumeration but cannot be combined with -e/--exclude or -u/--use.

8) Specify Custom Output Filename

./sinaSub.sh -d example.com -o mysubdomains.txt

    Overrides default sinsub-example.com-YYYY-MM-DD.txt.

9) Set Number of Threads for DNS/HTTP Probing

./sinaSub.sh -d example.com -r -t 100

    Uses 100 threads when running dnsx (or httpx if integrated later).

10) Display Version or Help

./sinaSub.sh -v  # Print version
./sinaSub.sh -h  # Show help/usage

