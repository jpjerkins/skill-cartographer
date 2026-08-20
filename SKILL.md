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
