# /cartographer — specification

Status: **approved design, ready for implementation planning.**
Design record and rationale: [`DECISIONS.md`](DECISIONS.md). This spec is what gets
built; DECISIONS.md is why. Where they differ, this file wins.

---

## 1. Thesis

Nobody can predict their own preferences — not remote enterprise stakeholders, not
the developer. The person in the chat is a proxy for "who they'll be once they've
seen it working."

Therefore: **conversation produces guesses; only reaction to a working artifact
produces evidence.**

Build cost has collapsed. **Oracle contact has not.** Contact is the scarce
resource, so work is sized to *one contact*, not one agent session.

## 2. Relationship to `/wayfinder`

`/cartographer` is a **standalone fork** of Matt Pocock's `/wayfinder`, not an
extension and not a composition. It is installed as a sibling skill and shares no
files with it.

**Inherited unchanged:** the map/destination model, fog-of-war, *Not yet
specified*, *Out of scope*, ticket claiming, the frontier query, tracker-agnosticism
(a tracker doc supplies how *this* repo expresses maps, children, blocking and
queries; native tracker relations are used wherever they exist, body conventions
only where they don't).

**Added:** the oracle, the five-phase loop, provenance tags, probes and variant
sets, the brief, and the failure-mode detectors.

**Frontmatter:** `disable-model-invocation: true`, matching wayfinder. Every phase
is entered deliberately by the human.

## 3. Vocabulary

These words are load-bearing and must be used consistently in every file. The
metaphor is cartographic and coherent: **a marine chart is built from soundings.**

| Word | Meaning |
|---|---|
| **chart** | The map issue. Destination, fog, decisions, oracle, sounding shape. |
| **fog** | *Not yet specified* — questions not yet sharp enough to be tickets. |
| **oracle** | The human whose reaction counts as evidence. May be several people. |
| **probe** | A ticket of kind `probe` **plus** the variant set built for it. The unit costing a Prep session and minutes of reaction budget. |
| **variant set** | The 2–5 working alternatives themselves. Always throwaway. |
| **breaker** | A variant built specifically to violate a load-bearing assumption. A **gate**, not a competitor. |
| **sounding** | The act of measuring reality against the oracle — phase 3. Never the artifact. |
| **brief** | The prioritized agenda artifact carried into a sounding. |
| **decay** | How many guesses have stacked on a probe's subject since it was prepped. |
| **cut line** | Where the brief's budget runs out. Below it = stretch. |
| **advance** | Phase 4 — the only phase that moves work into main. |

## 4. The loop

**Chart, Prep, Brief and Advance are agent phases. Sound is a HUMAN phase** — the
human is in a room or on a call and the agent may not be present at all.
Everything the agent can do for a sounding must be handed over in advance, as an
artifact.

| # | Phase | Who | Output |
|---|---|---|---|
| 0 | **Chart** | agent | destination, fog, oracle, sounding shape — once |
| 1 | **Prep** | agent | one probe's variant set → `prepped` |
| 2 | **Brief** | agent | the prioritized agenda artifact |
| 3 | **Sound** | **human** | reactions, captured verbatim |
| 4 | **Advance** | agent | decisions, converged code, graduated fog |

Loop is `1 → 2 → 3 → 4 → 1`. **N Prep sessions feed one Brief.**

### Two absolute rules

- **Advance before Prep.** Never build new variant sets while unadvanced reactions
  sit on the chart. Unconditional — a rule with exceptions gets talked out of.
- **Brief is a real session with a real deliverable.**

### Between contacts: widen, never advance

Never build on an un-reacted-to decision. Build more variants, or variants for the
next question. The phase name carries the rule: *don't reach Advance without a
sounding.*

## 5. Provenance

Every decision line on the chart carries exactly one tag.

| tag | what happened | remedy |
|---|---|---|
| `assumed` | Agent picked it to make progress. No human considered it. | Make one variant violate it |
| `predicted` | A human stated it, without seeing anything working. | Put it in front of them as a probe |
| `sounded` | A human reacted to a working artifact. | Firm |

Phases 0, 1 **and 3** all produce predictions — including the oracle's own verbal
answers during a sounding, which are forecasts, not evidence. That claim is what
separates this skill from "talk to your stakeholder more."

**A confirmed prediction never becomes `sounded`.** Nobody reacted to it. It stays
`predicted` with a note that a nearby reaction is consistent. Letting confirmations
promote launders the chart back into guesswork within months.

**`sounded` requires a quoted human utterance.** No quote, no tag.

Four mechanisms keep provenance honest:

- **a. Prefer reversible guesses.** When Prep must assume, pick the assumption
  cheapest to overturn, not the one most likely right.
- **b. Violate load-bearing assumptions.** If every variant shares an assumption,
  the oracle cannot react to it. One variant must violate it.
- **c. Re-examine on touch** — bounded, see below.
- **d. Destination gate.** Not finished while a load-bearing prediction is
  unsounded; each must be sounded or accepted as a named risk. The one exhaustive
  sweep lives here, along with the proxy-oracle flag (§9).

### Re-examination scope

Bounded by two filters, both required:

1. **Subject tags** — every decision line carries one or two domain nouns. A
   reaction names its subjects; only decisions sharing one are touched.
2. **Load-bearing filter** — only predictions explicitly marked load-bearing are
   re-examined at Advance. Unmarked ones are accepted risk by definition.

Bound = *load-bearing predictions sharing a subject with this reaction* — typically
a handful.

## 6. Tickets

### Kinds

- **probe** — two or more working alternatives side by side reveal the answer.
  Costs a Prep session + minutes of contact budget.
- **question** — sharp, but no comparison would reveal anything. Just ask. Costs
  seconds. Resolves to `predicted`.
- **research** — AFK investigation.
- **task** — has an **owner**, agent or human. Human-owned tasks are handed over as
  a precise checklist.

probe-vs-question is a fork **at** the ticket level, not a rung between fog and
ticket: fog/ticket is about *sharpness*; probe/question is about *what resolves it*.

### Shape

`## Question` + `## Reaction needed`, the latter phrased as what a comparison
between variants would reveal, never as something you could just ask. Each probe
also records **which oracle role must react to it**, and its **assumptions** with
load-bearing ones marked.

### States and queries

States: `open` → `prepped` → `closed`.

- **frontier** = open, unclaimed, not prepped → what a Prep session may take.
- **eligible** = `prepped` **and** its required oracle will be present → Brief's input.

### Blocking edges

Uses the tracker's native dependency relation. Narrowing rule:

> Blocking edges express only that work must complete before a ticket is workable.
> They **never** express that one decision must precede another — that's fog, and
> encoding it as a blocking edge is a worse copy of the fog mechanism.

A blocker may be the human's own to do.

## 7. The chart

Wayfinder's map plus two sections:

- **Oracle** — who the authority actually is; whether the person in the session is
  them or a proxy (including "I am a proxy for what I'll want once I see it");
  contact cadence and realistic budget **in minutes**; and a **tiebreaker line**
  naming who decides when the room splits. If nobody holds that authority, "who
  decides this" becomes its own ticket.
- **Sounding shape** — chosen once at Chart time from oracle reachability: live app
  with a variant switcher | self-contained shareable file | published artifact.
  Changing it later is a scoping act.

`Decisions so far` lines carry a provenance tag, subject tags, and — for `sounded`
— **three** links: the variant set that produced the reaction (evidence), the
commit or PR that embodies it (embodiment), and the brief file whose `## Capture`
section holds the quoted utterance (provenance). The capture link is what makes
§11's first invariant satisfiable; without it the quote is required but
untraceable. Bidirectional linkage makes a later reversal tractable instead of
archaeological.

Fog patches in *Not yet specified* name the ticket(s) that would sharpen them,
written when that ticket is created. Fog isn't a ticket, so it cannot hold a native
relation — this is the one place a body convention is used.

## 8. Phase specifications

### 8.1 Prep

**Radical variation on the axis under test. Everything off-axis held constant.**

Two failure modes:
- **Wallpaper** — variants differ only in degree; nothing to react to.
- **Uninterpretable** — variants differ everywhere; you learn which won, never why.

The **Reaction needed** field names the axis, so the set is checkable before
building: a difference not on that axis is a bug in the variant set.

**Cap: at most 5 variants, at least 2 on-axis** → at most 3 breakers → a probe with
4+ load-bearing assumptions cannot be built. Escalation, first that applies:

1. **Two axes?** Split into two probes. (Commonest cause.)
2. **Can the assumptions just be asked?** Promote to `question` tickets and block
   the probe on them. Answers land as `predicted` — a real upgrade over agent
   invention, for seconds of budget.
3. **One assumption dominating?** Re-aim the probe at it. It was never a supporting
   assumption; it was the real question.
4. **None of the above?** It is **fog wearing a ticket's clothes.** Demote to *Not
   yet specified*. A question statable only as "assuming A, B, C, D, then which?"
   is a conditional, not a precise statement — the conditions are the real
   frontier. **Assumption count is a measurable proxy for sharpness.**

Assumptions are recorded on the ticket **before** building. Listing them afterwards
is reconstruction.

**Reaction prompt** ships with every variant set: 2–3 forced choices phrased so
approval isn't an available answer. Not "what do you think?" but "which would annoy
you first, and on which screen?" In domain language, not code.

**Prototype constraints, in full:** no tests, no error handling beyond
runnability, no persistence, no abstraction. A shared `<Header>` is fine; a shared
`<Layout>` defeats the point.

**Session order:** claim → restate Question and Reaction needed (if no comparison
would reveal it, reclassify as a `question` and **stop**) → list assumptions, mark
load-bearing → fix the axis → build in the chart's sounding shape → write the
reaction prompt → record `assumed` entries → label `prepped`, link the artifact.

**Probe sizing: ~5 minutes of reaction each, targeting 2–4 probes per sounding.**
If one probe consumes a whole sounding, throughput is one decision per contact and
oracle latency dominates absolutely.

### 8.2 Brief

Runs in **its own session, after the last Prep before contact** — never earlier,
because eligibility depends on who is in the room.

**Prioritization — three checkable numbers:**

1. **Unblocking power** = native blocking relations pointing at this ticket + fog
   patches naming it.
2. **Decay** = count of `assumed`/`predicted` decision lines dated after the probe
   was labelled `prepped` that **share a subject tag** with it. Subject-scoped, so
   unrelated work doesn't inflate it.
3. **Cost** = estimated reaction minutes.

**The artifact.** Canonical form is a **markdown one-pager committed to the repo**
at `briefs/YYYY-MM-DD-<oracle>.md`. It is the durable record, and Advance reads it
back to know what was carried into the room. A remote or async oracle gets a
**published rendering** of that same file with live variant links — a rendering,
never a second source of truth.

Per item: question in domain language, direct links to the variant set (deep
`?variant=` URLs or the file), the forced-choice reaction prompt, expected minutes.

**Cut line.** Probes carry estimated minutes (default 5, breakers bundled in since
gates run in seconds). Questions budget 1 minute each. Asks get their own section,
a flat 1 minute for the whole list, and are **never cut** — they are handed over,
not reacted to. The cut line falls at **80% of the chart's stated budget**; the
remainder is slack for the room running long. Below the line = **stretch**:
carried, not failed, and decay raises its priority next time.

**Order.**
- **Breakers first**, matching Advance's processing order. A breaker is a gate: if
  it can void an axis, it runs before the axis. Neutralize bias by **form**, not
  order — present it as a question about the assumption ("B has no undo. Does that
  matter here?"), never as one more thing to rank.
- **Questions ride after their probe** — agenda position: a question sharing a
  subject with a probe is asked immediately *after* that probe's reaction. Orphan
  questions batch at the tail. A verbal answer given first is a `predicted` the
  oracle will then defend when they see the variants, contaminating the only real
  evidence in the room.

**First-run preamble**, for the first few soundings with a given oracle: *you're
picking between working things; "looks good" isn't an answer I can use; tell me
which one annoys you and where.* It belongs in the artifact, not the agent's head.

**Degenerate cases.**
- No eligible probes but eligible questions or asks → **still produce a short
  brief.** Contact is too scarce to waive.
- Nothing eligible at all → **no agenda, and a chart finding**: either release the
  contact, or the frontier is aimed at an oracle who isn't the one showing up. The
  brief file is still written, carrying the finding and no agenda items, so the
  invariant in §11 holds and a released contact leaves a trace.
- **Brief never builds.** A gap it finds is Prep's job and needs Prep's session.

### 8.3 Sound

The human phase. **The agent runs no session while it happens** — that silence is
the structural guard against the agent later inventing reactions it didn't witness.

**One deliverable: a raw capture appended to the brief file** as a `## Capture`
section, so one file per contact holds both plan and result and the pairing cannot
drift. Written in the room or immediately after — never reconstructed days later.

**Capture records words, not conclusions.** Verbatim, attributed by name, hedges
intact. Where a machine transcript exists (Teams, Zoom, Meet), **that transcript is
the capture** — verbatim by construction, zero effort.

**Three rules for the room:**
1. **Don't advocate.** Explaining why a variant was built converts a reaction into
   agreement with you. Present, then stop talking.
2. **Don't accept approval.** "Looks good" is not an answer; the forced-choice
   prompt is in the brief for exactly this moment.
3. **Attribute everything.** Oracle disagreement is a finding Advance handles
   explicitly, and it is unrecoverable if the capture says "they said."

**The agenda is a plan, not a contract.** Order will be abandoned; normal. The one
thing Sound must note is **where the cut actually fell** — which items were never
reached. Advance treats "not reached" and "reached and settled nothing" as
completely different results, and only the room knows which happened.

**Async path.** The email or comment thread pasted verbatim into the same section,
no summarizing on the way in. Attribution in a pasted thread is often ambiguous —
display names, aliases, people forwarded in late. Advance **asks** rather than
guessing who the oracles were.

### 8.4 Advance

The only phase that **contributes to main**, via whatever the repo's process is.
Variant sets never target main at all. Explicitly **not** one ticket per session —
reactions arrive batched.

1. **Transcribe, don't interpret.** Verbatim, attributed, hedges intact, before any
   analysis. Auditable from the chart without reading code. **When oracles
   disagree, never average** — the disagreement *is* the finding, the sharpest form
   of the proxy problem. Use the chart's tiebreaker line. Resolve ambiguous async
   attribution here by asking.
2. **Record and process breakers first.** A breaker winning is a **bigger** result
   than any on-axis win: it voids the on-axis comparison entirely. Record the
   assumption killed, discard the on-axis result even if one variant clearly won,
   and re-prep on corrected footing.
3. **Classify each on-axis result.**
   - *One variant wins* → converge.
   - *Composite* ("header from B, sidebar from C") → the axis has sub-structure.
     Under controlled divergence this is a structural finding, not just how people
     talk. Converge the composite, or split into two probes if genuinely
     independent.
   - *"None of these"* → the **question** was wrong, not the variants. Don't
     converge; re-ticket and record what the framing missed.
   - *No discrimination* ("looks good") → the probe failed. Don't tag. Diagnose.
   - *Not reached* → normal; just where the cut line fell. Stays `prepped`, rides
     to the next Brief, priority rises via decay. No diagnosis, no blame.
4. **Interview on incomplete coverage — never auto-classify.** When a ticket got
   partial or zero attention, **ask**. Separating: never reached / reached but
   sprawled (probe too big, resize) / an hour spent settling nothing (wrong
   question — a finding about the chart). Best single question: **"Would you take
   this same probe back tomorrow unchanged, or does it need reframing?"**
5. **Capture asks born in the room.** Asks are rare and usually appear during the
   sounding rather than being planned into the brief, so the Brief won't have
   predicted them.
6. **Converge** — rewrite the winner **properly**. Not promoted, rewritten:
   variants carry prototype constraints that must not reach production. Repo
   standards and TDD re-engage here and only here.
   *An Advance session that converges nothing is a successful session* — its output
   was a correction to the chart.
7. **Write the decision line** with all three links (variant set = evidence,
   commit = embodiment, brief file = provenance), plus provenance and subject tags.
8. **Re-examine predictions on touch**, bounded per §5.
9. **Graduate fog, archive, close.** New tickets from what's now specifiable; clear
   those patches from *Not yet specified*. Variant sets become throwaway branches,
   linked from their tickets.

## 9. Failure modes and detectors

Each detector is checkable from the chart.

| # | Failure | Detector | Remedy |
|---|---|---|---|
| 1 | Agent answers its own question | a `sounded` line lacking **either** the quoted utterance **or** the capture link | demote to `assumed`, re-ticket |
| 2 | Politeness recorded as evidence | a sounding where **every** probe classifies "no discrimination" | re-run the first-run preamble, diverge harder; twice with the same oracle is a chart finding on the Oracle line, not a variant problem |
| 3 | Contact never arriving | count and age of `prepped` tickets | **stop prepping** past ~2 soundings' worth (~8 probes); shift the frontier to `research` and `task`; raise "oracle unreachable" as a chart-level risk |
| 4 | A reaction invalidating converged code | a new `sounded` line contradicting an existing `sounded` line that shares a subject tag | expected, not a failure — write a superseding decision line, keep both; the old commit link shows what to unwind. Reversals clustering in one subject mean that fog graduated too early |
| 5 | Agenda overflow becoming routine | a **carried count** per stretch item | at three carries it is mispriced, not unlucky: resize the probe or close it as accepted risk. If decay promoted it and it still wasn't reached, correct the Oracle line's budget downward |
| 6 | Gold-plated variants | prototype constraints violated; **"if you'd be sad to delete it, it's gold-plated"** | Advance rewrites rather than promotes precisely so variants stay cheap |
| 7 | Everything becoming a probe | probe count vs. budget; Prep's reclassify-and-stop step | **provenance quality is never a reason to spend contact budget.** Probe load-bearing things; ask the rest |

Failure 3 adds one rule to the destination gate: **load-bearing decisions sounded
only by a proxy oracle must be flagged there.**

## 10. Deliverables

```
cartographer/
  SKILL.md      the loop — what every session does, in order
  CHART.md      chart + ticket format; charting and writing to the chart
  PREP.md       building a variant set and picking its form
  BRIEF.md      assembling and prioritizing the agenda artifact
```

Placement follows the information hierarchy: `SKILL.md` carries the loop, the two
absolute rules, the provenance table and the phase-entry decision — what **every**
branch needs. `CHART.md`, `PREP.md` and `BRIEF.md` are disclosed reference reached
by pointers from the phase each serves, since only that branch reaches them.

Sound and Advance have **no** file of their own: Sound's instructions belong in the
brief artifact (the agent isn't there), and Advance's ordered steps sit in
`SKILL.md` because Advance is where every loop lands.

## 11. Invariants

Three chart-auditable invariants, checkable without reading code. They are the
skill's test suite.

1. **Every `sounded` decision line quotes a human utterance and links its capture.**
2. **Every sounding has a brief file, and every brief file has a `## Capture`
   section** once its sounding has happened.
3. **No Prep session ran while unadvanced reactions sat on the chart.**

## 12. Validation

Validate on **one small home project where the user is openly his own proxy**
before pointing the skill at work. Success is not "the skill ran" but: at least one
`assumed` entry got overturned by a breaker, and at least one decision line reached
`sounded` with a real quote.

## 13. Out of scope

- Slide-deck brief rendering. The markdown one-pager plus optional published
  rendering covers both reachability cases.
- Composing with `/wayfinder` at runtime. The fork is deliberate and total.
- Automating the sounding itself. Phase 3 is human by definition.
- Any tracker-specific implementation. Tracker specifics live in the tracker doc
  wayfinder already defines.
