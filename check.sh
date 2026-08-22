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

# block <file> <start-BRE> <end-address> — the lines of <file> from the first
# line matching <start-BRE> through <end-address> (a sed address: /^## Next/ for
# the next heading, or $ for end of file), so an assertion can be anchored to one
# section instead of matching anywhere in the file. Deleting the section makes
# the range empty, which fails the assertion.
block() { sed -n "/$2/,$3 p" "$1"; }

# flatblock — block, flattened for wrap-tolerant multi-word matching.
flatblock() { block "$1" "$2" "$3" | tr '\n' ' ' | tr -s ' '; }

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
check "SKILL.md opens with the thesis"               'flat SKILL.md | grep -q "conversation produces guesses; only reaction to a working artifact produces evidence" && flat SKILL.md | grep -q "Contact with the oracle has not.\*\* Contact is the scarce resource"'
check "SKILL.md states the wayfinder inheritance"    'flat SKILL.md | grep -q "standalone fork of .\/wayfinder. and inherits its machinery" && flat SKILL.md | grep -q "consult the tracker doc, exactly as .\/wayfinder. does"'
check "the two absolute rules live only in SKILL.md" '[ "$(grep -l "Advance before Prep" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -eq 1 ]'

# --- Task 3: provenance and routing ---
check "SKILL.md defines all three provenance tags"   'flat SKILL.md | grep -q "| .assumed. | You picked it to make progress" && flat SKILL.md | grep -q "| .predicted. | A human stated it, without seeing anything working" && flat SKILL.md | grep -q "| .sounded. | A human reacted to a working artifact"'
check "SKILL.md names the four provenance mechanisms" 'flat SKILL.md | grep -q "Prefer reversible guesses" && flat SKILL.md | grep -q "Violate load-bearing assumptions" && flat SKILL.md | grep -q "Re-examine on touch" && flat SKILL.md | grep -q "Destination gate"'
check "the quote rule appears exactly once"          '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "No quote, no tag")" -eq 1 ] && flat SKILL.md | grep -q "requires a quoted human utterance. No quote, no tag"'
check "the confirmed-prediction rule is stated"      'flat SKILL.md | grep -q "A confirmed prediction never becomes .sounded..\*\* Nobody reacted to it. It stays .predicted."'
check "SKILL.md points at CHART.md"                  'grep -q "(CHART.md)" SKILL.md'
check "SKILL.md points at PREP.md"                   'grep -q "(PREP.md)" SKILL.md'
check "SKILL.md points at BRIEF.md"                  'grep -q "(BRIEF.md)" SKILL.md'
# Local pointers are bare filenames; a path with a slash (docs/agents/issue-tracker.md)
# names a file in the TARGET repo, not this one, so it is deliberately excluded.
check "every pointed-at file exists"                 '( for f in $(grep -oh "[A-Za-z0-9_/.-]*[A-Za-z0-9]\.md" SKILL.md CHART.md PREP.md BRIEF.md | grep -v "/" | sort -u); do [ -f "$f" ] || exit 1; done )'
check "the routing block asks four gates in order"   '[ "$(block SKILL.md "^## Which phase am I in" "/^## Advance/" | grep -c "^[0-9]\. \*\*")" -eq 4 ] && flatblock SKILL.md "^## Which phase am I in" "/^## Advance/" | grep -q "Ask in this order and take the first that applies"'
check "routing gate 1 is the no-chart gate"          'flatblock SKILL.md "^## Which phase am I in" "/^## Advance/" | grep -q "1. \*\*No chart for this effort yet?\*\* → \*\*Chart.\*\* Read \[.CHART.md.\](CHART.md)"'
check "routing gate 4 falls through to Prep"         'flatblock SKILL.md "^## Which phase am I in" "/^## Advance/" | grep -q "4. \*\*Otherwise\*\* → \*\*Prep.\*\* Read \[.PREP.md.\](PREP.md)"'
check "routing gate 2 states its test"               'flatblock SKILL.md "^## Which phase am I in" "/^## Advance/" | grep -q "Unadvanced reactions sitting on the chart?\*\* — a file under .briefs/. with a filled-in .## Capture. section whose tickets are still .prepped."'
check "the routing block keeps Sound out of session" 'flatblock SKILL.md "^## Which phase am I in" "/^## Advance/" | grep -q "Sound is never your session"'

