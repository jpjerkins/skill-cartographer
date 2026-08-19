# /cartographer — design decisions so far

Brainstorm in progress (architectural path). All design sections closed (1–7; Section 4 amended and closed).
Next step: write the spec.
Fork of Matt Pocock's `/wayfinder`, standalone sibling skill.

Renamed from `/trailblazer` → `/cartographer`: marine charts are *built from
soundings*, so Chart / Prep / Sound is one coherent domain rather than a mixed
metaphor. The chart accretes from measurements of the actual seabed.

## Thesis

Nobody can predict their own preferences — not remote enterprise stakeholders,
not the developer. The person in the chat is a proxy for "who they'll be once
they've seen it working." So conversation produces guesses; only reaction to a
working artifact produces evidence. Build cost has collapsed; **oracle contact
has not**, so contact is the scarce resource and work is sized to one contact,
not one agent session.

## Settled foundations

- **Fork wayfinder**, don't extend or compose. Keep: destination, fog-of-war,
  not-yet-specified, out-of-scope, claiming.
- **Loop unit: diverge cheap → converge real.** N throwaway variants get the
  reaction; ONE real increment is built from what the reaction taught.
- **Between contacts: widen, never advance.** Never build on an un-reacted-to
  decision. Build more variants, or variants for the next question.
- **Sounding shape picked once at Chart time** from oracle reachability:
  live app w/ variant switcher | self-contained shareable file | published artifact.

## Phases

**Chart, Prep, Brief and Advance are agent phases. Sound is a HUMAN phase** — Phil is
in a room or on a call, and the agent may not be present at all. Everything the
agent can do for the sounding must be handed over in advance, as an artifact.

| # | Phase | Who | Output |
|---|---|---|---|
| 0 | **Chart** | agent | destination, fog, oracle, sounding shape — once |
| 1 | **Prep** | agent | one probe's variant set → `prepped` |
| 2 | **Brief** | agent | the prioritized agenda artifact, carried into the room |
| 3 | **Sound** | **human** | reactions |
| 4 | **Advance** | agent | decisions, converged code, graduated fog |

Loop is `1 → 2 → 3 → 4 → 1`. **N Prep sessions feed one Brief.**

## Two absolute rules

- **Advance before Prep.** Never build new variant sets while unadvanced reactions
  sit on the chart. Unconditional — a rule with exceptions gets talked out of.
- **Brief is a real session with a real deliverable.** (Replaces the earlier
  "every session exits with the agenda" rule, which did Brief's job badly as a
  trailing side effect of unrelated sessions.)

## Decision provenance — three tags, increasing trust

| tag | what happened | remedy |
|---|---|---|
| `assumed` | Agent picked it to make progress. No human has considered it. | Make one variant violate it |
| `predicted` | A human stated it, without seeing anything working. | Put it in front of them as a probe |
| `sounded` | A human reacted to a working artifact. | Firm |

Phases 0, 1 AND 3 all produce predictions — including the oracle's own verbal
answers during Sound, which are forecasts, not evidence. That claim is what
separates this skill from "talk to your stakeholder more."

**A confirmed prediction NEVER becomes `sounded`.** Nobody reacted to it; it stays
a prediction with a note that a nearby reaction is consistent. Letting
confirmations promote launders the chart back into guesswork over a few months.

Four mechanisms:
- **a. Prefer reversible guesses** — when Prep must assume, pick the assumption
  cheapest to overturn, not the one most likely right.
- **b. Violate load-bearing assumptions** — if all variants share an assumption
  the oracle cannot react to it. One variant must violate it. (Highest-confidence
  mechanism; converts invisible → testable at zero cost.)
- **c. Re-examine on touch** — bounded; see "Re-examination scope" below.
- **d. Destination gate** — not finished while a load-bearing prediction is
  unsounded; each must be sounded or accepted as a named risk. This is also
  where the one exhaustive sweep happens.

### Re-examination scope (bounded)

"Grep every prediction the reaction bears on" is unbounded on a large chart. Two
cheap bounds, both required:

