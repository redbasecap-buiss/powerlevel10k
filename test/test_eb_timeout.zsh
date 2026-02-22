#!/usr/bin/env zsh
# Test: eb list timeout protection
# Verifies that the eb list call in prompt_aws_eb_env uses timeout.

set -euo pipefail

source_file="${0:A:h}/../internal/p10k.zsh"

echo "=== Test: eb list timeout ==="

# Verify the source contains timeout wrapping for eb list
if grep -q 'command timeout 10 eb list' "$source_file"; then
  echo "PASS: eb list has 10-second timeout"
else
  echo "FAIL: eb list missing timeout wrapper"
  exit 1
fi

echo "=== Test: taskwarrior timeout ==="

# Verify task show has timeout
if grep -q 'command timeout 5 task show' "$source_file"; then
  echo "PASS: task show has 5-second timeout"
else
  echo "FAIL: task show missing timeout wrapper"
  exit 1
fi

# Verify task count has timeout
if grep -q 'command timeout 5 task +\$name count' "$source_file"; then
  echo "PASS: task count has 5-second timeout"
else
  echo "FAIL: task count missing timeout wrapper"
  exit 1
fi

# Verify task list has timeout
if grep -q 'command timeout 5 task +PENDING' "$source_file"; then
  echo "PASS: task list has 5-second timeout"
else
  echo "FAIL: task list missing timeout wrapper"
  exit 1
fi

echo ""
echo "All timeout tests passed!"
