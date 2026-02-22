#!/usr/bin/env zsh
# Tests for IP_INTERFACE regex matching (#2900)
# Verifies that bridge interfaces (br*) are matched by config defaults.

emulate -L zsh

typeset -i pass=0 fail=0

assert_iface() {
  local desc=$1 pattern=$2 iface=$3 expected=$4
  local regex="^($pattern)\$"
  local result=0
  [[ $iface =~ $regex ]] && result=1
  if (( result == expected )); then
    print -P "%F{green}✓%f $desc"
    (( pass++ ))
  else
    print -P "%F{red}✗%f $desc (pattern='$pattern', iface='$iface', expected=$expected, got=$result)"
    (( fail++ ))
  fi
}

local default_pattern='[ewb].*'

# Ethernet interfaces
assert_iface "eth0 matches" "$default_pattern" "eth0" 1
assert_iface "enp0s3 matches" "$default_pattern" "enp0s3" 1
assert_iface "en0 matches" "$default_pattern" "en0" 1

# WiFi interfaces
assert_iface "wlan0 matches" "$default_pattern" "wlan0" 1
assert_iface "wlp2s0 matches" "$default_pattern" "wlp2s0" 1

# Bridge interfaces (#2900)
assert_iface "br0 matches" "$default_pattern" "br0" 1
assert_iface "br-docker matches" "$default_pattern" "br-docker" 1
assert_iface "bridge0 matches" "$default_pattern" "bridge0" 1

# Should not match
assert_iface "lo does not match" "$default_pattern" "lo" 0
assert_iface "docker0 does not match" "$default_pattern" "docker0" 0
assert_iface "veth123 does not match" "$default_pattern" "veth123" 0
assert_iface "tun0 does not match" "$default_pattern" "tun0" 0

# VPN interface pattern
local vpn_pattern='(gpd|wg|(.*tun)|tailscale)[0-9]*|(zt.*)'
assert_iface "wg0 matches VPN" "$vpn_pattern" "wg0" 1
assert_iface "tailscale0 matches VPN" "$vpn_pattern" "tailscale0" 1
assert_iface "tun0 matches VPN" "$vpn_pattern" "tun0" 1
assert_iface "zt12345 matches VPN" "$vpn_pattern" "zt12345" 1

print
if (( fail )); then
  print -P "%F{red}$fail test(s) failed%f, $pass passed"
  exit 1
else
  print -P "%F{green}All $pass tests passed%f"
fi
