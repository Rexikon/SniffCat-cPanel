#!/bin/bash
# SniffCat cPHulk Integration - Uninstaller
# https://github.com/Rexikon/SniffCat-cPanel
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/uninstall.sh)
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

INSTALL_DIR="/opt/sniffcat"
LOG_FILE="/var/log/sniffcat.log"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR]${NC} This script must be run as root."
    exit 1
fi

# --- Confirm ---
echo ""
echo -e "${BOLD}SniffCat cPHulk Integration - Uninstaller${NC}"
echo ""
echo -e "${YELLOW}The following will be removed:${NC}"
echo "  - ${INSTALL_DIR}/ (directory and all contents)"
echo "  - ${LOG_FILE}"
echo ""
read -rp "$(echo -e "${RED}Are you sure you want to uninstall? [y/N]: ${NC}")" confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# --- Remove files ---
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}[OK]${NC} Removed ${INSTALL_DIR}"
else
    echo -e "${YELLOW}[SKIP]${NC} ${INSTALL_DIR} not found"
fi

if [[ -f "$LOG_FILE" ]]; then
    rm -f "$LOG_FILE"
    echo -e "${GREEN}[OK]${NC} Removed ${LOG_FILE}"
else
    echo -e "${YELLOW}[SKIP]${NC} ${LOG_FILE} not found"
fi

echo ""
echo -e "${GREEN}Uninstallation complete.${NC}"
echo -e "${YELLOW}Remember to remove the command from WHM → cPHulk Brute Force Protection settings.${NC}"
echo ""
