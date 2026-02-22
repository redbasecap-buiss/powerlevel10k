#!/usr/bin/env zsh
# Tests for haskell_stack resolver parsing improvements (#2890)

emulate -L zsh
setopt extended_glob

typeset -i pass=0 fail=0

assert_eq() {
  local desc=$1 expected=$2 actual=$3
  if [[ $expected == $actual ]]; then
    print -P "%F{green}✓%f $desc"
    (( pass++ ))
  else
    print -P "%F{red}✗%f $desc (expected '$expected', got '$actual')"
    (( fail++ ))
  fi
}

# Test resolver extraction from stack.yaml content
parse_resolver() {
  local content=$1
  local resolver
  resolver="$(print -r -- $content | command sed -n 's/^resolver:[[:space:]]*//p' 2>/dev/null)"
  resolver="${resolver#url:}"
  resolver="${resolver## }"
  resolver="${resolver#\"}"
  resolver="${resolver%\"}"
  print -r -- "$resolver"
}

# Test ghc-* resolver pattern
resolver=$(parse_resolver "resolver: ghc-9.6.3")
case $resolver in
  ghc-*) v="${resolver#ghc-}";;
  *) v="";;
esac
assert_eq "ghc-X.Y.Z resolver extracts version" "9.6.3" "$v"

# Test LTS resolver (should not match ghc-* pattern)
resolver=$(parse_resolver "resolver: lts-22.7")
case $resolver in
  ghc-*) v="${resolver#ghc-}";;
  *) v="fallback";;
esac
assert_eq "lts resolver triggers fallback" "fallback" "$v"

# Test nightly resolver
resolver=$(parse_resolver "resolver: nightly-2024-01-15")
case $resolver in
  ghc-*) v="${resolver#ghc-}";;
  *) v="fallback";;
esac
assert_eq "nightly resolver triggers fallback" "fallback" "$v"

# Test resolver with url: prefix
resolver=$(parse_resolver 'resolver: url: "https://raw.githubusercontent.com/.../snapshot.yaml"')
case $resolver in
  ghc-*) v="${resolver#ghc-}";;
  *) v="fallback";;
esac
assert_eq "url resolver triggers fallback" "fallback" "$v"

# Test quoted ghc resolver
resolver=$(parse_resolver 'resolver: "ghc-9.4.8"')
case $resolver in
  ghc-*) v="${resolver#ghc-}";;
  *) v="fallback";;
esac
assert_eq "quoted ghc resolver extracts version" "9.4.8" "$v"

# Test resolver with extra whitespace
resolver=$(parse_resolver "resolver:   ghc-9.2.1")
case $resolver in
  ghc-*) v="${resolver#ghc-}";;
  *) v="fallback";;
esac
assert_eq "resolver with extra whitespace" "9.2.1" "$v"

print
if (( fail )); then
  print -P "%F{red}$fail test(s) failed%f, $pass passed"
  exit 1
else
  print -P "%F{green}All $pass tests passed%f"
fi