# --- Task 4: CHART.md ---
check "CHART.md defines the Oracle section"     'flat CHART.md | grep -q "\*\*Oracle\*\* — who the authority actually is" && flat CHART.md | grep -qi "proxy" && flat CHART.md | grep -q "budget \*\*in minutes\*\*"'
check "CHART.md defines the sounding shape"     'flat CHART.md | grep -q "\*\*Sounding shape\*\* — chosen once, from oracle reachability" && flat CHART.md | grep -q "variant switcher | self-contained shareable file | published artifact"'
check "CHART.md names a tiebreaker"             'flat CHART.md | grep -q "\*\*tiebreaker line\*\* naming who decides when the room splits"'
check "CHART.md defines all four ticket kinds"  '[ "$(grep -c "^- \*\*probe\*\*\|^- \*\*question\*\*\|^- \*\*research\*\*\|^- \*\*task\*\*" CHART.md)" -eq 4 ]'
check "CHART.md defines the three states"       'flat CHART.md | grep -q ".open. → .prepped. → .closed."'
check "CHART.md defines frontier and eligible"  'flat CHART.md | grep -q "\*\*frontier\*\* = open, unclaimed, not prepped" && flat CHART.md | grep -q "\*\*eligible\*\* = .prepped. and its required oracle will be present"'
check "CHART.md constrains blocking edges"      'flat CHART.md | grep -q "\*\*never\*\* express that one decision must precede another"'
check "CHART.md requires three links on sounded" 'flat CHART.md | grep -q "For .sounded. lines only, carry \*\*three\*\* links" && flat CHART.md | grep -q "the variant set that produced the reaction (evidence), the commit or PR that embodies it (embodiment), and the brief file whose .## Capture. section holds the quoted utterance"'
check "CHART.md keeps the reversal rationale"   'flat CHART.md | grep -q "makes a later reversal tractable instead of archaeological"'
check "CHART.md states the fog body convention" 'flat CHART.md | grep -q "Fog patches in \*Not yet specified\* name the ticket(s) that would sharpen them, written when that ticket is created" && flat CHART.md | grep -q "Fog isn.t a ticket, so it cannot hold a native relation — this is the one place a body convention is used"'
check "CHART.md orders the charting session"    '[ "$(block CHART.md "^## Charting session order" "$" | grep -c "^[0-9]\. ")" -eq 6 ] && flatblock CHART.md "^## Charting session order" "$" | grep -q "1. \*\*Name the destination — grill it out of the human" && flatblock CHART.md "^## Charting session order" "$" | grep -q "6. Wire blocking edges in a second pass"'
check "CHART.md is within its sprawl cap"       '[ "$(wc -l < CHART.md)" -le 140 ] && [ "$(wc -l < CHART.md)" -ge 60 ]'

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
check "PREP.md orders the Prep session"          '[ "$(block PREP.md "^## Session order" "/^## Sizing/" | grep -c "^[0-9]\. ")" -eq 7 ] && flatblock PREP.md "^## Session order" "/^## Sizing/" | grep -q "1. Claim the ticket." && flatblock PREP.md "^## Session order" "/^## Sizing/" | grep -q "7. Record .assumed. entries; label the ticket .prepped., link the artifact."'
check "the Prep session order stops on no-comparison" 'flatblock PREP.md "^## Session order" "/^## Sizing/" | grep -q "If no comparison would reveal the answer, reclassify as a .question. and \*\*stop\*\* — do not build"'
check "PREP.md is within its sprawl cap"         '[ "$(wc -l < PREP.md)" -le 140 ] && [ "$(wc -l < PREP.md)" -ge 60 ]'

# --- Task 6: BRIEF.md ---
check "BRIEF.md names all three priority terms" 'flat BRIEF.md | grep -q "\*\*Unblocking power\*\* — native blocking relations pointing at the ticket" && flat BRIEF.md | grep -q "\*\*Decay\*\* — count of .assumed./.predicted. decision lines dated after" && flat BRIEF.md | grep -q "\*\*Cost\*\* — estimated reaction minutes"'
check "BRIEF.md fixes the brief file path"      'grep -q "briefs/YYYY-MM-DD-<oracle>.md" BRIEF.md'
check "BRIEF.md sets the cut line at 80%"       'flat BRIEF.md | grep -q "The cut line falls at \*\*80%\*\* of the chart.s stated budget"'
check "BRIEF.md never cuts asks"                'flat BRIEF.md | grep -q "Asks get their own section.*are \*\*never cut\*\* — they are handed over, not reacted to"'
check "BRIEF.md orders breakers first"          'flat BRIEF.md | grep -q "\*\*Breakers first\*\* (see .PREP.md.), matching Advance.s processing order"'
check "BRIEF.md places questions after probes"  'flat BRIEF.md | grep -q "is asked immediately \*\*after that probe\*\*.s reaction"'
check "BRIEF.md carries the first-run preamble" 'flat BRIEF.md | grep -q "<first-run preamble, first few soundings with this oracle:>" && flat BRIEF.md | grep -q "looks good. isn.t an answer I can use"'
check "the template has a Capture section"      'block BRIEF.md "^\`\`\`markdown" "/^\`\`\`\$/" | grep -q "^## Capture" && flat BRIEF.md | grep -q "Capture verbatim, attributed by name, hedges intact"'
check "the capture is written in the room"      'flatblock BRIEF.md "^\`\`\`markdown" "/^\`\`\`\$/" | grep -q "Written in the room or immediately after — never reconstructed days later"'
check "BRIEF.md asks who is attending and when" 'flat BRIEF.md | grep -q "Ask the human two things first, before anything else in the session: who is attending, and on what date.\*\*" && flat BRIEF.md | grep -q "oracle plus date name the brief file"'
check "the template carries the room rules"     'flat BRIEF.md | grep -q "1. Don.t advocate — present, then stop talking. 2. Don.t accept approval — use the reaction prompt below. 3. Attribute everything by name."'
check "BRIEF.md handles nothing-eligible"       'flat BRIEF.md | grep -q "\*\*Nothing is eligible\*\* at all → no agenda, and a chart finding"'
check "BRIEF.md is within its sprawl cap"       '[ "$(wc -l < BRIEF.md)" -le 140 ] && [ "$(wc -l < BRIEF.md)" -ge 60 ]'

