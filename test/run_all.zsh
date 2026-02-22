#!/usr/bin/env zsh
# Run all tests in the test directory

emulate -L zsh
local -i total_pass=0 total_fail=0
local test_dir="${0:h}"

print -P "%F{cyan}Running all tests...%f"
print

for test_file in "$test_dir"/test_*.zsh; do
  print -P "%F{cyan}━━━ ${test_file:t} ━━━%f"
  if zsh "$test_file"; then
    (( total_pass++ ))
  else
    (( total_fail++ ))
  fi
  print
done

print -P "%F{cyan}━━━ Summary ━━━%f"
if (( total_fail )); then
  print -P "%F{red}$total_fail test file(s) failed%f, $total_pass passed"
  exit 1
else
  print -P "%F{green}All $total_pass test files passed%f"
fi
