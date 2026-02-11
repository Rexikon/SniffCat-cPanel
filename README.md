<div align="center">

# SniffCat cPHulk Integration

**Automatically report brute force attackers from cPanel/WHM to [SniffCat](https://sniffcat.com)**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![cPanel](https://img.shields.io/badge/cPanel-Compatible-orange.svg)](https://cpanel.net)
[![SniffCat](https://img.shields.io/badge/SniffCat-API%20v1-green.svg)](https://sniffcat.com)

</div>

---

## Overview

SniffCat-cPanel integrates **cPHulk Brute Force Protection** (built into cPanel/WHM) with the [SniffCat](https://sniffcat.com) threat intelligence API. When cPHulk detects and blocks a brute force attack, this integration automatically reports the attacker's IP address to SniffCat, contributing to a shared threat intelligence database.

### How It Works

```
Attacker → cPHulk detects brute force → cphulk.sh triggered → IP reported to SniffCat API
```

1. **cPHulk** detects a brute force attack and blocks the offending IP
2. **cPHulk** executes the configured command (`cphulk.sh`) with attack details
3. **cphulk.sh** sends a structured report to the SniffCat API with the attacker's IP and metadata

## Requirements

- cPanel/WHM server with **cPHulk** enabled
- `curl` installed on the server
- **Root** access
- SniffCat API token — [get one here](https://sniffcat.com)

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/install.sh)
```

The installer will interactively ask for your SniffCat API token and handle everything else.

## Installation

### Automatic (recommended)

Using **curl**:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/install.sh)
```

Using **wget**:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/install.sh)
```

The installer will:

- Verify root access and dependencies
- Ask for your SniffCat API token
- Install the script to `/opt/sniffcat/`
- Create a secure config file (`chmod 600`)
- Set up logging to `/var/log/sniffcat.log`
- Display the WHM configuration instructions

### Manual

```bash
# Create installation directory
mkdir -p /opt/sniffcat

# Download the script
curl -fsSL https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/cphulk.sh \
    -o /opt/sniffcat/cphulk.sh

# Make it executable
chmod 755 /opt/sniffcat/cphulk.sh

# Create config file with your token
cat > /opt/sniffcat/sniffcat.conf <<EOF
SNIFFCAT_TOKEN="your-token-here"
EOF

# Secure the config file
chmod 600 /opt/sniffcat/sniffcat.conf

# Create log file
touch /var/log/sniffcat.log
chmod 640 /var/log/sniffcat.log
```

## WHM Configuration

1. Log in to **WHM**
2. Navigate to **Security Center** → **cPHulk Brute Force Protection**
3. Find the **IP Address-based Protection** section
4. In the field **"Command to Run When an IP Address Triggers Brute Force Protection"**, enter:

```
/opt/sniffcat/cphulk.sh %remote_ip% %authservice% %user% %current_failures% %reason%
```

5. Click **Save**

### cPHulk Parameters

| Parameter | cPHulk Variable      | Description                               |
|-----------|----------------------|-------------------------------------------|
| `$1`      | `%remote_ip%`        | IP address of the attacker                |
| `$2`      | `%authservice%`      | Service being attacked (SMTP, FTP, etc.)  |
| `$3`      | `%user%`             | Username used in the attack attempt       |
| `$4`      | `%current_failures%` | Number of failed authentication attempts  |
| `$5`      | `%reason%`           | Reason for the block                      |

## File Structure

```
/opt/sniffcat/
├── cphulk.sh          # Main script (755)
└── sniffcat.conf      # API token configuration (600)

/var/log/
└── sniffcat.log       # Activity log (640)
```

## Logs

Only errors are logged to `/var/log/sniffcat.log` — successful reports are silent:

```
2026-02-11 12:34:56 [SniffCat] ERROR: IP=203.0.113.50 service=smtp user=admin — HTTP 401: {"error":"invalid token"}
2026-02-11 13:01:22 [SniffCat] ERROR: Config file not found: /opt/sniffcat/sniffcat.conf
```

## Uninstallation

Using the uninstaller:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/uninstall.sh)
```

Or manually:

```bash
rm -rf /opt/sniffcat
rm -f /var/log/sniffcat.log
```

> **Note:** Remember to remove the command from WHM → cPHulk Brute Force Protection settings after uninstalling.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
