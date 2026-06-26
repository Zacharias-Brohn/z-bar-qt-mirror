#!/bin/bash
# =============================================================================
# wifi-sim.sh — Virtual WiFi environment for development & testing
#
# Creates 3 dummy networks using mac80211_hwsim + hostapd:
#   - FreeWifi       (open,  strong signal, ch 1)
#   - OfficeNetwork  (open,  medium signal, ch 6)
#   - HomeNetwork    (WPA2,  weak signal,   ch 11)
#
# Usage:
#   sudo ./wifi-sim.sh start
#   sudo ./wifi-sim.sh stop
#   sudo ./wifi-sim.sh status
# =============================================================================

set -euo pipefail

# --- User configuration ------------------------------------------------------

SSID_STRONG="FreeWifi"      # Open network, strong signal
SSID_MEDIUM="OfficeNetwork" # Open network, medium signal
SSID_SECURE="HomeNetwork"   # WPA2 network, weak signal
WIFI_PASSWORD="testpassword123"

# TX power levels in mBm (millibel-milliwatts). Higher = stronger signal.
# These affect the RSSI reported to scanning clients.
TXPOWER_STRONG=3000 # 30 dBm
TXPOWER_MEDIUM=1500 # 15 dBm
TXPOWER_WEAK=100    #  1 dBm

RUN_DIR="/tmp/wifi-sim"

# --- Helpers -----------------------------------------------------------------

die() {
	echo "ERROR: $*" >&2
	exit 1
}
info() { echo "[*] $*"; }
ok() { echo "[+] $*"; }

