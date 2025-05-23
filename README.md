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


````markdown
# sinsub (Subdomain Enumeration Tool)

**Repository:**  
[https://github.com/sinayeghan/sinsub.git](https://github.com/sinayeghan/sinsub.git)

---

## 🚀 Installation & Setup

Follow these steps to get `sinsub` up and running in just a few commands.

### 1. Clone the Repository

```bash
git clone https://github.com/sinayeghan/sinsub.git
cd sinsub
````

### 2. Make Scripts Executable

```bash
chmod +x setup.sh
chmod +x sinaSub.sh
```

### 3. Run the Installer Script

```bash
./setup.sh
```

**What `setup.sh` Does:**

1. Installs or verifies all Go-based tools:

   * `findomain`
   * `subfinder`
   * `amass`
   * `assetfinder`
   * `dnsx`
   * `anew`
2. Installs GNU `parallel`.
3. Installs Python-based tool via `pipx`:

   * `sublist3r`
4. Installs `gobuster` via `apt`.
5. Adds `$HOME/go/bin` to your `PATH` if it’s not already there.

> After `setup.sh` finishes, you should see “Done” or “Failed” messages for each tool.
> If any tool fails, install it manually (see troubleshooting tips below).

---

## 🎯 Quick Usage Examples

Assume you are still inside the `sinsub/` folder. Replace `example.com` with your target domain.

### 1. Enumerate a Single Domain

```bash
./sinaSub.sh -d example.com
```

* Temporary files (`tmp-*.example.com`) will be created in the current folder for each tool.
* Final combined list of unique subdomains is saved as:

  ```
  sinsub-example.com-YYYY-MM-DD.txt
  ```

---

### 2. Enumerate Multiple Domains from a File

Prepare a text file (e.g. `domains.txt`) with one domain per line:

```
example.com
target.org
my.test-domain.io
```

Then run:

```bash
./sinaSub.sh -l domains.txt
```

* Each domain in `domains.txt` is processed in turn.
* Output files:

  ```
  sinsub-example.com-YYYY-MM-DD.txt
  sinsub-target.org-YYYY-MM-DD.txt
  sinsub-my.test-domain.io-YYYY-MM-DD.txt
  ```

---

### 3. Use Only Specific Tools

```bash
./sinaSub.sh -d example.com -u Findomain,Subfinder,Sublist3r
```

* `-u` (or `--use`) accepts a comma-separated list of tools to include. Valid tool names are:

  ```
  wayback, crt, abuseipdb, Findomain, Subfinder, Amass,
  Assetfinder, Sublist3r, GobusterDNS
  ```

---

### 4. Exclude Specific Tools

```bash
./sinaSub.sh -d example.com -e Amass,Assetfinder
```

* `-e` (or `--exclude`) accepts a comma-separated list of tools to skip.

---

### 5. Silent Mode (Only Print Subdomains)

```bash
./sinaSub.sh -d example.com -s
```

* Prints only the unique subdomains to standard output.
* Results are saved in `subenum-example.com.txt`.

---

### 6. Resolve Live Subdomains

```bash
./sinaSub.sh -d example.com -r
```

* After collecting subdomains, runs `dnsx` to check which ones resolve successfully.
* Live subdomains are saved in `resolved-example.com.txt`.

---

### 7. Run Tools in Parallel (Faster)

```bash
./sinaSub.sh -d example.com -p
```

* Uses GNU `parallel` to run every tool simultaneously.
* **Cannot** be combined with `-u/--use` or `-e/--exclude`.

---

### 8. Custom Output Filename

```bash
./sinaSub.sh -d example.com -o mysubs.txt
```

* Overrides the default filename (`sinsub-example.com-YYYY-MM-DD.txt`) and saves final results as `mysubs.txt`.

---

### 9. Adjust Number of Threads for DNS Probing

```bash
./sinaSub.sh -d example.com -r -t 100
```

* Uses 100 threads when running `dnsx` (or future HTTP/HTTPS probes).

---

### 10. Show Help or Version

```bash
./sinaSub.sh -h    # Display detailed usage  
./sinaSub.sh -v    # Show version (e.g., “sinsub v1.0.0”)
```

---

## 🔧 Troubleshooting & Tips

1. **Command Not Found Errors**
   If you see “command not found” for tools like `findomain`, `subfinder`, or `sublist3r`, make sure that:

   * `$HOME/go/bin` and `~/.local/bin` (where `pipx` installs binaries) are in your `PATH`:

     ```bash
     echo $PATH
     ```

     If not, add them and reload your shell:

     ```bash
     echo 'export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin' >> ~/.bashrc
     source ~/.bashrc
     ```

2. **Manual Installation of a Missing Tool**
   If `setup.sh` marked a tool as “Failed!”, install it manually:

   * **findomain**

     ```bash
     wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip
     unzip findomain-linux.zip
     sudo mv findomain /usr/local/bin/
     ```
   * **subfinder**

     ```bash
     go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
     ```
   * **amass**

     ```bash
     go install -v github.com/owasp-amass/amass/v4/...@master
     ```
   * **assetfinder**

     ```bash
     go install github.com/tomnomnom/assetfinder@latest
     ```
   * **dnsx**

     ```bash
     go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
     ```
   * **anew**

     ```bash
     go install -v github.com/tomnomnom/anew@latest
     ```
   * **sublist3r** (Python)

     ```bash
     pipx install sublist3r
     ```
   * **gobuster**

     ```bash
     sudo apt-get update && sudo apt-get install -y gobuster
     ```

3. **Using WSL (Windows Subsystem for Linux)**
   If you’re on WSL, install prerequisites first:

   ```bash
   sudo apt-get update
   sudo apt-get install -y wget unzip git pipx golang-go parallel
   ```

   Then add Go’s bin folder to your `PATH`:

   ```bash
   echo 'export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

---

<p align="center">
  ⭐️ You’re all set! Happy subdomain hunting with <strong>sinsub</strong>! ⭐️
</p>
```
