---
name: cartographer
description: Resolve a big, foggy effort by putting working alternatives in front of the stakeholder whose reaction counts, one contact at a time — for work where the requirements will not survive being guessed at.
disable-model-invocation: true
---

Nobody can predict their own preferences — not remote enterprise stakeholders,
not you. The person in the chat is a proxy for who they'll be once they've seen
it working. So **conversation produces guesses; only reaction to a working
artifact produces evidence.**

Build cost has collapsed. **Contact with the oracle has not.** Contact is the
scarce resource, so work here is sized to one contact, not one agent session.

Cartographer is a standalone fork of `/wayfinder` and inherits its machinery:
the map — here called the **chart** — with a destination, fog-of-war, *Not
yet specified*, *Out of scope*, ticket claiming, the frontier query, and
tracker-agnosticism. Where this skill is silent on how the tracker expresses
maps, child tickets, blocking or queries, consult the tracker doc, exactly as
`/wayfinder` does.

## The loop

**Chart, Prep, Brief and Advance are agent phases. Sound is a human phase** —
the human is in a room or on a call and you may not be present at all.
Everything you can do for a sounding must be handed over in advance, as an
artifact.

| # | Phase | Who | Output |
|---|---|---|---|
| 0 | **Chart** | agent | destination, fog, oracle, sounding shape — once |
| 1 | **Prep** | agent | one probe's variant set → `prepped` |
| 2 | **Brief** | agent | the prioritized agenda artifact |
| 3 | **Sound** | **human** | reactions, captured verbatim |
| 4 | **Advance** | agent | decisions, converged code, graduated fog |

The loop runs `1 → 2 → 3 → 4 → 1`. **N Prep sessions feed one Brief.**

## Two absolute rules

- **Advance before Prep.** Never build new variant sets while unadvanced
  reactions sit on the chart. Unconditional — a rule with exceptions gets
  talked out of.
- **Brief is a real session with a real deliverable.**

## Between contacts: widen, never advance

Build on a reaction, never on an un-reacted-to decision. Between contacts,
widen: build more variants, or variants for the next question. The phase name
carries the rule: a sounding is what unlocks Advance.

## Provenance

Every decision line on the chart carries exactly one tag.

| tag | what happened | remedy |
|---|---|---|
| `assumed` | You picked it to make progress. No human has considered it. | Make one variant violate it |
| `predicted` | A human stated it, without seeing anything working. | Put it in front of them as a probe |
| `sounded` | A human reacted to a working artifact. | Firm |

Phases 0, 1 **and 3** all produce predictions — including the oracle's own
verbal answers during a sounding, which are forecasts, not evidence. That claim
is what separates this skill from talking to your stakeholder more.

**A confirmed prediction never becomes `sounded`.** Nobody reacted to it. It
stays `predicted` with a note that a nearby reaction is consistent. Letting
confirmations promote launders the chart back into guesswork within months.

**`sounded` requires a quoted human utterance. No quote, no tag.** The
retrospective half of the same rule: **a `sounded` line lacking either the
quoted utterance or the capture link is demoted to `assumed` and re-ticketed**
— it is an agent answering its own question, and the demotion is not optional.

Four mechanisms keep provenance honest:

- **Prefer reversible guesses.** When Prep must assume, pick the assumption
  cheapest to overturn, not the one most likely right.
- **Violate load-bearing assumptions.** If every variant shares an assumption,
  the oracle cannot react to it. One variant must violate it.
- **Re-examine on touch.** At Advance, re-examine exactly the load-bearing
  predictions sharing a subject tag with this reaction — typically a handful.
  Unmarked predictions are accepted risk by definition.
- **Destination gate.** The effort is not finished while a load-bearing
  prediction is unsounded: each must be sounded or accepted as a named risk.
  The one exhaustive sweep lives here, and so does the proxy flag — a
  load-bearing decision sounded only by a proxy oracle is flagged at this gate.