require_cmds() {
	local missing=()
	for cmd in "$@"; do
		command -v "$cmd" &>/dev/null || missing+=("$cmd")
	done
	if [[ ${#missing[@]} -gt 0 ]]; then
		die "Missing required tools: ${missing[*]}
       Install with: sudo apt install hostapd wpasupplicant iw"
	fi
}

get_phy_for_iface() {
	iw dev "$1" info | awk '/wiphy/{print "phy"$2}'
}

# --- Start -------------------------------------------------------------------

cmd_start() {
	[[ $EUID -ne 0 ]] && die "Please run as root:  sudo $0 start"
	require_cmds hostapd iw ip

	if [[ -d "$RUN_DIR" && -f "$RUN_DIR/interfaces" ]]; then
		die "wifi-sim appears to already be running. Run 'sudo $0 stop' first."
	fi
	mkdir -p "$RUN_DIR"

	# Snapshot existing wlan interfaces so we can identify the new ones
	info "Snapshotting existing interfaces..."
	BEFORE=($(iw dev 2>/dev/null | awk '/Interface/{print $2}' | grep -v '^hwsim' || true))

	# Load the kernel module with 4 radios (3 APs + 1 client)
	info "Loading mac80211_hwsim (4 radios)..."
	if lsmod | grep -q mac80211_hwsim; then
		die "mac80211_hwsim is already loaded. Run 'sudo $0 stop' or 'sudo rmmod mac80211_hwsim' first."
	fi
	modprobe mac80211_hwsim radios=4
	sleep 1 # Give the kernel a moment to register all interfaces

	# Find the interfaces created by our modprobe
	AFTER=($(iw dev 2>/dev/null | awk '/Interface/{print $2}' | grep -v '^hwsim'))
	NEW_IFACES=()
	for iface in "${AFTER[@]}"; do
		[[ ! " ${BEFORE[*]:-} " =~ " $iface " ]] && NEW_IFACES+=("$iface")
	done

	if [[ ${#NEW_IFACES[@]} -lt 4 ]]; then
		rmmod mac80211_hwsim 2>/dev/null || true
		die "Expected 4 new wlan interfaces, found ${#NEW_IFACES[@]}. Check 'dmesg' for errors."
	fi

	AP1="${NEW_IFACES[0]}"    # Will host SSID_STRONG
	AP2="${NEW_IFACES[1]}"    # Will host SSID_MEDIUM
	AP3="${NEW_IFACES[2]}"    # Will host SSID_SECURE
	CLIENT="${NEW_IFACES[3]}" # Client-side interface for your code to use

	info "Interfaces assigned: AP1=$AP1  AP2=$AP2  AP3=$AP3  Client=$CLIENT"
	echo "$AP1 $AP2 $AP3 $CLIENT" >"$RUN_DIR/interfaces"

	# Prevent NetworkManager from fighting us over these interfaces
	if command -v nmcli &>/dev/null && nmcli general status &>/dev/null 2>&1; then
		info "Marking interfaces as unmanaged in NetworkManager..."
		for iface in "$AP1" "$AP2" "$AP3"; do
			nmcli device set "$iface" managed no 2>/dev/null || true
		done

		nmcli device set "$CLIENT" managed yes
	fi

	# Set TX power on each physical radio to simulate signal strength differences.
	# mac80211_hwsim factors TX power into the RSSI reported to scanning clients.
	# Note: for precise RSSI control, consider 'wmediumd' (a wireless medium daemon).
	info "Setting TX power levels for signal strength simulation..."
	PHY1=$(get_phy_for_iface "$AP1")
	PHY2=$(get_phy_for_iface "$AP2")
	PHY3=$(get_phy_for_iface "$AP3")

	iw phy "$PHY1" set txpower fixed $TXPOWER_STRONG
	iw phy "$PHY2" set txpower fixed $TXPOWER_MEDIUM
	iw phy "$PHY3" set txpower fixed $TXPOWER_WEAK

	# --- hostapd config: AP1 (open, strong, channel 1) -----------------------
	cat >"$RUN_DIR/ap1.conf" <<EOF
interface=$AP1
driver=nl80211
ssid=$SSID_STRONG
hw_mode=g
channel=1
auth_algs=1
wmm_enabled=0
ignore_broadcast_ssid=0
EOF

	# --- hostapd config: AP2 (open, medium, channel 6) -----------------------
	cat >"$RUN_DIR/ap2.conf" <<EOF
interface=$AP2
driver=nl80211
ssid=$SSID_MEDIUM
hw_mode=g
channel=6
auth_algs=1
wmm_enabled=0
ignore_broadcast_ssid=0
EOF

	# --- hostapd config: AP3 (WPA2, weak, channel 11) ------------------------
	cat >"$RUN_DIR/ap3.conf" <<EOF
interface=$AP3
driver=nl80211
ssid=$SSID_SECURE
hw_mode=g
channel=11
auth_algs=1
wpa=2
wpa_passphrase=$WIFI_PASSWORD
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wmm_enabled=0
ignore_broadcast_ssid=0
EOF

	# Start a hostapd instance for each AP
	info "Starting hostapd instances..."
	hostapd -B -P "$RUN_DIR/ap1.pid" "$RUN_DIR/ap1.conf" \
		>"$RUN_DIR/ap1.log" 2>&1 ||
		{
			cat "$RUN_DIR/ap1.log"
			die "hostapd failed for AP1. See log above."
		}

	hostapd -B -P "$RUN_DIR/ap2.pid" "$RUN_DIR/ap2.conf" \
		>"$RUN_DIR/ap2.log" 2>&1 ||
		{
			cat "$RUN_DIR/ap2.log"
			die "hostapd failed for AP2. See log above."
		}

	hostapd -B -P "$RUN_DIR/ap3.pid" "$RUN_DIR/ap3.conf" \
		>"$RUN_DIR/ap3.log" 2>&1 ||
		{
			cat "$RUN_DIR/ap3.log"
			die "hostapd failed for AP3. See log above."
		}

	# Bring up the client interface so it's ready to scan/connect
	ip link set "$CLIENT" up

	# --- Summary -------------------------------------------------------------
	ok "Virtual WiFi environment is up!"
	echo ""
	echo "  Networks:"
	echo "  ┌──────────────────┬──────────┬────────┬─────────────┐"
	echo "  │ SSID             │ Security │ Signal │ Interface   │"
	echo "  ├──────────────────┼──────────┼────────┼─────────────┤"
	printf "  │ %-16s │ %-8s │ %-6s │ %-11s │\n" "$SSID_STRONG" "Open" "Strong" "$AP1"
	printf "  │ %-16s │ %-8s │ %-6s │ %-11s │\n" "$SSID_MEDIUM" "Open" "Medium" "$AP2"
	printf "  │ %-16s │ %-8s │ %-6s │ %-11s │\n" "$SSID_SECURE" "WPA2" "Weak" "$AP3"
	echo "  └──────────────────┴──────────┴────────┴─────────────┘"
	echo ""
	echo "  WPA2 password : $WIFI_PASSWORD"
	echo "  Client iface  : $CLIENT  (use this in your code)"
	echo ""
	echo "  Useful commands:"
	echo "    Scan for networks : sudo iw dev $CLIENT scan | grep -E 'SSID|signal'"
	echo "    Connect (open)    : sudo iw dev $CLIENT connect \"$SSID_STRONG\""
	echo "    Connect (WPA2)    : sudo wpa_supplicant -Dnl80211 -i$CLIENT \\"
	echo "                          -c <(wpa_passphrase \"$SSID_SECURE\" \"$WIFI_PASSWORD\")"
	echo "    Stop simulation   : sudo $0 stop"
	echo ""
	echo "  Logs: $RUN_DIR/ap{1,2,3}.log"
}

# --- Stop --------------------------------------------------------------------

cmd_stop() {
	[[ $EUID -ne 0 ]] && die "Please run as root:  sudo $0 stop"

	info "Stopping virtual WiFi environment..."
	local had_something=false

	# Kill hostapd processes via PID files
	for ap in ap1 ap2 ap3; do
		PID_FILE="$RUN_DIR/$ap.pid"
		if [[ -f "$PID_FILE" ]]; then
			PID=$(cat "$PID_FILE")
			if kill "$PID" 2>/dev/null; then
				info "Stopped hostapd for $ap (PID $PID)"
			fi
			rm -f "$PID_FILE"
			had_something=true
		fi
	done

	# Re-enable NetworkManager management for these interfaces
	if [[ -f "$RUN_DIR/interfaces" ]]; then
		read -r AP1 AP2 AP3 CLIENT <"$RUN_DIR/interfaces"
		if command -v nmcli &>/dev/null; then
			for iface in "$AP1" "$AP2" "$AP3" "$CLIENT"; do
				nmcli device set "$iface" managed yes 2>/dev/null || true
			done
		fi
	fi

	# Unload the kernel module (also destroys all virtual interfaces)
	if lsmod | grep -q mac80211_hwsim; then
		info "Unloading mac80211_hwsim..."
		rmmod mac80211_hwsim && had_something=true
	fi

	# Clean up runtime directory
	rm -rf "$RUN_DIR"

	if $had_something; then
		ok "Virtual WiFi environment stopped."
	else
		echo "Nothing was running."
	fi
}

# --- Status ------------------------------------------------------------------

cmd_status() {
	if [[ ! -f "$RUN_DIR/interfaces" ]]; then
		echo "wifi-sim is not running."
		return
	fi

	read -r AP1 AP2 AP3 CLIENT <"$RUN_DIR/interfaces"
	echo "wifi-sim is running."
	echo ""
	echo "  Interfaces:"
	for iface in "$AP1" "$AP2" "$AP3" "$CLIENT"; do
		STATE=$(ip link show "$iface" 2>/dev/null | awk '/state/{print $9}' || echo "unknown")
		CHANNEL=$(iw dev "$iface" info 2>/dev/null | awk '/channel/{print $2}' || echo "?")
		printf "  %-10s  state=%-4s  channel=%s\n" "$iface" "$STATE" "$CHANNEL"
	done
	echo ""
	echo "  Processes:"
	for ap in ap1 ap2 ap3; do
		PID_FILE="$RUN_DIR/$ap.pid"
		if [[ -f "$PID_FILE" ]]; then
			PID=$(cat "$PID_FILE")
			if kill -0 "$PID" 2>/dev/null; then
				echo "  hostapd ($ap)  PID=$PID  running"
			else
				echo "  hostapd ($ap)  PID=$PID  DEAD (check $RUN_DIR/$ap.log)"
			fi
		fi
	done
}

# --- Entry point -------------------------------------------------------------

case "${1:-help}" in
start) cmd_start ;;
stop) cmd_stop ;;
status) cmd_status ;;
*)
	echo "Usage: sudo $0 {start|stop|status}"
	echo ""
	echo "  start   Load mac80211_hwsim and bring up 3 virtual APs"
	echo "  stop    Tear down all virtual interfaces and unload module"
	echo "  status  Show current state of interfaces and processes"
	echo ""
	echo "Networks created on start:"
	printf "  %-16s  open,  strong signal\n" "$SSID_STRONG"
	printf "  %-16s  open,  medium signal\n" "$SSID_MEDIUM"
	printf "  %-16s  WPA2,  weak signal   (password: $WIFI_PASSWORD)\n" "$SSID_SECURE"
	;;
esac
