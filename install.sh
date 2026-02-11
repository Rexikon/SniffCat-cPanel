#!/bin/bash
# SniffCat cPHulk Integration - Installer
# https://github.com/Rexikon/SniffCat-cPanel
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main/install.sh)
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# --- Configuration ---
INSTALL_DIR="/opt/sniffcat"
CONFIG_FILE="${INSTALL_DIR}/sniffcat.conf"
SCRIPT_NAME="cphulk.sh"
REPO_URL="https://raw.githubusercontent.com/Rexikon/SniffCat-cPanel/main"
LOG_FILE="/var/log/sniffcat.log"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- Functions ---
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

banner() {
    echo ""
    echo -e "${BOLD}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║     SniffCat cPHulk Integration       ║"
    echo "  ║            Installer v1.0              ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# --- Banner ---
banner

# --- Pre-checks ---

# Root check
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use: sudo bash install.sh"
fi

# Check for curl
if ! command -v curl &>/dev/null; then
    error "curl is required but not installed. Install it with: yum install curl"
fi

# Check for cPanel/WHM
if [[ ! -d "/usr/local/cpanel" ]]; then
    warn "cPanel does not appear to be installed on this server."
    read -rp "Continue anyway? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# Check for existing installation
if [[ -f "${INSTALL_DIR}/${SCRIPT_NAME}" ]]; then
    warn "Existing installation detected at ${INSTALL_DIR}"
    read -rp "Overwrite? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# --- Token Input ---
echo ""
info "You need a SniffCat API token to continue."
info "Get your token at: ${BOLD}https://sniffcat.com${NC}"
echo ""

read -rp "$(echo -e "${YELLOW}Enter your SniffCat API token: ${NC}")" TOKEN

if [[ -z "$TOKEN" ]]; then
    error "Token cannot be empty."
fi

if [[ ${#TOKEN} -lt 10 ]]; then
    warn "Token seems too short. Are you sure it's correct?"
    read -rp "Continue? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# --- Installation ---
echo ""
info "Installing SniffCat cPHulk integration..."

# Create install directory
mkdir -p "$INSTALL_DIR"
success "Created directory: ${INSTALL_DIR}"

# Download script
info "Downloading ${SCRIPT_NAME}..."
if curl -fsSL "${REPO_URL}/${SCRIPT_NAME}" -o "${INSTALL_DIR}/${SCRIPT_NAME}"; then
    success "Downloaded: ${INSTALL_DIR}/${SCRIPT_NAME}"
else
    error "Failed to download ${SCRIPT_NAME} from ${REPO_URL}"
fi

# Create config file
cat > "$CONFIG_FILE" <<EOF
# SniffCat Configuration
# https://sniffcat.com
#
# API Token for authentication
SNIFFCAT_TOKEN="${TOKEN}"
EOF
success "Created config: ${CONFIG_FILE}"

# Set permissions
chmod 755 "${INSTALL_DIR}/${SCRIPT_NAME}"
chmod 600 "$CONFIG_FILE"
success "Set permissions (script: 755, config: 600)"

# Create log file
touch "$LOG_FILE"
chmod 640 "$LOG_FILE"
success "Created log file: ${LOG_FILE}"

# --- Verify installation ---
echo ""
info "Verifying installation..."

if [[ -x "${INSTALL_DIR}/${SCRIPT_NAME}" ]] && [[ -f "$CONFIG_FILE" ]]; then
    success "Installation completed successfully!"
else
    error "Installation verification failed."
fi

# --- Next steps ---
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Next Steps${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  1. Log in to ${BOLD}WHM${NC}"
echo ""
echo -e "  2. Navigate to:"
echo -e "     ${BLUE}Security Center → cPHulk Brute Force Protection${NC}"
echo ""
echo -e "  3. In the ${BOLD}IP Address-based Protection${NC} section, set"
echo -e "     ${YELLOW}\"Command to Run When an IP Address Triggers"
echo -e "     Brute Force Protection\"${NC} to:"
echo ""
echo -e "     ${GREEN}${INSTALL_DIR}/${SCRIPT_NAME} %remote_ip% %authservice% %user% %current_failures% %reason%${NC}"
echo ""
echo -e "  4. ${BOLD}Save${NC} the settings."
echo ""
echo -e "  ${BLUE}Logs:${NC}   ${LOG_FILE}"
echo -e "  ${BLUE}Config:${NC} ${CONFIG_FILE}"
echo ""