# --- Task 7: Advance ---
check "SKILL.md has an Advance section"           'grep -q "^## Advance" SKILL.md'
check "Advance transcribes before interpreting"   'flat SKILL.md | grep -q "\*\*Transcribe, don.t interpret\*\* — verbatim, attributed, hedges intact, before any analysis"'
check "Advance refuses to average oracles"        'flat SKILL.md | grep -q "When oracles disagree, never average\*\*: the disagreement \*is\* the finding"'
check "Advance processes breakers first"          'flat SKILL.md | grep -q "\*\*Record and process breakers first\*\* — a breaker winning is a bigger result than any on-axis win"'
check "Advance classifies all five outcomes"      'flat SKILL.md | grep -q "one variant wins → converge" && flat SKILL.md | grep -q "\*\*composite\*\* → the axis has sub-structure" && flat SKILL.md | grep -q "none of these.\*\* → the question was wrong" && flat SKILL.md | grep -q "\*\*no discrimination\*\* → the probe failed" && flat SKILL.md | grep -q "\*\*not reached\*\* → normal, just where the \*\*cut line\*\*"'
check "Advance carries the interview question"    'flat SKILL.md | grep -q "Would you take this same probe back tomorrow unchanged, or does it need reframing?"'
check "Advance rewrites rather than promotes"     'flat SKILL.md | grep -q "Not promoted, rewritten: variants carry prototype constraints"'
check "converging nothing is a success"           'flat SKILL.md | grep -q "An Advance session that converges nothing is a successful session"'
check "Advance runs nine steps in order"          '[ "$(block SKILL.md "^## Advance" "$" | grep -c "^[0-9]\. \*\*")" -eq 9 ] && flatblock SKILL.md "^## Advance" "$" | grep -q "1. \*\*Transcribe, don.t interpret\*\*" && flatblock SKILL.md "^## Advance" "$" | grep -q "9. \*\*Graduate fog, archive, close\*\*"'
check "Advance step 7 carries all three links"    'flatblock SKILL.md "^## Advance" "$" | grep -q "7. \*\*Write the decision line\*\* with all three links — variant set, commit or PR, and the brief file holding the quote"'
check "an unquoted sounded line is demoted"       'flat SKILL.md | grep -q "a .sounded. line lacking either the quoted utterance or the capture link is demoted to .assumed. and re-ticketed" && flatblock SKILL.md "^## Advance" "$" | grep -q "A line you cannot give a quote and a capture link is not .sounded.: demote it to .assumed. and re-ticket the question"'
check "SKILL.md is within its sprawl cap"         '[ "$(wc -l < SKILL.md)" -le 200 ] && [ "$(wc -l < SKILL.md)" -ge 100 ]'

# --- Task 8: failure-mode detectors ---
check "PREP.md caps prepping when contact stalls"  'flat PREP.md | grep -q "\*\*Stop prepping\*\* past roughly two soundings. worth"'
check "PREP.md guards against probe inflation"     'flat PREP.md | grep -q "\*\*Provenance quality is never a reason to spend contact budget.\*\* Probe load-bearing things; ask the rest"'
check "BRIEF.md defines the carried count"         'flat BRIEF.md | grep -q "the \*\*carried count\*\* on each stretch item, incremented every time the item rides below the cut line" && flat BRIEF.md | grep -q "At three carries it is mispriced rather than unlucky"'
check "CHART.md records the carried field"         'flat CHART.md | grep -q "\*\*.carried:.\*\*, an integer starting at 0, incremented by Brief each time the ticket falls below the cut line"'
check "SKILL.md treats reversal as first-class"    'flat SKILL.md | grep -q "Write a \*\*superseding\*\* decision line and keep both"'
check "SKILL.md diagnoses whole-sounding politeness" 'flat SKILL.md | grep -q "if \*\*every probe\*\* in the sounding classifies this way"'

