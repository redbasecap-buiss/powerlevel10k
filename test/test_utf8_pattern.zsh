#!/usr/bin/env zsh
# Tests for UTF-8 codeset matching patterns (#2887)
# Verifies that case statements work correctly as replacements for
# the problematic (utf|UTF)(-|)8 alternation pattern.

typeset -i pass=0 fail=0

assert_match() {
  local desc=$1 codeset=$2 expected=$3
  local result=0
  case "$codeset" in
    utf-8|UTF-8|utf8|UTF8) result=1;;
  esac
  if (( result == expected )); then
    print -P "%F{green}✓%f $desc"
    (( pass++ ))
  else
    print -P "%F{red}✗%f $desc (codeset='$codeset', expected=$expected, got=$result)"
    (( fail++ ))
  fi
}

assert_match "UTF-8 matches" "UTF-8" 1
assert_match "utf-8 matches" "utf-8" 1
assert_match "UTF8 matches" "UTF8" 1
assert_match "utf8 matches" "utf8" 1
assert_match "LATIN-1 does not match" "LATIN-1" 0
assert_match "ASCII does not match" "ASCII" 0
assert_match "empty does not match" "" 0
assert_match "UTF-16 does not match" "UTF-16" 0
assert_match "utf-8-mac does not match" "utf-8-mac" 0

# Verify case statement works without extended_glob
emulate -L zsh
unsetopt extended_glob

local codeset="UTF-8"
local matched=0
case "$codeset" in
  utf-8|UTF-8|utf8|UTF8) matched=1;;
esac
if (( matched )); then
  print -P "%F{green}✓%f case statement works without extended_glob"
  (( pass++ ))
else
  print -P "%F{red}✗%f case statement fails without extended_glob"
  (( fail++ ))
fi

print
if (( fail )); then
  print -P "%F{red}$fail test(s) failed%f, $pass passed"
  exit 1
else
  print -P "%F{green}All $pass tests passed%f"
fi
