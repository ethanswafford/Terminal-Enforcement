#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./sec-start.sh            # auto-detect interface
#   ./sec-start.sh eth0       # specify interface
#
# Requires: sudo, tmux, nethogs, iftop, systemctl, aide (optional but recommended), auditd, suricata

IFACE="${1:-}"

detect_iface() {
  # Default route interface is usually what you want
  ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}'
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

echo "[*] Starting security stack..."

# Detect interface if not provided
if [[ -z "${IFACE}" ]]; then
  IFACE="$(detect_iface || true)"
fi

if [[ -z "${IFACE}" ]]; then
  echo "[!] Could not auto-detect interface. Run: ./sec-start.sh <iface>  (e.g., eth0, wlan0, tun0)"
  exit 1
fi

echo "[*] Using interface: ${IFACE}"

# Start services
echo "[*] Starting auditd..."
sudo systemctl start auditd || true
sudo systemctl --no-pager --full status auditd || true

echo "[*] Starting suricata..."
sudo systemctl start suricata || true
sudo systemctl --no-pager --full status suricata || true

# Initialize AIDE only if DB not present
if need_cmd aideinit; then
  if [[ -f /var/lib/aide/aide.db.gz || -f /var/lib/aide/aide.db ]]; then
    echo "[*] AIDE database already exists. Skipping aideinit."
  else
    echo "[*] Running AIDE initialization (first-time setup)..."
    sudo aideinit
    # Common post-step: move new DB into place
    if [[ -f /var/lib/aide/aide.db.new.gz ]]; then
      echo "[*] Installing new AIDE database..."
      sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    elif [[ -f /var/lib/aide/aide.db.new ]]; then
      echo "[*] Installing new AIDE database..."
      sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    else
      echo "[!] AIDE init finished, but expected DB file not found where anticipated."
      echo "    Check /var/lib/aide/ for aide.db.new*"
    fi
  fi
else
  echo "[!] aideinit not found. (Install with: sudo apt install aide)"
fi

# Launch nethogs + iftop inside tmux
if ! need_cmd tmux; then
  echo "[!] tmux not found. Install with: sudo apt install tmux"
  echo "    Then re-run this script."
  exit 1
fi

if ! need_cmd nethogs; then
  echo "[!] nethogs not found. Install with: sudo apt install nethogs"
  exit 1
fi

if ! need_cmd iftop; then
  echo "[!] iftop not found. Install with: sudo apt install iftop"
  exit 1
fi

SESSION="secmon"

echo "[*] Launching tmux session '${SESSION}' with nethogs + iftop..."
# If session exists, just attach
if tmux has-session -t "${SESSION}" 2>/dev/null; then
  tmux attach -t "${SESSION}"
  exit 0
fi

tmux new-session -d -s "${SESSION}" "sudo nethogs ${IFACE}"
tmux split-window -h -t "${SESSION}" "sudo iftop -i ${IFACE}"
tmux select-layout -t "${SESSION}" even-horizontal
tmux attach -t "${SESSION}"
EOF

chmod +x sec-start.sh
