# UrNetwork Windows CLI BootStrap

> Desktop application for running UrNetwork node and SOCKS proxy services on Windows

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Usage](#usage)
7. [How It Works](#how-it-works)
8. [Project Structure](#project-structure)
9. [Features](#features)
10. [Troubleshooting](#troubleshooting)
11. [Security](#security)
12. [FAQ](#faq)
13. [Changelog](#changelog)
14. [Support](#support)

---

## Introduction

UrNetwork is a decentralized network platform that provides peer-to-peer services. This desktop application simplifies running UrNetwork components on Windows by automating:

- **Automatic Updates**: Downloads the latest binary versions from GitHub
- **Easy Configuration**: Simple INI file for credentials and settings
- **Architecture Support**: Works on both AMD64 and ARM64 Windows systems
- **Cache System**: Reuses downloaded files to save bandwidth and time

### What Can You Run?

| Service | Binary | Description |
| :--- | :--- | :--- |
| **Provider Node** | `ur_provider.exe` | Contribute to the network by running a full node |
| **SOCKS Proxy** | `ur_socks.exe` | Route your internet traffic through UrNetwork |

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
| :--- | :--- | :--- |
| Operating System | Windows 10/11 | Windows 11 |
| Architecture | amd64 or arm64 | amd64 |
| Internet Connection | Required | High-speed |
| Disk Space | 500 MB | 1 GB |
| RAM | 512 MB | 1 GB |

### Software Requirements

- **Windows 10 version 1803 or later** or **Windows 11**
- **PowerShell 5.1 or later** (included with Windows)
- **curl** (included with Windows 10 1803+)
- **tar** (included with Windows 10 1803+)

---

## Quick Start

1. **Clone or download** this repository
2. **Copy** `env.ini.example` to `ENV.ini`
3. **Edit** `ENV.ini` with your credentials
4. **Run** `_start_node.bat` or `_start_socks.bat`

```cmd
copy env.ini.example ENV.ini
notepad ENV.ini
_start_node.bat
```

That's it! The script will automatically download and set up everything you need.

---

## Installation

### Step 1: Get the Files

Clone the repository or download the ZIP:

```cmd
git clone https://github.com/your-repo/UrNetwork.git
cd UrNetwork
```

### Step 2: Configure Credentials

1. Copy the example configuration:
   ```cmd
   copy env.ini.example ENV.ini
   ```

2. Open in your favorite text editor:
   ```cmd
   notepad ENV.ini
   ```

3. Fill in your credentials (see [Configuration](#configuration) below)

### Step 3: Run the Application

- **For Node**: Double-click `_start_node.bat` or run `\_start_node.bat`
- **For Proxy**: Double-click `_start_socks.bat` or run `\_start_socks.bat`

The first run will download the binaries automatically. Subsequent runs will use cached versions.

---

## Configuration

### ENV.ini File Format

The configuration file uses standard INI format:

```ini
[SECTION_NAME]
key=value
```

### NODE Section

Required for running the provider node:

| Key | Required | Description | Example |
| :--- | :--- | :--- | :--- |
| USER | Yes | Your UrNetwork account username/email | user@example.com |
| PASS | Yes | Your UrNetwork account password | MySecurePassword123 |

### PROXY Section

Required for running the SOCKS proxy:

| Key | Required | Description | Default |
| :--- | :--- | :--- | :--- |
| USER | Yes | Your UrNetwork account username/email | user@example.com |
| PASS | Yes | Your UrNetwork account password | MySecurePassword123 |
| COUNTRY | No | Country to announce your proxy from | United States |
| LISTEN_ADDR | No | IP and port for the proxy to listen on | 127.0.0.1:1080 |

### Example Configuration

```ini
[NODE]
USER=john@example.com
PASS=SecureP@ssw0rd!

[PROXY]
USER=john@example.com
PASS=SecureP@ssw0rd!
COUNTRY=United States
LISTEN_ADDR=127.0.0.1:1080
```

---

## Usage

### Starting the Provider Node

The provider node makes your machine part of the UrNetwork infrastructure:

```cmd
_start_node.bat
```

What happens:
1. Searches GitHub releases for matching Windows asset
2. Downloads latest provider binary if needed
3. Extracts the executable
4. Reads your credentials from ENV.ini
5. Starts the provider with authentication

The node will continue running until you close the window or press Ctrl+C.

### Starting the SOCKS Proxy

The SOCKS proxy lets you route traffic through UrNetwork:

```cmd
_start_socks.bat
```

What happens:
1. Searches GitHub releases for matching Windows asset
2. Downloads latest proxy binary if needed
3. Extracts the executable
4. Reads your credentials and settings from ENV.ini
5. Starts the proxy server

Configure your applications to use `127.0.0.1:1080` (or your custom LISTEN_ADDR) as a SOCKS5 proxy.

### Exit Behavior

- **Successful run**: Window closes automatically
- **Error occurred**: Window stays open so you can read error messages
- **Manual exit**: Press Ctrl+C or close the window

---

## How It Works

### The Startup Process

Each batch script performs these steps in sequence:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         START                                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  1. Display Banner                                                  │
│     - Show ASCII logo                                               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  2. Detect Architecture                                            │
│     - Check PROCESSOR_ARCHITECTURE                                 │
│     - Determine amd64 or arm64                                     │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  3. Query GitHub API (paginated)                                   │
│     - Page through releases (up to 10 pages)                      │
│     - Find first release with a matching asset                    │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  4. Download (with retry)                                           │
│     - Check cache first                                            │
│     - Download if needed                                           │
│     - Retry up to 3 times on failure                               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  5. Extract Binary                                                  │
│     - Decompress tar.gz                                            │
│     - Extract from windows/{arch} folder                          │
│     - Rename to ur_provider.exe or ur_socks.exe                  │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  6. Verify & Cleanup                                               │
│     - Confirm executable exists                                    │
│     - Remove temporary extraction folder                          │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  7. Read Configuration                                              │
│     - Parse ENV.ini                                                 │
│     - Extract credentials and settings                             │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  8. Run Binary                                                      │
│     - Execute ur_provider or ur_socks                              │
│     - Pass credentials as arguments                                 │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         END                                         │
└─────────────────────────────────────────────────────────────────────┘
```

### Cache System

Downloaded binaries are cached in the `cached/` folder:

- `cached/urnetwork-provider-*.tar.gz` - Provider archive
- `cached/urnetwork-proxy-socks-*.tar.gz` - Proxy archive

On subsequent runs, the script checks if the cached file matches the latest version. If so, it skips the download, saving time and bandwidth.

### Temporary Files

During extraction, temporary folders are created:

- `cached/extracted_node/` - Provider extraction
- `cached/extracted_socks/` - Proxy extraction

These are automatically cleaned up after successful extraction.

---

## Project Structure

| File/Directory | Description |
| :--- | :--- |
| `README.md` | This file - user documentation |
| `ENV.ini` | Your configuration (create from env.ini.example) |
| `env.ini.example` | Template for configuration |
| `_start_node.bat` | Script to start the provider node |
| `_start_socks.bat` | Script to start the SOCKS proxy |
| `ur_provider.exe` | Provider binary (auto-downloaded) |
| `ur_socks.exe` | Proxy binary (auto-downloaded) |
| `cached/` | Downloaded archives and temp files |
| `.gitignore` | Git ignore rules |

---

## Features

### Implemented Features

- ✅ Automatic updates from GitHub releases
- ✅ Smart caching - skips download if already cached
- ✅ Architecture detection (amd64/arm64)
- ✅ Retry logic for failed downloads
- ✅ File integrity checks (empty file detection)
- ✅ Temp folder cleanup on failure
- ✅ Conditional pause (close on success, stay open on error)
- ✅ Clean error messages
- ✅ ASCII art banner
- ✅ Paginated release search — finds the matching Windows asset even when the latest release does not include it

---

## Troubleshooting

### Error: "Unknown architecture detected"

**Cause**: Your CPU architecture is not supported.

**Solution**: This bootstrap only supports AMD64 (Intel/AMD 64-bit) and ARM64 (ARM 64-bit) processors. Check your system specs.

---

### Error: "No urnetwork-provider-*.tar.gz asset found"

**Cause**: No recent release contains a Windows asset matching the expected name prefix.

**Solution**:
1. Check your internet connection
2. Verify https://github.com/urnetwork/build is accessible
3. The script now searches up to 10 pages of releases to find a matching asset — if none exists, no recent release has the Windows binary
4. Check if the asset naming convention has changed

---

### Error: "Download failed after 3 attempts"

**Cause**: Network connectivity issues or GitHub is down.

**Solution**:
1. Check your internet connection
2. Try again later
3. Manually download the file and place in `cached/` folder
4. Check firewall/proxy settings

---

### Error: "USER not set in ENV.ini"

**Cause**: Missing or misconfigured credentials in ENV.ini.

**Solution**:
1. Verify ENV.ini exists
2. Check the [NODE] section has USER= and PASS= lines
3. Ensure format is `KEY=value` (no spaces around =)
4. Make sure you're not using semicolons for comments

---

### Error: "ENV.ini not found in current directory"

**Cause**: ENV.ini file is missing.

**Solution**:
```cmd
copy env.ini.example ENV.ini
notepad ENV.ini
```

---

### Binary crashes immediately

**Cause**: Invalid credentials or network issues.

**Solution**:
1. Verify credentials in ENV.ini are correct
2. Check your internet connection
3. Try running the binary manually with `--help` to see options

---

### Proxy not working

**Cause**: Incorrect proxy configuration in your application.

**Solution**:
1. Verify the proxy is running (check the output)
2. Confirm LISTEN_ADDR in ENV.ini (default: 127.0.0.1:1080)
3. Configure your application to use SOCKS5 (not HTTP)
4. Try 127.0.0.1:1080 as the proxy address

---

## FAQ

### Can I run both services at once?

Yes, you can run both `_start_node.bat` and `_start_socks.bat` simultaneously in separate command windows.

### Where do I get credentials?

Refer to your UrNetwork account registration. The credentials are the same for both node and proxy services.

### How do I stop the service?

Close the command window or press Ctrl+C in the window running the service.

### Can I change the proxy port?

Yes, edit `LISTEN_ADDR` in the [PROXY] section of ENV.ini. Format: `IP:PORT` (e.g., `127.0.0.1:1080`).

### How do updates work?

On each run, the script checks GitHub for a newer release. If found and different from your cached version, it downloads automatically.

### Can I use my own downloaded binaries?

Yes! Place the `ur_provider.exe` or `ur_socks.exe` in the project folder, and the script will use them instead of downloading.

### Where are logs?

Currently, there is no logging system. Output is displayed in the console window.

### Is this open source?

This wrapper project is open source. The UrNetwork binaries themselves have their own licensing.

---

## Support

### Getting Help

1. **Check this README** - Most common questions are answered here
2. **Check Troubleshooting** - Specific error solutions
3. **Check FAQ** - Common questions

### Reporting Issues

When reporting issues, include:

- Windows version
- Error message (exact text)
- What step failed
- Your ENV.ini (remove passwords first!)

---

## License

This project is provided as-is under the MIT License.

The UrNetwork binaries (ur_provider.exe, ur_socks.exe) are distributed by their respective owners and are subject to their own licensing terms.

---
