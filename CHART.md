# CHART.md — chart and ticket format

Read this at Chart time, and whenever you write to the chart.

## The chart body

Wayfinder's map — destination, *Not yet specified*, *Out of scope*, `Decisions
so far` — plus two sections unique to this chart.

- **Oracle** — who the authority actually is. Whether the person in the
  session is them or a proxy (including "I am a proxy for what I'll want once
  I see it"). Contact cadence and a realistic budget **in minutes**. A
  **tiebreaker line** naming who decides when the room splits. If nobody holds
  that authority, "who decides this" becomes its own ticket.
- **Sounding shape** — chosen once, from oracle reachability: live app with a
  variant switcher | self-contained shareable file | published artifact.
  Changing it later is a scoping act, not a formatting tweak.

## Decision lines

Each `Decisions so far` line carries a provenance tag and one or two subject
tags. See `SKILL.md` for what the three tags mean and how to earn each one.

For `sounded` lines only, carry **three** links: the variant set that produced
the reaction (evidence), the commit or PR that embodies it (embodiment), and
the brief file whose `## Capture` section holds the quoted utterance
(provenance). Bidirectional linkage makes a later reversal tractable instead
of archaeological — the capture link is what makes the quote checkable years
later without archaeology.

## Fog

Fog patches in *Not yet specified* name the ticket(s) that would sharpen them,
written when that ticket is created. Fog isn't a ticket, so it cannot hold a
native relation — this is the one place a body convention is used.

## Tickets

### Kinds

- **probe** — two or more working alternatives side by side reveal the
  answer. Costs a Prep session plus minutes of oracle contact budget.
- **question** — sharp, but no comparison would reveal anything. Just ask.
  Costs seconds. Resolves to `predicted`.
- **research** — AFK investigation, no oracle contact.
- **task** — has an owner, agent or human. Human-owned tasks are handed over
  as a precise checklist.

probe-vs-question is a fork **at the ticket level**, not a rung between fog
and ticket: fog/ticket is about *sharpness*; probe/question is about *what
resolves it*.

### Ticket shape

`## Question` + `## Reaction needed`, the latter phrased as what a comparison
between variants would reveal — never as something you could just ask. Record
which oracle role must react to the ticket, and its assumptions, with any
load-bearing assumptions marked.

A `prepped` ticket also carries **`carried:`**, an integer starting at 0,
incremented by Brief each time the ticket falls below the cut line. See
`BRIEF.md` for what the count means at three.

### States

`open` → `prepped` → `closed`.

### Queries

- **frontier** = open, unclaimed, not prepped → what a Prep session may take.
- **eligible** = `prepped` and its required oracle will be present → Brief's
  input.

## Blocking edges

Use the tracker's native dependency relation.

> Blocking edges express only that work must complete before a ticket is
> workable. They **never** express that one decision must precede another —
> that's fog, and encoding it as a blocking edge is a worse copy of the fog
> mechanism.

A blocker may be the human's own to do.

## Provisioning the tracker doc

Every Chart session starts here — and any other phase that reaches for the
tracker doc and finds its `## Cartography operations` section missing does
the same before proceeding.

- **The doc exists but has no `## Cartography operations` section** — the
  sibling `/setup-matt-pocock-skills` already ran and recorded the tracker
  choice. Reuse it; do not re-ask which tracker. Append the section from
  this skill's matching seed template (`tracker-github.md` or
  `tracker-local.md`) to `docs/agents/issue-tracker.md`.
- **No tracker doc at all** — ask the user which tracker this repo uses,
  GitHub issues or local markdown, proposing GitHub when `git remote -v`
  points at a GitHub remote. Then write `docs/agents/issue-tracker.md` from
  the matching seed template, `## Cartography operations` section included.

**Never default silently.** The tracker choice is always the user's, and is
always recorded in the doc — a cold session must never fall back to local
markdown because nobody answered.

## Charting session order

1. **Name the destination — grill it out of the human.** Run `/grilling` and
   `/domain-modeling` to pin down what this chart is finding its way to. The
   destination comes from the person, not from the repo: treat a README, an
   existing spec, or a directory name as a **starting hypothesis to put to
   them and have confirmed**, never as the answer. Charting from inference
   produces a chart made entirely of guesses whose author nobody remembers.
2. **Map the fog — grill again, breadth-first.** Fan out across the whole
   space rather than deep on one thread, surfacing the open questions and the
   first work takeable now. If this surfaces no fog, the way is already clear
   and no chart is needed: stop and ask the human how they want to proceed.
3. Fill the Oracle section.
4. Pick the sounding shape.
5. Create the tickets you can specify now.
6. Wire blocking edges in a second pass — ids must exist before they can
   reference each other.
