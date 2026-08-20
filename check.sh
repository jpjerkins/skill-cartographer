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

# flat <file...> — the file(s) with newlines and runs of whitespace collapsed to
# single spaces, so a phrase split across a markdown line wrap still matches.
flat() { cat "$@" | tr '\n' ' ' | tr -s ' '; }

# --- Task 1: files exist ---
check "SKILL.md exists"  '[ -f SKILL.md ]'
check "CHART.md exists"  '[ -f CHART.md ]'
check "PREP.md exists"   '[ -f PREP.md ]'
check "BRIEF.md exists"  '[ -f BRIEF.md ]'

# --- Task 2: SKILL.md core ---
check "SKILL.md frontmatter names the skill"        'head -5 SKILL.md | grep -q "^name: cartographer$"'
check "SKILL.md disables model invocation"          'head -5 SKILL.md | grep -q "^disable-model-invocation: true$"'
check "SKILL.md has a description line"             'head -5 SKILL.md | grep -q "^description: "'
check "SKILL.md states the Advance-before-Prep rule" 'flat SKILL.md | grep -q "Advance before Prep\.\*\* Never build new variant sets while unadvanced reactions sit on the chart"'
check "SKILL.md states the widen-never-advance rule" 'flat SKILL.md | grep -qi "Between contacts: widen, never advance" && flat SKILL.md | grep -q "Build on a reaction, never on an un-reacted-to decision"'
check "SKILL.md carries the five-phase table"        '[ "$(grep -c "^| [0-4] |" SKILL.md)" -eq 5 ] && grep -q "^| 3 | \*\*Sound\*\* | \*\*human\*\*" SKILL.md'
check "the two absolute rules live only in SKILL.md" '[ "$(grep -l "Advance before Prep" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -eq 1 ]'

# --- Task 3: provenance and routing ---
check "SKILL.md defines all three provenance tags"   'flat SKILL.md | grep -q "| .assumed. | You picked it to make progress" && flat SKILL.md | grep -q "| .predicted. | A human stated it, without seeing anything working" && flat SKILL.md | grep -q "| .sounded. | A human reacted to a working artifact"'
check "SKILL.md names the four provenance mechanisms" 'flat SKILL.md | grep -q "Prefer reversible guesses" && flat SKILL.md | grep -q "Violate load-bearing assumptions" && flat SKILL.md | grep -q "Re-examine on touch" && flat SKILL.md | grep -q "Destination gate"'
check "the quote rule appears exactly once"          '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "No quote, no tag")" -eq 1 ] && flat SKILL.md | grep -q "requires a quoted human utterance. No quote, no tag"'
check "the confirmed-prediction rule is stated"      'flat SKILL.md | grep -q "A confirmed prediction never becomes .sounded..\*\* Nobody reacted to it. It stays .predicted."'
check "SKILL.md points at CHART.md"                  'grep -q "(CHART.md)" SKILL.md'
check "SKILL.md points at PREP.md"                   'grep -q "(PREP.md)" SKILL.md'
check "SKILL.md points at BRIEF.md"                  'grep -q "(BRIEF.md)" SKILL.md'
check "every pointed-at file exists"                 '( for f in $(grep -o "[A-Z]*\.md" SKILL.md | sort -u); do [ -f "$f" ] || exit 1; done )'

# --- Task 4: CHART.md ---
check "CHART.md defines the Oracle section"     'flat CHART.md | grep -q "\*\*Oracle\*\* — who the authority actually is" && flat CHART.md | grep -qi "proxy" && flat CHART.md | grep -q "budget \*\*in minutes\*\*"'
check "CHART.md defines the sounding shape"     'flat CHART.md | grep -q "\*\*Sounding shape\*\* — chosen once, from oracle reachability" && flat CHART.md | grep -q "variant switcher | self-contained shareable file | published artifact"'
check "CHART.md names a tiebreaker"             'flat CHART.md | grep -q "\*\*tiebreaker line\*\* naming who decides when the room splits"'
check "CHART.md defines all four ticket kinds"  '[ "$(grep -c "^- \*\*probe\*\*\|^- \*\*question\*\*\|^- \*\*research\*\*\|^- \*\*task\*\*" CHART.md)" -eq 4 ]'
check "CHART.md defines the three states"       'flat CHART.md | grep -q ".open. → .prepped. → .closed."'
check "CHART.md defines frontier and eligible"  'flat CHART.md | grep -q "\*\*frontier\*\* = open, unclaimed, not prepped" && flat CHART.md | grep -q "\*\*eligible\*\* = .prepped. and its required oracle will be present"'
check "CHART.md constrains blocking edges"      'flat CHART.md | grep -q "\*\*never\*\* express that one decision must precede another"'
check "CHART.md requires both links on sounded" 'flat CHART.md | grep -q "For .sounded. lines only, carry \*\*both\*\* links"'
check "CHART.md is within its sprawl cap"       '[ "$(wc -l < CHART.md)" -le 140 ]'

