# BRIEF.md — assembling the agenda

Read this to build the agenda you carry into a sounding, or to see the
template that carries Sound's rules — Sound has no file of its own, because
the agent is not present for it.

## When Brief runs

Its own session, after the last Prep before contact — never earlier, because
eligibility depends on who is in the room. **Brief never builds.** A gap it
finds is Prep's job and needs Prep's session.

## Prioritization

Rank `eligible` tickets (see `CHART.md`) by three checkable numbers:

1. **Unblocking power** — native blocking relations pointing at the ticket +
   fog patches naming it.
2. **Decay** — count of `assumed`/`predicted` decision lines dated after the
   probe was labelled `prepped` that share a subject tag with it.
   Subject-scoped, so unrelated work doesn't inflate it.
3. **Cost** — estimated reaction minutes.

## The artifact

Canonical form is a markdown one-pager committed to the repo at
`briefs/YYYY-MM-DD-<oracle>.md`. It is the durable record; Advance reads it
back to know what was carried into the room. A remote or async oracle gets a
published rendering of that same file with live variant links — a rendering,
never a second source of truth.

## Cut line

Probes carry estimated minutes (default 5, breakers bundled in since gates
run in seconds). Questions budget 1 minute each. Asks get their own section,
a flat 1 minute for the whole list, and are **never cut** — they are handed
over, not reacted to. The cut line falls at **80%** of the chart's stated
budget; the remainder is slack for the room running long. Below the line is
**stretch**: carried, not failed, and decay raises its priority next time.

## Order

- **Breakers first** (see `PREP.md`), matching Advance's processing order — a
  breaker is a gate, and a gate runs before the axis it can void. Neutralize
  bias by form, not order: present a breaker as a question about the
  assumption ("B has no undo. Does that matter here?"), never as one more
  thing to rank.
- **Questions ride after their probe** — a question sharing a subject tag
  with a probe is asked immediately **after that probe**'s reaction. A verbal
  answer given first is a `predicted` the oracle will then defend once they
  see the variants, contaminating the only real evidence in the room.
- Orphan questions batch at the tail.

## Degenerate cases

- No eligible probes but eligible questions or asks → still produce a short
  brief. Contact is too scarce to waive.
- **Nothing is eligible** at all → no agenda, and a chart finding: either
  release the contact, or the frontier is aimed at an oracle who isn't the
  one showing up. The brief file is still written, carrying the finding and
  no agenda items, so a released contact leaves a trace.

## When this goes wrong

**Agenda overflow becoming routine.** Detector: the **carried count** on
each stretch item, incremented every time the item rides below the cut line.
At three carries it is mispriced rather than unlucky: resize the probe, or
close it as accepted risk. No third option. And if decay did promote it and
it still wasn't reached, the budget is wrong — correct the chart's Oracle
line downward.

## The template

Fill this in, commit it at `briefs/YYYY-MM-DD-<oracle>.md`, and carry it into
the room. It carries the reaction prompt and breaker from `PREP.md`.

```markdown
# Brief — YYYY-MM-DD — <oracle>

<first-run preamble, first few soundings with this oracle:>
You're picking between working things; "looks good" isn't an answer I can
use. Tell me which one annoys you, and where.

**Rules for the room:**
1. Don't advocate — present, then stop talking.
2. Don't accept approval — use the reaction prompt below.
3. Attribute everything by name.

## Agenda

### [breaker/probe/question] — <title>

- Question (domain language): ...
- Variant set: <links>
- Reaction prompt: <2–3 forced choices>
- Expected minutes: N

<repeat, breakers first, each question after that probe, orphans at the tail>

---
<items below the cut line: stretch, carried not failed>

## Asks

- <handed over, 1 minute flat for the list, never cut>

## Where the cut actually fell

<filled in during/after Sound: which items were never reached>

## Capture

<The commonest case: notes typed in the room, no recording, no thread.
Capture verbatim, attributed by name, hedges intact — the `sounded` tag
requires a quoted utterance, so a capture that isn't verbatim costs the
skill its only evidence. A machine transcript, where one exists, is the
capture. An async thread is pasted verbatim without summarizing on the way
in.>
```
