#!/bin/bash
# SniffCat cPHulk Integration
# Reports brute force IPs detected by cPHulk to the SniffCat API
#
# https://github.com/Rexikon/SniffCat-cPanel
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# --- Paths ---
INSTALL_DIR="/opt/sniffcat"
CONFIG_FILE="${INSTALL_DIR}/sniffcat.conf"
LOG_FILE="/var/log/sniffcat.log"
API_URL="https://api.sniffcat.com/api/v1/report"

# --- Arguments from cPHulk ---
IP="${1:-}"
SERVICE="${2:-}"
USER="${3:-}"
FAILURES="${4:-}"
REASON="${5:-}"

# --- Functions ---
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SniffCat] $*" >> "$LOG_FILE" 2>/dev/null || true
}

die() {
    log "ERROR: $*"
    exit 1
}

# --- Validation ---
[[ -z "$IP" ]] && die "No IP address provided"

# --- Load config ---
[[ -f "$CONFIG_FILE" ]] || die "Config file not found: $CONFIG_FILE"
# shellcheck source=/dev/null
source "$CONFIG_FILE"
[[ -z "${SNIFFCAT_TOKEN:-}" ]] && die "SNIFFCAT_TOKEN not set in $CONFIG_FILE"

# --- Report to SniffCat API ---
RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "X-Secret-Token: ${SNIFFCAT_TOKEN}" \
    --data "{
        \"ip\": \"${IP}\",
        \"categories\": [17],
        \"comment\": \"Banned by cPHulk | service: ${SERVICE}, user: ${USER}, failures: ${FAILURES}, reason: ${REASON}\"
    }" 2>&1) || true

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [[ ! "$HTTP_CODE" =~ ^2[0-9]{2}$ ]]; then
    log "ERROR: IP=${IP} service=${SERVICE} user=${USER} — HTTP ${HTTP_CODE}: ${BODY}"
fi
