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


Step-by-Step Installation & Usage (0 to 100)

Below is a detailed, step-by-step guide (“Installation” section) you can include in your GitHub repository—either in the README or in a separate INSTALL.md file. This will help anyone who clones your repo to get up and running from scratch:
1. Clone the Repository

    Open a terminal (on Kali Linux, WSL, Ubuntu, etc.).

    Run:

    git clone https://github.com/yourusername/sinsub.git
    cd sinsub

    This creates a local sinsub/ folder containing all project files.

2. Make Scripts Executable

Inside the sinsub/ folder, give execution permission to both setup.sh and sinaSub.sh:

chmod +x setup.sh
chmod +x sinaSub.sh

3. Install Dependencies

Run the installer script. This will take care of installing all Go-based and Python-based tools:

./setup.sh

What setup.sh does:

    Installs Golang (if not already installed).

    Installs or verifies:

        findomain

        subfinder

        amass

        assetfinder

        dnsx

        GNU parallel

        anew

    Installs Python-based tools via pipx:

        sublist3r

    Installs Gobuster via apt-get:

    sudo apt-get install -y gobuster

    Adds $HOME/go/bin to your PATH (if it isn’t there already).

    Important:

        If any of these tools fail to install, setup.sh will print a “Failed!” line. You may have to install that tool manually.

        After setup.sh completes, make sure you restart your terminal or run source ~/.bashrc so that new PATH changes take effect.

4. Verify Installation

    Verify Go binaries (these should appear in ~/go/bin and now be in your $PATH):

which findomain    # should return /usr/local/bin/findomain
which subfinder    # should return ~/go/bin/subfinder
which amass        # should return ~/go/bin/amass
which assetfinder  # should return ~/go/bin/assetfinder
which dnsx         # should return ~/go/bin/dnsx
which anew         # should return ~/go/bin/anew
which gobuster     # should return /usr/bin/gobuster (or similar)

Verify Python-based tools:

    pipx list         # you should see sublist3r listed
    which sublist3r   # should return something like ~/.local/bin/sublist3r

If any of the above “which” commands return no path, you may need to manually install or correct your $PATH.
5. (Optional) Install sinaSub System-Wide

If you want to call sinaSub from anywhere (no need to cd sinsub each time):

sudo cp sinaSub.sh /usr/local/bin/sinaSub
sudo chmod +x /usr/local/bin/sinaSub

Now you can simply run sinsub instead of ./sinaSub.sh.
6. Basic Enumeration Examples
A) Enumerate a Single Domain

# If still inside sinsub/ folder:
./sinaSub.sh -d example.com

# If installed system-wide:
sinsub -d example.com

    Outputs for each tool are temporarily stored as:

tmp-wayback-example.com
tmp-crt-example.com
tmp-abuseipdb-example.com
tmp-findomain-example.com
tmp-subfinder-example.com
tmp-amass-example.com
tmp-assetfinder-example.com
tmp-sublist3r-example.com
tmp-gobuster-example.com

At the very end, all unique domain results are combined into:

    sinsub-example.com-YYYY-MM-DD.txt

B) Enumerate a List of Domains

Assume domains.txt contains:

example.com
domain2.com
mytarget.org

Run:

./sinaSub.sh -l domains.txt

The script will process example.com first (printing progress), then domain2.com, then mytarget.org. Each domain gets its own final output file:

sinsub-example.com-YYYY-MM-DD.txt
sinsub-domain2.com-YYYY-MM-DD.txt
sinsub-mytarget.org-YYYY-MM-DD.txt

7. Advanced Usage Examples
1. Only Specific Tools

# Only use Findomain, Wayback, and Subfinder:
sinsub -d hackerone.com -u Findomain,wayback,Subfinder

2. Exclude Specific Tools

# Run all tools except Amass and Assetfinder:
sinsub -d hackerone.com -e Amass,Assetfinder

3. Silent Mode

# Silent mode: only print unique subdomains to stdout; save them in subenum-hackerone.com.txt
sinsub -d hackerone.com -s

4. Resolve Live Subdomains

# After collecting subdomains, check which ones resolve (requires dnsx). Output to resolved-hackerone.com.txt
sinsub -d hackerone.com -r

5. Parallel Enumeration

# Use GNU parallel to run each tool concurrently for faster results
sinsub -d example.com -p

    Note: Cannot combine -p with -u or -e.

6. Custom Output Filename

# Save final results into mysubs.txt instead of default
sinsub -d example.com -o mysubs.txt

7. Adjust DNSX Thread Count

# Use 100 threads when resolving live subdomains
sinsub -d example.com -r -t 100

8. Tips & Troubleshooting

    “Command not found” errors: Verify that $HOME/go/bin and ~/.local/bin (where pipx places binaries) are in your $PATH.

echo $PATH

If necessary:

echo 'export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc

Manual installation of a single missing tool:

    If findomain failed, visit https://github.com/Findomain/Findomain and follow their instructions.

    If subfinder failed, run:

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

If amass failed, run:

go install -v github.com/owasp-amass/amass/v4/...@master

If assetfinder failed, run:

go install github.com/tomnomnom/assetfinder@latest

If dnsx failed, run:

go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

If anew failed, run:

go install -v github.com/tomnomnom/anew@latest

If sublist3r failed, run:

pipx install sublist3r

If gobuster failed, run:

        sudo apt-get install -y gobuster

    WSL (Windows Subsystem for Linux):

        If using WSL, make sure you’ve installed sudo apt update && sudo apt install -y wget unzip git pipx golang-go parallel first.

        In WSL, $HOME/go/bin might not be in your default $PATH—add it manually.

    License:

        This project is released under the MIT License. Feel free to use, modify, and distribute.

By following these steps, any user—whether on a fresh Kali install, Ubuntu, or WSL—will be able to:

    Clone the sinsub repository.

    Run setup.sh to install all dependencies.

    Run sinaSub.sh (or the sinsub alias) to enumerate subdomains.

Thank you for using sinaSub! Happy Hunting.
