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
