#!/usr/bin/env zsh
# Test transient prompt duration formatting
# Run: zsh test/test_transient_duration.zsh

emulate -L zsh

local -i pass=0 fail=0

function assert_eq() {
  local desc=$1 expected=$2 actual=$3
  if [[ $expected == $actual ]]; then
    (( pass++ ))
    print -P "%F{green}✓%f $desc"
  else
    (( fail++ ))
    print -P "%F{red}✗%f $desc: expected '$expected', got '$actual'"
  fi
}

# Simulate the duration formatting logic from precmd
function format_duration() {
  local -F seconds=$1 threshold=$2
  if (( seconds < threshold )); then
    print ""
    return
  fi
  local -i d=$((seconds + 0.5))
  if (( d < 60 )); then
    print "${d}s"
  elif (( d < 3600 )); then
    print "$((d / 60))m $((d % 60))s"
  elif (( d < 86400 )); then
    print "$((d / 3600))h $((d / 60 % 60))m $((d % 60))s"
  else
    print "$((d / 86400))d $((d / 3600 % 24))h $((d / 60 % 60))m"
  fi
}

# Test cases
assert_eq "below threshold" "" "$(format_duration 2.5 3)"
assert_eq "at threshold" "3s" "$(format_duration 3.0 3)"
assert_eq "seconds" "5s" "$(format_duration 5.2 3)"
assert_eq "rounds up" "6s" "$(format_duration 5.7 3)"
assert_eq "one minute" "1m 0s" "$(format_duration 60 3)"
assert_eq "minutes+seconds" "2m 30s" "$(format_duration 150 3)"
assert_eq "one hour" "1h 0m 0s" "$(format_duration 3600 3)"
assert_eq "hours+min+sec" "1h 30m 45s" "$(format_duration 5445 3)"
assert_eq "one day" "1d 0h 0m" "$(format_duration 86400 3)"
assert_eq "days+hours" "2d 3h 15m" "$(format_duration 184500 3)"
assert_eq "zero threshold" "1s" "$(format_duration 1.0 0)"

print
if (( fail == 0 )); then
  print -P "%F{green}All $pass tests passed%f"
else
  print -P "%F{red}$fail/$((pass+fail)) tests failed%f"
  exit 1
fi