# --- Task 5: PREP.md ---
check "PREP.md states the variation rule"        'flat PREP.md | grep -q "\*\*Radical variation on the axis under test. Everything off-axis held constant.\*\*"'
check "PREP.md names both failure modes"         'flat PREP.md | grep -q "\*\*Wallpaper\*\* — variants differ only in degree" && flat PREP.md | grep -q "\*\*Uninterpretable\*\* — variants differ everywhere"'
check "PREP.md states the variant cap"           'flat PREP.md | grep -q "At most 5 variants, at least 2 on-axis"'
check "PREP.md has a four-step escalation"       '[ "$(grep -c "^[1-4]\. \*\*" PREP.md)" -ge 4 ] && flat PREP.md | grep -q "Two axes?\*\* Split into two probes" && flat PREP.md | grep -q "Can the assumptions just be asked?\*\* Promote them to .question. tickets" && flat PREP.md | grep -q "One assumption dominating?\*\* Re-aim the probe at it directly" && flat PREP.md | grep -q "None of the above?\*\*"'
check "PREP.md names fog wearing a ticket"       'flat PREP.md | grep -q "fog wearing a ticket.s clothes.\*\* Demote it"'
check "PREP.md defines a breaker as a gate"      'flat PREP.md | grep -q "\*\*breaker\*\* is a variant built specifically to violate a load-bearing assumption — a \*\*gate\*\*, not a competitor"'
check "PREP.md defines the reaction prompt"      'flat PREP.md | grep -q "2–3 forced choices phrased so approval isn.t an available answer"'
check "PREP.md lists prototype constraints"      'flat PREP.md | grep -q "No tests, no error handling beyond runnability, no persistence, no abstraction"'
check "PREP.md gives probe sizing in minutes"    'flat PREP.md | grep -q "Target \*\*~5 minutes\*\* of reaction per probe, aiming for 2–4 probes per sounding"'
check "PREP.md is within its sprawl cap"         '[ "$(wc -l < PREP.md)" -le 140 ]'

# --- Task 6: BRIEF.md ---
check "BRIEF.md names all three priority terms" 'flat BRIEF.md | grep -q "\*\*Unblocking power\*\* — native blocking relations pointing at the ticket" && flat BRIEF.md | grep -q "\*\*Decay\*\* — count of .assumed./.predicted. decision lines dated after" && flat BRIEF.md | grep -q "\*\*Cost\*\* — estimated reaction minutes"'
check "BRIEF.md fixes the brief file path"      'grep -q "briefs/YYYY-MM-DD-<oracle>.md" BRIEF.md'
check "BRIEF.md sets the cut line at 80%"       'flat BRIEF.md | grep -q "The cut line falls at \*\*80%\*\* of the chart.s stated budget"'
check "BRIEF.md never cuts asks"                'flat BRIEF.md | grep -q "Asks get their own section.*are \*\*never cut\*\* — they are handed over, not reacted to"'
check "BRIEF.md orders breakers first"          'flat BRIEF.md | grep -q "\*\*Breakers first\*\* (see .PREP.md.), matching Advance.s processing order"'
check "BRIEF.md places questions after probes"  'flat BRIEF.md | grep -q "is asked immediately \*\*after that probe\*\*.s reaction"'
check "BRIEF.md carries the first-run preamble" 'flat BRIEF.md | grep -q "<first-run preamble, first few soundings with this oracle:>" && flat BRIEF.md | grep -q "looks good. isn.t an answer I can use"'
check "the template has a Capture section"      'grep -q "^## Capture" BRIEF.md && flat BRIEF.md | grep -q "Capture verbatim, attributed by name, hedges intact"'
check "the template carries the room rules"     'flat BRIEF.md | grep -q "1. Don.t advocate — present, then stop talking. 2. Don.t accept approval — use the reaction prompt below. 3. Attribute everything by name."'
check "BRIEF.md handles nothing-eligible"       'flat BRIEF.md | grep -q "\*\*Nothing is eligible\*\* at all → no agenda, and a chart finding"'
check "BRIEF.md is within its sprawl cap"       '[ "$(wc -l < BRIEF.md)" -le 140 ]'

