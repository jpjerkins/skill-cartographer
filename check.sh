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

# --- Task 4: CHART.md ---
check "CHART.md defines the Oracle section"     'grep -q "Oracle" CHART.md'
check "CHART.md defines the sounding shape"     'grep -qi "sounding shape" CHART.md'
check "CHART.md names a tiebreaker"             'grep -qi "tiebreaker" CHART.md'
check "CHART.md defines all four ticket kinds"  '[ "$(grep -c "^- \*\*probe\*\*\|^- \*\*question\*\*\|^- \*\*research\*\*\|^- \*\*task\*\*" CHART.md)" -eq 4 ]'
check "CHART.md defines the three states"       'grep -q "prepped" CHART.md && grep -q "closed" CHART.md'
check "CHART.md defines frontier and eligible"  'grep -q "frontier" CHART.md && grep -q "eligible" CHART.md'
check "CHART.md constrains blocking edges"      'grep -qi "blocking edges" CHART.md'
check "CHART.md is within its sprawl cap"       '[ "$(wc -l < CHART.md)" -le 140 ]'

# --- Task 5: PREP.md ---
check "PREP.md states the variation rule"        'grep -qi "radical variation" PREP.md'
check "PREP.md names both failure modes"         'grep -qi "wallpaper" PREP.md && grep -qi "uninterpretable" PREP.md'
check "PREP.md states the variant cap"           'grep -q "5 variants" PREP.md'
check "PREP.md has a four-step escalation"       '[ "$(grep -c "^[1-4]\. \*\*" PREP.md)" -ge 4 ]'
check "PREP.md names fog wearing a ticket"       'grep -qi "wearing a ticket" PREP.md'
check "PREP.md defines the reaction prompt"      'grep -qi "reaction prompt" PREP.md'
check "PREP.md lists prototype constraints"      'grep -qi "prototype constraints" PREP.md'
check "PREP.md gives probe sizing in minutes"    'grep -q "5 minutes" PREP.md'
check "PREP.md is within its sprawl cap"         '[ "$(wc -l < PREP.md)" -le 140 ]'

# --- Task 6: BRIEF.md ---
check "BRIEF.md names all three priority terms" 'grep -qi "unblocking power" BRIEF.md && grep -qi "decay" BRIEF.md && grep -qi "cost" BRIEF.md'
check "BRIEF.md fixes the brief file path"      'grep -q "briefs/" BRIEF.md'
check "BRIEF.md sets the cut line at 80%"       'grep -q "80%" BRIEF.md'
check "BRIEF.md never cuts asks"                'grep -qi "never cut" BRIEF.md'
check "BRIEF.md orders breakers first"          'grep -qi "breakers first" BRIEF.md'
check "BRIEF.md places questions after probes"  'grep -qi "after that probe" BRIEF.md'
check "BRIEF.md carries the first-run preamble" 'grep -qi "first-run preamble" BRIEF.md'
check "the template has a Capture section"      'grep -q "## Capture" BRIEF.md'
check "the template carries the room rules"     'grep -qi "advocate" BRIEF.md && grep -qi "attribute everything" BRIEF.md'
check "BRIEF.md handles nothing-eligible"       'grep -qi "nothing is eligible" BRIEF.md'
check "BRIEF.md is within its sprawl cap"       '[ "$(wc -l < BRIEF.md)" -le 140 ]'

# --- Task 7: Advance ---
check "SKILL.md has an Advance section"           'grep -q "^## Advance" SKILL.md'
check "Advance transcribes before interpreting"   'grep -qi "transcribe" SKILL.md'
check "Advance refuses to average oracles"        'grep -qi "never average" SKILL.md'
check "Advance processes breakers first"          'grep -qi "breakers first\|breaker.*first" SKILL.md'
check "Advance classifies all five outcomes"      'grep -qi "composite" SKILL.md && grep -qi "none of these" SKILL.md && grep -qi "no discrimination" SKILL.md && grep -qi "not reached" SKILL.md'
check "Advance carries the interview question"    'grep -qi "back tomorrow unchanged" SKILL.md'
check "Advance rewrites rather than promotes"     'grep -qi "rewritten" SKILL.md'
check "converging nothing is a success"           'grep -qi "converges nothing" SKILL.md'
check "SKILL.md is within its sprawl cap"         '[ "$(wc -l < SKILL.md)" -le 200 ]'

# --- Task 8: failure-mode detectors ---
check "PREP.md caps prepping when contact stalls"  'grep -qi "stop prepping" PREP.md'
check "PREP.md guards against probe inflation"     'grep -qi "never a reason to spend contact budget" PREP.md'
check "BRIEF.md defines the carried count"         'grep -q "carried count" BRIEF.md'
check "CHART.md records the carried field"         'grep -q "carried:" CHART.md'
check "SKILL.md treats reversal as first-class"    'grep -qi "superseding" SKILL.md'
check "SKILL.md diagnoses whole-sounding politeness" 'grep -qi "every probe" SKILL.md'

echo "---"
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; fi
exit $([ "$fails" -eq 0 ] && echo 0 || echo 1)
