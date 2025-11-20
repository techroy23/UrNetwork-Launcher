# UrNetwork-Launcher
A tool that streamlines GitHub release management. It automatically detects system architecture, downloads and caches the latest release assets, extracts provider binaries, reads credentials from ENV.ini, and runs authentication in one seamless workflow.

---

## ✨ Features
- 🔍 **Architecture Detection**  
  Automatically detects `amd64`, `arm64`.

- 📦 **Release Asset Management**  
  Fetches the latest `.tar.gz` asset from GitHub releases using the REST API.

- ⚡ **Caching & Extraction**  
  Skips re-downloads if cached, extracts provider binaries for your system.

- 🔑 **Credential Handling**  
  Reads `USER` and `PASS` from `ENV.ini` securely via PowerShell.

- 🔐 **Provider Authentication**  
  Runs `provider auth-provide` with parsed credentials.

- 🧹 **Cleanup**  
  Removes temporary files and folders after execution.

---

## 🚀 Usage

1. Clone or download this repository.
2. Create or Edit the `ENV.ini` file with:
   ```ini
   USER=email.email@email.com
   PASS=myV3rYsEcUr3P@sSw0Rd
   ```
3. Run the _start.bat

## ⚠️ Notes
- Do not commit your ENV.ini file to GitHub for security reasons.