1. **Subject tags** — every decision line carries one or two domain nouns
   (piggybacks on `/domain-modeling`; keeps the chart greppable). A reaction names
   its subjects; only predictions sharing one are touched.
2. **Load-bearing filter** — only predictions explicitly marked load-bearing are
   ever re-examined at Advance. Unmarked ones are accepted risk by definition.

Bound = *load-bearing predictions sharing a subject with this reaction* —
typically a handful. The unbounded sweep lives only at the destination gate.

## Ticket kinds

- **probe** — two or more working alternatives side by side reveal the answer.
  Costs a Prep session + minutes of contact budget.
- **question** — sharp, but no comparison would reveal anything. Just ask.
  Costs seconds of contact budget. Resolves `predicted`.
- **research** — AFK investigation ("identify best library", "infer file format").
- **task** — has an **owner**, agent or human ("allocate subnet", "purchase the
  selected UI library"). Human-owned tasks are handed over as a precise checklist.

Probe vs question is a fork AT the ticket level, not a rung between fog and
ticket: fog/ticket is about *sharpness*, probe/question is about *what resolves it*.

**Agenda has three currencies:** probes (minutes), questions (seconds), and
**asks** — things the oracle must DO, not answer. An ask only touches contact
budget if the oracle owns it; human-owned tasks Phil owns just block.

**Probe sizing: ~5 minutes of reaction each, targeting 2–4 probes per sounding.**
If one probe consumes a whole sounding, throughput is one decision per contact
and oracle latency dominates absolutely.

## Blocking edges — kept, narrowed

Restored (my YAGNI cut was wrong). Narrowing rule:

> Blocking edges express only that work must complete before a ticket is
> workable. They NEVER express that one decision must precede another — that's
> fog, and encoding it as a blocking edge is a worse copy of the fog mechanism.

Blocking is not limited to AFK work; a blocker may be Phil's own to do.

## The chart (label `cartographer:map`)

Wayfinder's map plus two new sections:
- **Oracle** — who the authority actually is; whether the person in the session
  is them or a proxy (including "I am a proxy for what I'll want once I see it");
  contact cadence and realistic budget; **and a tiebreaker line** naming who
  decides when the room splits. If nobody holds that authority, "who decides
  this" becomes its own ticket.
- **Sounding shape** — chosen once at Chart time. Changing it is a scoping act.

`Decisions so far` lines carry a provenance tag, subject tags, and — for
`sounded` — cite BOTH the variant set that produced the reaction AND the commit
or PR that embodies it. Bidirectional linkage makes a later reversal tractable
instead of archaeological.

## Ticket shape

`## Question` + `## Reaction needed` (phrased as what a comparison between
variants would reveal, not as something you could just ask). Each probe also
records **which oracle role must react to it**.

States: `open` → `prepped` → `closed`. Two label-driven queries:
- **frontier** = open, unclaimed, not prepped → what a Prep session may take
- **eligible** = prepped AND its required oracle will be present → Brief's input

## Section 3 — Prep (CLOSED)

**Radical variation on the axis under test. Everything off-axis held constant.**
(Phil's wording, within my constrained-variation frame.) Two failure modes:
- **Wallpaper** — variants differ only in degree; nothing to react to.
- **Uninterpretable** — variants differ everywhere; you learn which won, never why.

The **Reaction needed** field names the axis, so it's checkable before building:
a difference not on that axis is a bug in the variant set.

**Cap: at most 5 variants total, at least 2 on-axis** → at most 3
assumption-breakers → a probe with 4+ load-bearing assumptions cannot be built.
Escalation, first that applies:
1. **Two axes?** Split into two probes. (Commonest cause.)
2. **Can the assumptions just be asked?** Promote to `question` tickets, block the
   probe on them. Cheap — questions cost seconds; answers land as `predicted`,
   which is a real trust upgrade over agent invention.
3. **One assumption dominating?** Re-aim the probe at that assumption. It was
   never a supporting assumption — it was the real question.
4. **None of the above?** It's **fog wearing a ticket's clothes**. Demote to
   *Not yet specified*. A question statable only as "assuming A,B,C,D, then which?"
   is a conditional, not a precise statement — the conditions are the real frontier.
   **Assumption count is a measurable proxy for sharpness.**

Assumptions are recorded on the ticket **before** building, load-bearing ones
marked. Listing them afterwards is reconstruction.

**Reaction prompt** ships with every variant set: 2–3 forced choices phrased so
approval isn't an available answer. Not "what do you think?" but "which would
annoy you first, and on which screen?" In domain language, not code.

Prototype constraints in full: no tests, no error handling beyond runnability,
no persistence, no abstraction. Shared `<Header>` fine; shared `<Layout>` defeats
the point.

**Prep session order:** claim → restate Question/Reaction-needed (if no comparison
would reveal it, reclassify as a question and STOP) → list assumptions, mark
load-bearing → fix the axis → build in the chart's sounding shape → write the
reaction prompt → record `assumed` entries, label `prepped`, link the artifact.

## Section 4 — Advance (CLOSED)

**Advance is the only phase that CONTRIBUTES TO main** (via whatever the repo's
process is — PR, review, etc.). Variants never target main at all.
Explicitly NOT one-ticket-per-session: reactions arrive batched.

1. **Transcribe, don't interpret.** Verbatim, attributed, hedges intact, before
   any analysis. **A `sounded` tag requires a quoted human utterance. No quote,
   no tag.** Auditable from the chart without reading code.
   **When oracles disagree, never average.** The disagreement IS the finding —
   the sharpest form of the proxy problem. Use the chart's tiebreaker line.
2. **Record and process assumption-breakers first.** A breaker winning is a
   BIGGER result than any on-axis win: it voids the on-axis comparison entirely.
   Record the assumption killed; discard the on-axis result even if one variant
   clearly won; re-prep on corrected footing.
3. **Classify each on-axis result.**
   - One variant wins → converge.
   - **Composite** ("header from B, sidebar from C") → the axis has sub-structure.
     Under controlled divergence this is a structural finding, not just how people
     talk. Converge the composite, or split into two probes if genuinely independent.
   - **"None of these"** → the QUESTION was wrong, not the variants. Don't
     converge; re-ticket, record what the framing missed.
   - **No discrimination** ("looks good") → probe failed. Don't tag. Diagnose.
   - **Not reached** → normal. Just where the cut line fell. Stays `prepped`,
     rides to next Brief, priority rises via decay. No diagnosis, no blame.
4. **Interview on incomplete coverage — never auto-classify.** When a ticket got
   partial or zero attention, the agent ASKS. Separating: never reached / reached
   but sprawled (probe too big, resize) / an hour spent settling nothing (wrong
   question — a finding about the chart). Best single question:
   **"Would you take this same probe back tomorrow unchanged, or does it need
   reframing?"**
5. **Converge** — rewrite the winner PROPERLY. Not promoted, rewritten; variants
   carry prototype constraints that must not reach production. Repo standards and
   TDD re-engage here and only here.
   An Advance session that converges nothing is a SUCCESSFUL session — its output was
   a correction to the chart.
6. **Write the decision line** with both links (variant set = evidence, commit =
   embodiment) plus provenance and subject tags.
7. **Re-examine predictions on touch** — bounded per "Re-examination scope".
8. **Graduate fog, archive, close.** New tickets from what's now specifiable;
   clear those patches from *Not yet specified*. Variant sets → throwaway branches,
   linked from tickets.

## Section 5 — Brief (CLOSED)

Assembles from state that only exists immediately before contact.

A **probe** = a ticket of kind `probe` *plus* the variant set built for it. It is
the unit that costs a Prep session and minutes of reaction budget.

**Eligibility = `prepped` AND the oracle this probe needs will be present.**
That's why it can't be computed earlier.

### Prioritization — three checkable numbers

1. **Unblocking power.** Two terms, because the chart has two kinds of dependent:
   - *Blocked tickets* — real issues, so this uses the **tracker's native
     dependency relation** (wayfinder's own rule). Queryable and already rendered
     in the tracker UI; no grep, no convention.
   - *Fog patches* — *Not yet specified* entries aren't issues, so they can't hold
     a native relation. These keep a body convention: the patch names the ticket
     that would sharpen it, written when that ticket is created.

   Power = native blockers + fog patches naming it.
2. **Decay.** Count of `assumed` / `predicted` decision lines dated after the probe
   was labelled `prepped` that **share a subject tag** with it. Subject-scoped, so
   unrelated work doesn't inflate it. It measures how much of the chart now rests
   on ground this probe would firm up.
3. **Cost.** Estimated reaction minutes.

### The artifact

**Canonical form: a markdown one-pager committed to the repo**
(`briefs/YYYY-MM-DD-<oracle>.md`). It is the durable record, and Advance reads it
back to know what was actually carried into the room. A remote/async oracle gets a
**published rendering** of that same file with live variant links — a rendering,
never a second source of truth. Slide deck: cut.

Per item: question in domain language, direct links to the variant set (deep
`?variant=` URLs or the file), the forced-choice reaction prompt, expected minutes.

### Cut line

Oracle budget is stated in minutes on the chart's Oracle line.
- **Probes** carry estimated minutes (default 5). Breakers are bundled into their
  probe's estimate — they are gates and run in seconds.
- **Questions** budget 1 minute each.
- **Asks** get their own section, flat 1 minute for the whole list, and are
  **never cut** — they are handed over, not reacted to.

Cut line falls at **80% of budget**; the remainder is slack for the room running
long. Below the line = stretch: carried, not failed, and decay raises its priority
next time.

**Asks are rare, and are usually born during the sounding** rather than planned
into the Brief. Consequence: Advance's transcription step must capture asks that
appeared in the room, since the Brief won't have predicted them.

### Order

**Breakers first, everywhere** — presentation order matches Advance's processing
order. A breaker is a GATE, not a peer variant competing in the ranking; if it can
void an axis it runs before the axis. Neutralize bias by FORM, not order: present
it as a question about the assumption ("B has no undo. Does that matter here?"),
never as a fourth thing to rank.

**Questions ride after their probe** — "rides after" is agenda position: a question
sharing a subject with a probe is asked immediately *after* that probe's reaction.
Orphan questions batch at the tail. This is not stylistic. A verbal answer given
first is a `predicted` the oracle will then defend when they see the variants,
contaminating the only real evidence in the room.

**First-run preamble** for the first few soundings with a given oracle: *you're
picking between working things; "looks good" isn't an answer I can use; tell me
which one annoys you and where.* Cheapest available defence against the politeness
failure, and it belongs in the artifact rather than the agent's head.

### When Brief runs

Its own session, **after the last Prep before contact** — never earlier, because
eligibility depends on who is in the room.

- No eligible probes, but eligible questions or asks → **still produce a short
  brief**. Contact is too scarce to waive.
- Nothing eligible at all → **no agenda, and a chart finding**: either release the
  contact, or the frontier is aimed at an oracle who isn't the one showing up.
- **Brief never builds.** A gap it finds is Prep's job and needs Prep's session.

## Section 6 — Sound (CLOSED)

The human phase. **The agent runs no session while it happens** — that silence is
deliberate, and it is the structural guard against the agent later inventing
reactions it did not witness.

**One deliverable: a raw capture appended to the brief file.** The same
`briefs/YYYY-MM-DD-<oracle>.md` gains a `## Capture` section, so one file per
contact holds both what was planned and what came back and the pairing cannot
drift. Captured in the room or immediately after — never reconstructed days later.

**Capture records words, not conclusions.** The quote rule pushed one phase
forward: Advance cannot write `sounded` without a quoted human utterance, so a
capture without utterances yields nothing taggable. Verbatim, attributed by name,
hedges intact. **Where a machine transcript exists (Teams, Zoom, Meet), that
transcript IS the capture** — verbatim by construction, zero effort.

**Three rules for the room:**
1. **Don't advocate.** Explaining why a variant was built converts a reaction into
   agreement with you. Present, then stop talking.
2. **Don't accept approval.** "Looks good" is not an answer; the forced-choice
   prompt is in the brief for exactly this moment.
3. **Attribute everything.** Oracle disagreement is a finding Advance handles
   explicitly, and it is unrecoverable if the capture says "they said".

**The agenda is a plan, not a contract.** Order will be abandoned; normal. The one
thing Sound must note is **where the cut actually fell** — which items were never
reached. Advance treats "not reached" and "reached and settled nothing" as
completely different results, and only the room knows which happened.

**Async path.** When the oracle reacted to a published rendering, the capture is
the email/comment thread pasted verbatim. No summarizing on the way in.
**Attribution in a pasted thread is often ambiguous** — display names, aliases,
people forwarded in late. Do NOT guess who the oracles were: **Advance asks.**
This folds into Advance's existing interview step.

## Section 7 — Failure modes (CLOSED)

Each has a detector checkable from the chart, not a vibe.

1. **Agent answers its own question.** *Detector:* a `sounded` line with no quoted
   utterance and no capture link. *Remedy:* demote to `assumed`, re-ticket.
2. **Politeness recorded as evidence.** *Detector:* a sounding where every probe
   classifies as "no discrimination". *Remedy:* re-run the first-run preamble,
   diverge the next variants harder. Recurring twice with the same oracle is not a
   variant problem — the finding is that this oracle won't discriminate in this
   setting, and it belongs on the chart's Oracle line.
3. **Contact never arriving.** *Detector:* count and age of `prepped` tickets.
   *Remedy:* **stop prepping** past ~two soundings' worth (~8 probes). More prep is
   not free — it multiplies decay and produces variant sets stale on arrival. Shift
   the frontier to `research` and `task` work; raise "oracle unreachable" as a
   chart-level risk. A proxy oracle may react; attribution records who, and the
   **destination gate must flag load-bearing decisions sounded only by a proxy.**
4. **A reaction invalidating already-converged code.** Not a failure — expected,
   and why decision lines carry both links. A failure only if silent. *Remedy:*
   reversal is a first-class Advance outcome: write a superseding decision line,
   keep both, and the old commit link shows what to unwind. *Signal:* reversals
   clustering in one subject mean that subject's fog graduated too early.
5. **Agenda overflow becoming routine.** *Detector:* a carried count per stretch
   item. *Remedy:* at three carries it is mispriced, not unlucky — resize the probe
   or close it as accepted risk, no third option. If decay did promote it and it
   still wasn't reached, the budget is wrong: correct the Oracle line downward.
6. **Gold-plated variants.** *Detector:* the Prep prototype constraints, plus one
   heuristic — **if you'd be sad to delete it, it's gold-plated.** *Remedy:* Advance
   rewrites rather than promotes precisely so variants stay cheap; a Prep session
   hoping for promotion has already lost.
7. **Everything becoming a probe.** Prep's session order catches the obvious case.
   The subtler pull is the reverse: probing what could be asked, because a probe
   yields `sounded` and a question only `predicted`. *Rule:* **provenance quality is
   never a reason to spend contact budget.** Probe load-bearing things; ask the rest.

## Naming

Skill is `/cartographer`. "Sounding" = the act of measuring reality against the
oracle (phase 3), never the artifact. The artifact is the **variant set** —
plain noun on purpose. Phase 4 is **Advance** — see "Naming decision (taken)" below.

## Still to design

- **Testing the skill**: three chart-auditable invariants — every `sounded` has a
  quote; every Brief produced an artifact; no Prep ran while unadvanced reactions
  sat. Validate on one small home project (where Phil is openly his own proxy)
  before pointing it at work.

## Files (planned)

```
cartographer/
  SKILL.md      the loop — what every session does, in order
  CHART.md      chart + ticket format (charting / writing to the chart)
  PREP.md       building a variant set + picking its form
  BRIEF.md      assembling and prioritizing the agenda artifact
```

`disable-model-invocation: true`, matching wayfinder.

## Open questions

- Where should the written spec live? `~/.claude` is not a git repo.

---

## Naming decision (taken)

Phase 4 is **Advance**, not Land or Fix. Nautical ("advance" is real ship-handling
vocabulary), true to the phase's nature — it is the only phase that moves the
effort forward into main — and it reinforces the between-contacts rule:
**"widen, don't advance"** now reads literally as *don't reach phase 4 without a
sounding*. Rule and phase name support each other.