# --- Task 9: audit ---
check "the five-phase table appears only once"   '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "| \*\*Chart\*\* |")" -eq 1 ]'
check "no reference file restates the loop"      'grep -qi "N Prep sessions feed one Brief" SKILL.md && ! grep -qi "N Prep sessions feed one Brief" CHART.md PREP.md BRIEF.md'
check "the phrase sounding shape is defined once" 'grep -q "Sounding shape" CHART.md && [ "$(grep -l "sounding shape" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -le 2 ]'
check "no file carries an unresolved placeholder" '! grep -rniE "TBD|TODO|FIXME|XXX" SKILL.md CHART.md PREP.md BRIEF.md'

check "BRIEF.md handles unsettled attendance"    'flat BRIEF.md | grep -q "When attendance is not yet settled"'
check "BRIEF.md flags a provisional brief"      'flat BRIEF.md | grep -q "mark the brief provisional"'

# --- Task 10: tracker provisioning ---
check "tracker-github.md exists" '[ -f tracker-github.md ]'
check "tracker-local.md exists"  '[ -f tracker-local.md ]'
check "SKILL.md names the tracker doc path and operations section" 'flat SKILL.md | grep -q "docs/agents/issue-tracker.md. in the target repo, under its .## Cartography operations. section"'
check "SKILL.md provisions the section when absent, in any phase" 'flat SKILL.md | grep -q "If that section is missing — in any phase, not only Chart — provision it before doing anything else" && flat SKILL.md | grep -q "per \[.CHART.md.\](CHART.md)"'
check "CHART.md provisions before the charting session order" '[ "$(grep -n "^## Provisioning the tracker doc" CHART.md | cut -d: -f1)" -lt "$(grep -n "^## Charting session order" CHART.md | cut -d: -f1)" ]'
check "CHART.md covers the doc-exists-without-section case" 'flat CHART.md | grep -q "exists but has no .## Cartography operations. section" && flat CHART.md | grep -q "Reuse it; do not re-ask which tracker"'
check "CHART.md covers the no-tracker-doc-at-all case" 'flat CHART.md | grep -q "No tracker doc at all\*\* — ask the user which tracker this repo uses" && flat CHART.md | grep -q "proposing GitHub when .git remote -v. points at a GitHub remote"'
check "CHART.md asks rather than defaults, and says so"  'flat CHART.md | grep -q "\*\*Never default silently.\*\* The tracker choice is always the user.s, and is always recorded"'
check "tracker-github.md defines the frontier and eligible queries" 'flat tracker-github.md | grep -q "Frontier query" && flat tracker-github.md | grep -q "Eligible query"'
check "tracker-local.md defines the frontier and eligible queries"  'flat tracker-local.md | grep -q "Frontier query" && flat tracker-local.md | grep -q "Eligible query"'
check "SPEC.md deliverables list the two seed templates" 'flat SPEC.md | grep -q "tracker-github.md" && flat SPEC.md | grep -q "tracker-local.md" && flat SPEC.md | grep -qi "only one of the two ever loads"'

check "charting grills the destination out of the human" 'flatblock CHART.md "^## Charting session order" "$" | grep -q "grill it out of the human"'
check "charting treats repo material as a hypothesis"  'flatblock CHART.md "^## Charting session order" "$" | grep -q "starting hypothesis to put to them and have confirmed"'
check "charting grills the fog breadth-first"          'flatblock CHART.md "^## Charting session order" "$" | grep -q "grill again, breadth-first"'
check "charting stops when no fog surfaces"            'flatblock CHART.md "^## Charting session order" "$" | grep -q "no chart is needed"'

check "tracker-github.md defers semantics to the skill" 'flat tracker-github.md | grep -q "CHART.md" && flat tracker-github.md | grep -q "BRIEF.md"'
check "tracker-local.md defers semantics to the skill"  'flat tracker-local.md | grep -q "CHART.md" && flat tracker-local.md | grep -q "BRIEF.md"'
check "tracker-github.md keeps its backend mechanics"   'flat tracker-github.md | grep -q "cartographer:prepped" && flat tracker-github.md | grep -q "gh issue create --label cartographer:map"'
check "tracker-local.md keeps its backend mechanics"    'flat tracker-local.md | grep -q "Status:" && flat tracker-local.md | grep -q "scratch/<effort>/map.md"'
check "no tracker template restates the ticket kinds"   '[ -s tracker-github.md ] && [ -s tracker-local.md ] && ! grep -q "probe./.question./.research" tracker-github.md tracker-local.md'
check "no tracker template restates the link count"     '[ -s tracker-github.md ] && [ -s tracker-local.md ] && ! grep -q "all three links" tracker-github.md tracker-local.md'

echo "---"
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; fi
exit $([ "$fails" -eq 0 ] && echo 0 || echo 1)
