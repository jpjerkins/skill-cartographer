#!/bin/sh
# Structural conformance checker for the cartographer skill.
# Each assertion prints PASS or FAIL; any failure exits 1.
cd "$(dirname "$0")" || exit 1
fails=0

check() { # check <description> <shell-condition-as-string>
  if eval "$2" >/dev/null 2>&1; then
    echo "PASS  $1"
  else
    echo "FAIL  $1"
    fails=$((fails + 1))
  fi
}

# --- Task 1: files exist ---
check "SKILL.md exists"  '[ -f SKILL.md ]'
check "CHART.md exists"  '[ -f CHART.md ]'
check "PREP.md exists"   '[ -f PREP.md ]'
check "BRIEF.md exists"  '[ -f BRIEF.md ]'

# --- Task 2: SKILL.md core ---
check "SKILL.md frontmatter names the skill"        'head -5 SKILL.md | grep -q "^name: cartographer$"'
check "SKILL.md disables model invocation"          'head -5 SKILL.md | grep -q "^disable-model-invocation: true$"'
check "SKILL.md has a description line"             'head -5 SKILL.md | grep -q "^description: "'
check "SKILL.md states the Advance-before-Prep rule" 'grep -q "Advance before Prep" SKILL.md'
check "SKILL.md states the widen-never-advance rule" 'grep -qi "widen, never advance" SKILL.md'
check "SKILL.md carries the five-phase table"        '[ "$(grep -c "^| [0-4] |" SKILL.md)" -eq 5 ]'
check "the two absolute rules live only in SKILL.md" '[ "$(grep -l "Advance before Prep" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -eq 1 ]'

# --- Task 3: provenance and routing ---
check "SKILL.md defines all three provenance tags"   'grep -q "assumed" SKILL.md && grep -q "predicted" SKILL.md && grep -q "sounded" SKILL.md'
check "the quote rule appears exactly once"          '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "No quote, no tag")" -eq 1 ]'
check "the confirmed-prediction rule is stated"      'grep -q "never becomes .sounded" SKILL.md'
check "SKILL.md points at CHART.md"                  'grep -q "CHART.md" SKILL.md'
check "SKILL.md points at PREP.md"                   'grep -q "PREP.md" SKILL.md'
check "SKILL.md points at BRIEF.md"                  'grep -q "BRIEF.md" SKILL.md'
check "every pointed-at file exists"                 '( for f in $(grep -o "[A-Z]*\.md" SKILL.md | sort -u); do [ -f "$f" ] || exit 1; done )'

echo "---"
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; fi
exit $([ "$fails" -eq 0 ] && echo 0 || echo 1)