# --- Task 7: Advance ---
check "SKILL.md has an Advance section"           'grep -q "^## Advance" SKILL.md'
check "Advance transcribes before interpreting"   'flat SKILL.md | grep -q "\*\*Transcribe, don.t interpret\*\* — verbatim, attributed, hedges intact, before any analysis"'
check "Advance refuses to average oracles"        'flat SKILL.md | grep -q "When oracles disagree, never average\*\*: the disagreement \*is\* the finding"'
check "Advance processes breakers first"          'flat SKILL.md | grep -q "\*\*Record and process breakers first\*\* — a breaker winning is a bigger result than any on-axis win"'
check "Advance classifies all five outcomes"      'flat SKILL.md | grep -q "one variant wins → converge" && flat SKILL.md | grep -q "\*\*composite\*\* → the axis has sub-structure" && flat SKILL.md | grep -q "none of these.\*\* → the question was wrong" && flat SKILL.md | grep -q "\*\*no discrimination\*\* → the probe failed" && flat SKILL.md | grep -q "\*\*not reached\*\* → normal, just where the \*\*cut line\*\*"'
check "Advance carries the interview question"    'flat SKILL.md | grep -q "Would you take this same probe back tomorrow unchanged, or does it need reframing?"'
check "Advance rewrites rather than promotes"     'flat SKILL.md | grep -q "Not promoted, rewritten: variants carry prototype constraints"'
check "converging nothing is a success"           'flat SKILL.md | grep -q "An Advance session that converges nothing is a successful session"'
check "SKILL.md is within its sprawl cap"         '[ "$(wc -l < SKILL.md)" -le 200 ]'

# --- Task 8: failure-mode detectors ---
check "PREP.md caps prepping when contact stalls"  'flat PREP.md | grep -q "\*\*Stop prepping\*\* past roughly two soundings. worth"'
check "PREP.md guards against probe inflation"     'flat PREP.md | grep -q "\*\*Provenance quality is never a reason to spend contact budget.\*\* Probe load-bearing things; ask the rest"'
check "BRIEF.md defines the carried count"         'flat BRIEF.md | grep -q "the \*\*carried count\*\* on each stretch item, incremented every time the item rides below the cut line" && flat BRIEF.md | grep -q "At three carries it is mispriced rather than unlucky"'
check "CHART.md records the carried field"         'flat CHART.md | grep -q "\*\*.carried:.\*\*, an integer starting at 0, incremented by Brief each time the ticket falls below the cut line"'
check "SKILL.md treats reversal as first-class"    'flat SKILL.md | grep -q "Write a \*\*superseding\*\* decision line and keep both"'
check "SKILL.md diagnoses whole-sounding politeness" 'flat SKILL.md | grep -q "if \*\*every probe\*\* in the sounding classifies this way"'

# --- Task 9: audit ---
check "the five-phase table appears only once"   '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "| \*\*Chart\*\* |")" -le 1 ]'
check "no reference file restates the loop"      '! grep -qi "N Prep sessions feed one Brief" CHART.md PREP.md BRIEF.md'
check "the phrase sounding shape is defined once" '[ "$(grep -l "sounding shape" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -le 2 ]'
check "no file carries an unresolved placeholder" '! grep -rniE "TBD|TODO|FIXME|XXX" SKILL.md CHART.md PREP.md BRIEF.md'

echo "---"
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; fi
exit $([ "$fails" -eq 0 ] && echo 0 || echo 1)