## Which phase am I in?

Ask in this order and take the first that applies.

1. **No chart for this effort yet?** → **Chart.** Read [`CHART.md`](CHART.md).
2. **Unadvanced reactions sitting on the chart?** — a file under `briefs/`
   with a filled-in `## Capture` section whose tickets are still `prepped` →
   **Advance.** Steps are below. This outranks everything; see the two
   absolute rules.
3. **Contact with the oracle imminent, and the last Prep is done?** →
   **Brief.** Read [`BRIEF.md`](BRIEF.md).
4. **Otherwise** → **Prep.** Read [`PREP.md`](PREP.md), take one ticket from
   the frontier.

Sound is never your session — that silence is the structural guard against
later inventing reactions you did not witness.

## Advance

Advance is the only phase that contributes to main, via whatever the repo's
process is — variant sets never target main at all. It is explicitly not one
ticket per session: reactions arrive batched, so work through all of them.

1. **Transcribe, don't interpret** — verbatim, attributed, hedges intact,
   before any analysis, from the `## Capture` section of the brief file
   ([`BRIEF.md`](BRIEF.md)) where the sounding's reactions actually live.
   **When oracles disagree, never average**: the disagreement *is* the
   finding, the sharpest form of the proxy problem; use the chart's
   tiebreaker line ([`CHART.md`](CHART.md)). Resolve ambiguous async
   attribution by asking, never by guessing.
2. **Record and process breakers first** — a breaker winning is a bigger
   result than any on-axis win because it voids the on-axis comparison
   entirely. Record the assumption killed, discard the on-axis result even
   if one variant clearly won, re-prep on corrected footing.
3. **Classify each on-axis result** into one of five outcomes: one variant
   wins → converge; **composite** → the axis has sub-structure, a structural
   finding under controlled divergence, so converge the composite or split
   into two probes; **"none of these"** → the question was wrong, so
   re-ticket and record what the framing missed; **no discrimination** → the
   probe failed, don't tag, diagnose — and if **every probe** in the sounding
   classifies this way, it is not a variant problem: re-run the first-run
   preamble and diverge harder; if it recurs with the same oracle twice, that
   is a chart finding for the Oracle line, this oracle won't discriminate in
   this setting; **not reached** → normal, just where the **cut line**
   ([`BRIEF.md`](BRIEF.md)) fell, stays `prepped`, rides to the next Brief,
   priority rises via decay, no diagnosis and no blame.
4. **Interview on incomplete coverage** — ask rather than auto-classifying,
   separating never reached / reached but sprawled / an hour spent settling
   nothing. Ask verbatim: **"Would you take this same probe back tomorrow
   unchanged, or does it need reframing?"**
5. **Capture asks born in the room** — rare, and usually appearing during the
   sounding rather than planned into the brief.
6. **Converge** — rewrite the winner properly. Not promoted, rewritten:
   variants carry prototype constraints ([`PREP.md`](PREP.md)) that must not
   reach production. Repo standards and TDD re-engage here and only here. An
   Advance session that converges nothing is a successful session — its
   output was a correction to the chart.
7. **Write the decision line** with all three links — variant set, commit or
   PR, and the brief file holding the quote — and provenance and subject
   tags, per [`CHART.md`](CHART.md). A line you cannot give a quote and a
   capture link is not `sounded`: demote it to `assumed` and re-ticket the
   question. A new `sounded` line contradicting an existing one that shares a
   subject tag is expected, not a failure — it is only a failure if silent.
   Write a **superseding** decision line and keep both; the old line's commit
   link shows what to unwind. Reversals clustering in one subject mean that
   subject's fog graduated too early.
8. **Re-examine predictions on touch**, bounded to load-bearing predictions
   sharing a subject.
9. **Graduate fog, archive, close** — new tickets from what's now specifiable,
   clear those patches from *Not yet specified*, variant sets become throwaway
   branches linked from their tickets.
