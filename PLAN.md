# /cartographer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `/cartographer` skill — four agent-facing markdown files that run a five-phase loop sizing work to one stakeholder contact rather than one agent session.

**Architecture:** A standalone fork of `/wayfinder`, installed at `~/.claude/skills/cartographer/`. `SKILL.md` carries what every branch needs (the loop, the two absolute rules, the provenance model, phase routing, and Advance's steps); `CHART.md`, `PREP.md` and `BRIEF.md` are disclosed reference reached by pointers from the phase each serves. Verification is a shell conformance checker (`check.sh`) asserting structural invariants — frontmatter, pointer integrity, single-source-of-truth, sprawl caps — plus a final human-gated dry run on a real project.

**Tech Stack:** Markdown, YAML frontmatter, POSIX shell + grep. No build step, no runtime dependencies.

**Spec:** [`SPEC.md`](SPEC.md) in this directory. Design rationale in [`DECISIONS.md`](DECISIONS.md). The plan argues from the spec — read both.

## Global Constraints

- **Install path:** `~/.claude/skills/cartographer/`. This directory is already a git repo with `DECISIONS.md` and `SPEC.md` committed.
- **Frontmatter on `SKILL.md` only.** `name: cartographer`, and `disable-model-invocation: true` verbatim (SPEC §2).
- **Four deliverable files exactly:** `SKILL.md`, `CHART.md`, `PREP.md`, `BRIEF.md` (SPEC §10). Sound and Advance get no file of their own.
- **Vocabulary is load-bearing** (SPEC §3). Use `chart`, `fog`, `oracle`, `probe`, `variant set`, `breaker`, `sounding`, `brief`, `decay`, `cut line`, `advance` exactly as defined. "Sounding" is the act, never the artifact.
- **Single source of truth.** Each meaning lives in exactly one file. The provenance table, the two absolute rules, and the quote rule each appear once across the whole skill.
- **Sprawl caps:** `SKILL.md` ≤ 200 lines, each reference file ≤ 140 lines. Wayfinder's own SKILL.md is 128 lines — that is the calibration.
- **Prompt the positive.** State target behaviour rather than banning its opposite, except where a hard guardrail cannot be phrased positively (writing-for-agents).
- **No tests, no error handling, no persistence, no abstraction** applies to *variant sets the skill later produces* — not to this plan's own deliverables.

**Testing note:** `claude plugin eval` was checked and is early-access, not enabled on this account. Verification is `check.sh` plus the Task 9 dry run. Do not add eval suites.

---

### Task 1: Conformance checker

Builds the red/green harness every later task uses. Nothing else works without it.

**Files:**
- Create: `check.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: `./check.sh` — exits 0 when all assertions pass, 1 otherwise, printing one `PASS`/`FAIL` line per assertion. Later tasks add assertions to it by appending `check` calls.

- [ ] **Step 1: Write the checker with its first assertion, which must fail**

```bash
cat > check.sh <<'SH'
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

echo "---"
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; fi
exit $([ "$fails" -eq 0 ] && echo 0 || echo 1)
SH
chmod +x check.sh
```

- [ ] **Step 2: Run it to verify it fails**

Run: `./check.sh`
Expected: four `FAIL` lines (none of the four files exist yet), final line `4 check(s) failed`, exit code 1.

- [ ] **Step 3: Create the four files as empty stubs**

```bash
touch SKILL.md CHART.md PREP.md BRIEF.md
```

- [ ] **Step 4: Run it to verify it passes**

Run: `./check.sh`
Expected: four `PASS` lines, `all checks passed`, exit code 0.

- [ ] **Step 5: Commit**

```bash
git add check.sh SKILL.md CHART.md PREP.md BRIEF.md
git commit -m "feat(cartographer): add conformance checker and file stubs"
```

---

### Task 2: SKILL.md — frontmatter, opening, and the loop

The always-loaded core. Everything here is material every branch needs.

**Files:**
- Modify: `SKILL.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: `check()` from Task 1.
- Produces: `SKILL.md` sections `## The loop`, `## Two absolute rules`, `## Between contacts: widen, never advance`. Later tasks append to this file below these sections and must not restate them.

- [ ] **Step 1: Add the failing assertions**

Insert immediately before the `echo "---"` line in `check.sh`:

```bash
# --- Task 2: SKILL.md core ---
check "SKILL.md frontmatter names the skill"        'head -5 SKILL.md | grep -q "^name: cartographer$"'
check "SKILL.md disables model invocation"          'head -5 SKILL.md | grep -q "^disable-model-invocation: true$"'
check "SKILL.md has a description line"             'head -5 SKILL.md | grep -q "^description: "'
check "SKILL.md states the Advance-before-Prep rule" 'grep -q "Advance before Prep" SKILL.md'
check "SKILL.md states the widen-never-advance rule" 'grep -qi "widen, never advance" SKILL.md'
check "SKILL.md carries the five-phase table"        '[ "$(grep -c "^| [0-4] |" SKILL.md)" -eq 5 ]'
check "the two absolute rules live only in SKILL.md" '[ "$(grep -l "Advance before Prep" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -eq 1 ]'
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: the four Task 1 checks PASS; all seven new checks FAIL; exit 1.

- [ ] **Step 3: Write the SKILL.md opening**

```markdown
---
name: cartographer
description: Resolve a big, foggy effort by putting working alternatives in front of the stakeholder whose reaction counts, one contact at a time — for work where the requirements will not survive being guessed at.
disable-model-invocation: true
---

Nobody can predict their own preferences — not remote enterprise stakeholders, not you. The person in the chat is a proxy for who they'll be once they've seen it working. So **conversation produces guesses; only reaction to a working artifact produces evidence.**

Build cost has collapsed. **Contact with the oracle has not.** Contact is the scarce resource, so work here is sized to one contact, not one agent session.

Cartographer is a standalone fork of `/wayfinder` and inherits its machinery: the map — here called the **chart** — with a destination, fog-of-war, *Not yet specified*, *Out of scope*, ticket claiming, the frontier query, and tracker-agnosticism. Where this skill is silent on how the tracker expresses maps, child tickets, blocking or queries, consult the tracker doc, exactly as wayfinding does.

## The loop

**Chart, Prep, Brief and Advance are agent phases. Sound is a human phase** — the human is in a room or on a call and you may not be present at all. Everything you can do for a sounding must be handed over in advance, as an artifact.

| # | Phase | Who | Output |
|---|---|---|---|
| 0 | **Chart** | agent | destination, fog, oracle, sounding shape — once |
| 1 | **Prep** | agent | one probe's variant set → `prepped` |
| 2 | **Brief** | agent | the prioritized agenda artifact |
| 3 | **Sound** | **human** | reactions, captured verbatim |
| 4 | **Advance** | agent | decisions, converged code, graduated fog |

The loop runs `1 → 2 → 3 → 4 → 1`. **N Prep sessions feed one Brief.**

## Two absolute rules

- **Advance before Prep.** Never build new variant sets while unadvanced reactions sit on the chart. Unconditional — a rule with exceptions gets talked out of.
- **Brief is a real session with a real deliverable.**

## Between contacts: widen, never advance

Build on a reaction, never on an un-reacted-to decision. Between contacts, widen: build more variants, or variants for the next question. The phase name carries the rule — don't reach Advance without a sounding.
```

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 11 `PASS` lines, `all checks passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add SKILL.md check.sh
git commit -m "feat(cartographer): add SKILL.md frontmatter, thesis, and the loop"
```

---

### Task 3: SKILL.md — provenance and phase routing

Provenance is the skill's spine and belongs in the always-loaded file. Routing tells a session which phase it is in — the first decision of every run.

**Files:**
- Modify: `SKILL.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: `SKILL.md` sections from Task 2.
- Produces: `SKILL.md` sections `## Provenance` and `## Which phase am I in?`. The provenance table defined here is the single source of truth — Tasks 4–6 reference the tags but never restate the table. The routing section names `CHART.md`, `PREP.md` and `BRIEF.md`, which is where their pointers live.

- [ ] **Step 1: Add the failing assertions**

Insert before `echo "---"` in `check.sh`:

```bash
# --- Task 3: provenance and routing ---
check "SKILL.md defines all three provenance tags"   'grep -q "assumed" SKILL.md && grep -q "predicted" SKILL.md && grep -q "sounded" SKILL.md'
check "the quote rule appears exactly once"          '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "No quote, no tag")" -eq 1 ]'
check "the confirmed-prediction rule is stated"      'grep -q "never becomes .sounded" SKILL.md'
check "SKILL.md points at CHART.md"                  'grep -q "CHART.md" SKILL.md'
check "SKILL.md points at PREP.md"                   'grep -q "PREP.md" SKILL.md'
check "SKILL.md points at BRIEF.md"                  'grep -q "BRIEF.md" SKILL.md'
check "every pointed-at file exists"                 'for f in $(grep -o "[A-Z]*\.md" SKILL.md | sort -u); do [ -f "$f" ] || exit 1; done'
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: Tasks 1–2 checks PASS; the seven new checks FAIL (the "every pointed-at file exists" check may pass vacuously — that is expected and it becomes meaningful in Step 3); exit 1.

- [ ] **Step 3: Append the two sections to SKILL.md**

```markdown
## Provenance

Every decision line on the chart carries exactly one tag.

| tag | what happened | remedy |
|---|---|---|
| `assumed` | You picked it to make progress. No human has considered it. | Make one variant violate it |
| `predicted` | A human stated it, without seeing anything working. | Put it in front of them as a probe |
| `sounded` | A human reacted to a working artifact. | Firm |

Phases 0, 1 **and 3** all produce predictions — including the oracle's own verbal answers during a sounding, which are forecasts, not evidence. That claim is what separates this skill from talking to your stakeholder more.

**A confirmed prediction never becomes `sounded`.** Nobody reacted to it. It stays `predicted` with a note that a nearby reaction is consistent. Letting confirmations promote launders the chart back into guesswork within months.

**`sounded` requires a quoted human utterance. No quote, no tag.**

Four mechanisms keep provenance honest:

- **Prefer reversible guesses.** When Prep must assume, pick the assumption cheapest to overturn, not the one most likely right.
- **Violate load-bearing assumptions.** If every variant shares an assumption, the oracle cannot react to it. One variant must violate it.
- **Re-examine on touch.** At Advance, re-examine exactly the load-bearing predictions sharing a subject tag with this reaction — typically a handful. Unmarked predictions are accepted risk by definition.
- **Destination gate.** The effort is not finished while a load-bearing prediction is unsounded: each must be sounded or accepted as a named risk. The one exhaustive sweep lives here, and so does the proxy flag — a load-bearing decision sounded only by a proxy oracle is flagged at this gate.

## Which phase am I in?

Ask in this order and take the first that applies.

1. **No chart for this effort yet?** → **Chart.** Read [`CHART.md`](CHART.md).
2. **Unadvanced reactions sitting on the chart?** → **Advance.** Steps are below. This outranks everything; see the two absolute rules.
3. **Contact with the oracle imminent, and the last Prep is done?** → **Brief.** Read [`BRIEF.md`](BRIEF.md).
4. **Otherwise** → **Prep.** Read [`PREP.md`](PREP.md), take one ticket from the frontier.

Sound is never your session. When a sounding is happening, you are not running.
```

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 18 `PASS` lines, `all checks passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add SKILL.md check.sh
git commit -m "feat(cartographer): add provenance model and phase routing"
```

---

### Task 4: CHART.md

Disclosed reference for phase 0 and for anyone writing to the chart.

**Files:**
- Modify: `CHART.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: the provenance tags and vocabulary from `SKILL.md`.
- Produces: `CHART.md` sections `## The chart body`, `## Decision lines`, `## Tickets`, `## Blocking edges`, `## Charting session order`. `PREP.md` and `BRIEF.md` rely on the ticket states (`open`/`prepped`/`closed`) and the two queries (`frontier`, `eligible`) defined here.

- [ ] **Step 1: Add the failing assertions**

Insert before `echo "---"` in `check.sh`:

```bash
# --- Task 4: CHART.md ---
check "CHART.md defines the Oracle section"     'grep -q "Oracle" CHART.md'
check "CHART.md defines the sounding shape"     'grep -qi "sounding shape" CHART.md'
check "CHART.md names a tiebreaker"             'grep -qi "tiebreaker" CHART.md'
check "CHART.md defines all four ticket kinds"  'grep -q "probe" CHART.md && grep -q "question" CHART.md && grep -q "research" CHART.md && grep -q "task" CHART.md'
check "CHART.md defines the three states"       'grep -q "prepped" CHART.md && grep -q "closed" CHART.md'
check "CHART.md defines frontier and eligible"  'grep -q "frontier" CHART.md && grep -q "eligible" CHART.md'
check "CHART.md constrains blocking edges"      'grep -qi "blocking edges" CHART.md'
check "CHART.md is within its sprawl cap"       '[ "$(wc -l < CHART.md)" -le 140 ]'
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: earlier checks PASS; the seven content checks FAIL; the sprawl-cap check PASSES (empty file); exit 1.

- [ ] **Step 3: Write CHART.md**

Write the file from **SPEC §6 and §7**, condensed to ≤ 140 lines, in this order and preserving every bolded term:

1. **`## The chart body`** — wayfinder's map plus the two new sections. Reproduce SPEC §7's Oracle bullet in full: who the authority actually is; whether the person in the session is them or a proxy (including "I am a proxy for what I'll want once I see it"); contact cadence and realistic budget **in minutes**; and the tiebreaker line naming who decides when the room splits — with the escalation that if nobody holds that authority, "who decides this" becomes its own ticket. Then the Sounding shape bullet, with its three options (live app with a variant switcher | self-contained shareable file | published artifact) and the rule that changing it later is a scoping act.
2. **`## Decision lines`** — provenance tag, subject tags, and for `sounded` **both** links (variant set = evidence, commit or PR = embodiment). State the reason verbatim from SPEC §7: bidirectional linkage makes a later reversal tractable instead of archaeological. Point back to `SKILL.md` for the tag meanings rather than restating the table.
3. **`## Fog`** — fog patches name the ticket(s) that would sharpen them, written when that ticket is created, and this is the one place a body convention is used because fog is not a ticket and cannot hold a native relation.
4. **`## Tickets`** — the four kinds from SPEC §6 with their costs; the fork rule ("fog/ticket is about sharpness; probe/question is about what resolves it"); the ticket shape (`## Question` + `## Reaction needed`, the latter phrased as what a comparison between variants would reveal; which oracle role must react; assumptions with load-bearing ones marked); the three states; and the two queries.
5. **`## Blocking edges`** — the native-relation rule and SPEC §6's narrowing blockquote reproduced verbatim.
6. **`## Charting session order`** — name the destination, write the fog, fill the Oracle section, pick the sounding shape, create the tickets you can specify now, then wire blocking edges in a second pass (ids must exist before they can reference each other).

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 26 `PASS` lines, `all checks passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add CHART.md check.sh
git commit -m "feat(cartographer): add CHART.md — chart and ticket format"
```

---

### Task 5: PREP.md

Disclosed reference for phase 1. The most procedural of the three.

**Files:**
- Modify: `PREP.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: ticket states and the `## Reaction needed` field from `CHART.md`; the `assumed` tag from `SKILL.md`.
- Produces: `PREP.md` sections `## The rule`, `## The two failure modes`, `## The cap`, `## The reaction prompt`, `## Prototype constraints`, `## Session order`. `BRIEF.md` relies on the reaction prompt and the breaker concept defined here.

- [ ] **Step 1: Add the failing assertions**

Insert before `echo "---"` in `check.sh`:

```bash
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
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: earlier checks PASS; the eight content checks FAIL; the sprawl-cap check PASSES (empty file); exit 1.

- [ ] **Step 3: Write PREP.md**

Write the file from **SPEC §8.1**, condensed to ≤ 140 lines, in this order:

1. **`## The rule`** — "Radical variation on the axis under test. Everything off-axis held constant." Then the checkability point: the `## Reaction needed` field names the axis, so a difference not on that axis is a bug in the variant set, catchable before building.
2. **`## The two failure modes`** — wallpaper (variants differ only in degree; nothing to react to) and uninterpretable (variants differ everywhere; you learn which won, never why).
3. **`## The cap`** — at most 5 variants, at least 2 on-axis, therefore at most 3 breakers, therefore a probe with 4+ load-bearing assumptions cannot be built. Then SPEC §8.1's four-step escalation reproduced in full as a numbered list with bolded leads, ending on **assumption count is a measurable proxy for sharpness**. Keep the numbered-list formatting — the check counts four `1.`–`4.` bolded items.
4. **`## Assumptions`** — recorded on the ticket before building, load-bearing ones marked; listing them afterwards is reconstruction. Name the breaker: a variant built specifically to violate a load-bearing assumption, which is a gate rather than a competitor.
5. **`## The reaction prompt`** — ships with every variant set: 2–3 forced choices phrased so approval isn't an available answer. Include SPEC §8.1's contrast verbatim ("which would annoy you first, and on which screen?") and the domain-language-not-code rule.
6. **`## Prototype constraints`** — no tests, no error handling beyond runnability, no persistence, no abstraction; shared `<Header>` fine, shared `<Layout>` defeats the point. Add the gold-plating heuristic from SPEC §9: if you'd be sad to delete it, it's gold-plated.
7. **`## Session order`** — SPEC §8.1's seven steps, keeping the reclassify-and-stop branch explicit.
8. **`## Sizing`** — ~5 minutes of reaction per probe, targeting 2–4 probes per sounding, with the reason: if one probe consumes a whole sounding, throughput is one decision per contact and oracle latency dominates absolutely.

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 35 `PASS` lines, `all checks passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add PREP.md check.sh
git commit -m "feat(cartographer): add PREP.md — building a variant set"
```

---

### Task 6: BRIEF.md, including the brief template and Sound's rules

Disclosed reference for phase 2. It also carries Sound, because the agent is not present for Sound and its instructions must travel inside the artifact.

**Files:**
- Modify: `BRIEF.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: `eligible` from `CHART.md`; the reaction prompt and breaker from `PREP.md`.
- Produces: `BRIEF.md` sections `## Prioritization`, `## The artifact`, `## The template`, `## Cut line`, `## Order`, `## Degenerate cases`. The template's `## Capture` heading is what Task 7's Advance steps read back.

- [ ] **Step 1: Add the failing assertions**

Insert before `echo "---"` in `check.sh`:

```bash
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
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: earlier checks PASS; the ten content checks FAIL; the sprawl-cap check PASSES (empty file); exit 1.

- [ ] **Step 3: Write BRIEF.md**

Write the file from **SPEC §8.2 and §8.3**, condensed to ≤ 140 lines, in this order:

1. **`## When Brief runs`** — its own session, after the last Prep before contact, never earlier, because eligibility depends on who is in the room. State that Brief never builds: a gap it finds is Prep's job and needs Prep's session.
2. **`## Prioritization`** — the three checkable numbers from SPEC §8.2: unblocking power (native blocking relations pointing at the ticket + fog patches naming it), decay (count of `assumed`/`predicted` decision lines dated after the probe was labelled `prepped` that share a subject tag with it — subject-scoped so unrelated work doesn't inflate it), and cost (estimated reaction minutes).
3. **`## The artifact`** — canonical form is a markdown one-pager committed at `briefs/YYYY-MM-DD-<oracle>.md`; it is the durable record and Advance reads it back. A remote or async oracle gets a published rendering of that same file with live variant links — a rendering, never a second source of truth.
4. **`## Cut line`** — probes carry estimated minutes (default 5, breakers bundled in since gates run in seconds); questions budget 1 minute each; asks get their own section, a flat 1 minute for the whole list, and are **never cut** because they are handed over rather than reacted to. The cut line falls at **80%** of the chart's stated budget, the remainder being slack for the room running long. Below the line = stretch: carried, not failed, and decay raises its priority next time.
5. **`## Order`** — breakers first, matching Advance's processing order, with the bias rule: neutralize by form, not order — present a breaker as a question about the assumption ("B has no undo. Does that matter here?"), never as one more thing to rank. Then questions ride after their probe, with SPEC §8.2's reason stated in full: a verbal answer given first is a `predicted` the oracle will then defend when they see the variants, contaminating the only real evidence in the room. Orphan questions batch at the tail.
6. **`## Degenerate cases`** — no eligible probes but eligible questions or asks → still produce a short brief, because contact is too scarce to waive. When **nothing is eligible** at all → no agenda and a chart finding (either release the contact, or the frontier is aimed at an oracle who isn't the one showing up), and the brief file is still written carrying the finding and no agenda items, so a released contact leaves a trace.
7. **`## The template`** — a fenced markdown block the agent fills in and commits. It must contain, in order: a title line with date and oracle; the **first-run preamble** addressed to the human running the sounding (*you're picking between working things; "looks good" isn't an answer I can use; tell me which one annoys you and where*); the **three rules for the room** from SPEC §8.3 (don't advocate — present, then stop talking; don't accept approval; attribute everything by name); a per-item block with question in domain language, links to the variant set, the forced-choice reaction prompt, and expected minutes; the cut line marked as a horizontal rule with stretch items below it; an asks section; a line for **where the cut actually fell**; and a trailing empty `## Capture` section with the instruction that a machine transcript, where one exists, *is* the capture, and that an async thread is pasted verbatim without summarizing on the way in.

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 46 `PASS` lines, `all checks passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add BRIEF.md check.sh
git commit -m "feat(cartographer): add BRIEF.md — agenda assembly and the brief template"
```

---

### Task 7: SKILL.md — Advance

Advance is where every loop lands, so its steps sit in the always-loaded file. Written last because it consumes vocabulary all three reference files define.

**Files:**
- Modify: `SKILL.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: `## Capture` from `BRIEF.md`'s template; decision-line format from `CHART.md`; breakers from `PREP.md`.
- Produces: `SKILL.md` section `## Advance` — the terminal section of the file.

- [ ] **Step 1: Add the failing assertions**

Insert before `echo "---"` in `check.sh`:

```bash
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
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: earlier checks PASS; the eight content checks FAIL; the sprawl-cap check PASSES; exit 1.

- [ ] **Step 3: Append the Advance section to SKILL.md**

Write from **SPEC §8.4** as a nine-item numbered list, ≤ 55 lines, opening with the framing that Advance is the only phase that contributes to main via whatever the repo's process is, that variant sets never target main at all, and that it is explicitly not one ticket per session because reactions arrive batched. The nine steps, keeping every bolded lead:

1. **Transcribe, don't interpret** — verbatim, attributed, hedges intact, before any analysis. **When oracles disagree, never average**: the disagreement *is* the finding, the sharpest form of the proxy problem; use the chart's tiebreaker line. Resolve ambiguous async attribution by asking, never by guessing.
2. **Record and process breakers first** — a breaker winning is a bigger result than any on-axis win because it voids the on-axis comparison entirely. Record the assumption killed, discard the on-axis result even if one variant clearly won, re-prep on corrected footing.
3. **Classify each on-axis result** — the five outcomes from SPEC §8.4 step 3, each with its handling: one variant wins → converge; composite → the axis has sub-structure, a structural finding under controlled divergence, so converge the composite or split into two probes; "none of these" → the question was wrong, so re-ticket and record what the framing missed; no discrimination → the probe failed, don't tag, diagnose; not reached → normal, stays `prepped`, rides to the next Brief, priority rises via decay, no diagnosis and no blame.
4. **Interview on incomplete coverage** — ask rather than auto-classifying, separating never reached / reached but sprawled / an hour spent settling nothing. Include the single best question verbatim: **"Would you take this same probe back tomorrow unchanged, or does it need reframing?"**
5. **Capture asks born in the room** — rare, and usually appearing during the sounding rather than planned into the brief.
6. **Converge** — rewrite the winner properly. Not promoted, rewritten: variants carry prototype constraints that must not reach production. Repo standards and TDD re-engage here and only here. An Advance session that converges nothing is a successful session — its output was a correction to the chart.
7. **Write the decision line** with both links, provenance and subject tags.
8. **Re-examine predictions on touch**, bounded to load-bearing predictions sharing a subject.
9. **Graduate fog, archive, close** — new tickets from what's now specifiable, clear those patches from *Not yet specified*, variant sets become throwaway branches linked from their tickets.

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 55 `PASS` lines, `all checks passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add SKILL.md check.sh
git commit -m "feat(cartographer): add the Advance phase"
```

---

### Task 8: Failure-mode detectors

SPEC §9's seven detectors, each placed in the phase that would actually notice it. They are co-located with their phase rather than gathered into a list, so the agent meets each detector while doing the work that trips it.

**Files:**
- Modify: `PREP.md`, `BRIEF.md`, `SKILL.md`, `CHART.md`
- Modify: `check.sh`

**Interfaces:**
- Consumes: all four files as written by Tasks 2–7.
- Produces: a `carried:` field on stretch tickets (defined in `CHART.md`, incremented by `BRIEF.md`, acted on at three) and a `## When this goes wrong` subsection in each of `PREP.md` and `BRIEF.md`.

- [ ] **Step 1: Add the failing assertions**

Insert before `echo "---"` in `check.sh`:

```bash
# --- Task 8: failure-mode detectors ---
check "PREP.md caps prepping when contact stalls"  'grep -qi "stop prepping" PREP.md'
check "PREP.md guards against probe inflation"     'grep -qi "never a reason to spend contact budget" PREP.md'
check "BRIEF.md defines the carried count"         'grep -q "carried" BRIEF.md'
check "CHART.md records the carried field"         'grep -q "carried:" CHART.md'
check "SKILL.md treats reversal as first-class"    'grep -qi "superseding" SKILL.md'
check "SKILL.md diagnoses whole-sounding politeness" 'grep -qi "every probe" SKILL.md'
```

- [ ] **Step 2: Run to verify the new assertions fail**

Run: `./check.sh`
Expected: the 55 earlier checks PASS; all six new checks FAIL; exit 1.

- [ ] **Step 3: Place each detector**

**In `PREP.md`, a `## When this goes wrong` subsection** carrying two detectors:

- *Contact never arriving* (SPEC §9.3). Detector: the count and age of `prepped` tickets. **Stop prepping past roughly two soundings' worth — about 8 probes.** More prep is not free: it multiplies decay and produces variant sets that are stale on arrival. Shift the frontier to `research` and `task` work, and raise "the oracle is unreachable" as a chart-level risk.
- *Everything becoming a probe* (SPEC §9.7). The session order already catches the obvious case. Name the subtler pull: probing what could simply be asked, because a probe yields `sounded` and a question only yields `predicted`. State the rule verbatim — **provenance quality is never a reason to spend contact budget.** Probe load-bearing things; ask the rest.

**In `BRIEF.md`, a `## When this goes wrong` subsection** carrying one detector:

- *Agenda overflow becoming routine* (SPEC §9.5). Detector: the **carried count** on each stretch item, incremented every time the item rides below the cut line. At three carries it is mispriced rather than unlucky: resize the probe, or close it as accepted risk. No third option. And if decay did promote it and it still wasn't reached, the budget is wrong — correct the chart's Oracle line downward.

**In `CHART.md`**, add `carried:` to the ticket fields: an integer on `prepped` tickets, starting at 0, incremented by Brief whenever the ticket falls below the cut line.

**In `SKILL.md`'s Advance section**, extend two existing steps rather than adding new ones:

- Step 3's *no discrimination* outcome gains the whole-sounding case (SPEC §9.2): when **every probe** in a sounding classifies as no discrimination, it is not a variant problem. Re-run the first-run preamble and diverge harder; if it recurs with the same oracle twice, that is a chart finding for the Oracle line — this oracle won't discriminate in this setting.
- Step 7 gains reversal (SPEC §9.4): a new `sounded` line contradicting an existing one that shares a subject tag is expected, not a failure — it is only a failure if silent. Write a **superseding** decision line and keep both; the old line's commit link shows what to unwind. Reversals clustering in one subject mean that subject's fog graduated too early.

Detector 1 (agent answers its own question) is already covered by the quote rule in `SKILL.md`, and detector 6 (gold-plated variants) by the prototype constraints in `PREP.md`. Add nothing for them.

- [ ] **Step 4: Run to verify all assertions pass**

Run: `./check.sh`
Expected: 61 `PASS` lines, `all checks passed`, exit 0. If `SKILL.md` now exceeds 200 lines, cut prose from the Advance framing rather than dropping a detector.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(cartographer): place the seven failure-mode detectors"
```

---

### Task 9: Audit, then a live dry run

The checker proves structure. This task proves the skill actually reads well and works. Its second half is human-gated and cannot be completed by an agent alone.

**Files:**
- Modify: any of the four files, as the audit finds problems
- Modify: `check.sh`

**Interfaces:**
- Consumes: all four completed files.
- Produces: a skill that passes `./check.sh` and has survived one real sounding.

- [ ] **Step 1: Add the duplication and sprawl assertions**

Insert before `echo "---"` in `check.sh`:

```bash
# --- Task 9: audit ---
check "the five-phase table appears only once"   '[ "$(cat SKILL.md CHART.md PREP.md BRIEF.md | grep -c "| \*\*Chart\*\* |")" -le 1 ]'
check "no reference file restates the loop"      '! grep -qi "N Prep sessions feed one Brief" CHART.md PREP.md BRIEF.md'
check "the phrase sounding shape is defined once" '[ "$(grep -l "sounding shape" SKILL.md CHART.md PREP.md BRIEF.md | wc -l)" -le 2 ]'
check "no file carries an unresolved placeholder" '! grep -rniE "TBD|TODO|FIXME|XXX" SKILL.md CHART.md PREP.md BRIEF.md'
```

- [ ] **Step 2: Run the checker and fix whatever fails**

Run: `./check.sh`
Expected: 65 checks total; any failure here is real duplication or a leftover placeholder. Fix by deleting the restatement in the reference file and leaving the definition in its owning file — never by loosening the assertion.

- [ ] **Step 3: Read all four files end to end, in the order an agent would**

Read `SKILL.md`, then each reference file as its pointer fires. Check three things the shell cannot:

- **No-ops** — does each sentence change behaviour versus the model's default? Delete whole sentences that don't.
- **Negation** — is any rule phrased as a ban that would read better as a positive target? Rewrite it, keeping hard guardrails as-is.
- **Vocabulary drift** — is "sounding" ever used for the artifact rather than the act? Is "probe" ever used for the variant set alone? Fix both.

- [ ] **Step 4: Commit the audit**

```bash
git add -A
git commit -m "chore(cartographer): audit for duplication, no-ops, and vocabulary drift"
```

- [ ] **Step 5: Run the skill for real, on one small home project**

Per SPEC §12, run it where the human is openly his own proxy — not on work. Complete one full `Prep → Brief → Sound → Advance` cycle. **Stop and hand back to the human for the Sound phase; the agent does not run during a sounding.**

Success is not "the skill ran". Both of these must be true:

- At least one `assumed` entry was overturned by a breaker.
- At least one decision line reached `sounded` with a real quote.

Verify the three invariants from SPEC §11 by reading the chart: every `sounded` line quotes an utterance and links its capture; the sounding has a brief file with a `## Capture` section; no Prep session ran while unadvanced reactions sat on the chart.

- [ ] **Step 6: Record what the dry run taught, then commit**

Append a `## Dry run` section to `DECISIONS.md` recording which invariants held, which of the seven failure modes from SPEC §9 actually appeared, and any wording that misfired in practice.

```bash
git add -A
git commit -m "docs(cartographer): record dry-run findings"
```

---

## Notes for the executor

- **The checker is a floor, not a ceiling.** Every assertion in `check.sh` can be satisfied by bad prose. Task 9 Step 3 is where quality is actually decided; don't skip it because the shell is green.
- **Never loosen an assertion to make it pass.** If a check fails, the file is wrong.
- **Line caps are real.** Wayfinder does the whole job in 128 lines. If a file is pushing its cap, the material either belongs in a different file or belongs nowhere.
