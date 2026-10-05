# Cartographer

A [Claude Code](https://claude.com/claude-code) skill for big, foggy efforts
where the requirements will not survive being guessed at.

Cartographer is a standalone fork of Matt Pocock's `/wayfinder`. It keeps
wayfinder's map (here called the **chart**): a destination, fog-of-war, *Not yet
specified*, *Out of scope*, ticket claiming, and tracker-agnosticism. It adds
the oracle, a five-phase loop, provenance tags and a brief.

## The idea

Nobody can predict their own preferences. So **conversation produces guesses;
only reaction to a working artifact produces evidence.**

Two things make this harder than it sounds:

- **The oracle is usually not the developer.** The person whose reaction counts
  is a remote stakeholder with limited time. Even when the oracle *is* you, the
  you in the chat is only a proxy for who you'll be once you've seen it
  working.
- **The fog covers more than the solution.** It also covers the *problem* and
  the *desired end-state*. A reaction to a working artifact can reshape any of
  the three.

So Cartographer iterates on all three: put working alternatives in front of the
oracle, record their reactions, sharpen the chart, and repeat until the result
is **good enough**.

Build cost has collapsed, but oracle contact has not. Contact is the scarce
resource, so work is sized to **one contact**, not one agent session.

## The loop

| # | Phase | Who | Output |
|---|---|---|---|
| 0 | **Chart** | agent | destination, fog, oracle, sounding shape (once) |
| 1 | **Prep** | agent | one probe's variant set → `prepped` |
| 2 | **Brief** | agent | the prioritized agenda artifact |
| 3 | **Sound** | **human** | reactions, captured verbatim |
| 4 | **Advance** | agent | decisions, converged code, graduated fog |

The loop runs `1 → 2 → 3 → 4 → 1`. Several Prep sessions feed one Brief.

Two absolute rules:

- **Advance before Prep.** Never build new variant sets while unadvanced
  reactions sit on the chart.
- **Brief is a real session with a real deliverable.**

Every decision on the chart carries a provenance tag:

| tag | meaning |
|---|---|
| `assumed` | The agent picked it to make progress. No human has considered it. |
| `predicted` | A human stated it without seeing anything working. |
| `sounded` | A human reacted to a working artifact. Requires a quoted utterance. |

The effort is not finished while a load-bearing `predicted` or `assumed`
decision remains unsounded, unless it is accepted as a named risk.

## Install and use

The skill lives at `~/.claude/skills/cartographer/`. Invoke it with
`/cartographer`. It is manual-only (`disable-model-invocation: true`), so every
phase is entered deliberately.

The target repo needs `docs/agents/issue-tracker.md` with a
`## Cartography operations` section. If the section is missing, the skill
provisions it from one of the templates here:

- [`tracker-github.md`](tracker-github.md): the chart is a GitHub issue and
  tickets are sub-issues.
- [`tracker-local.md`](tracker-local.md): the chart is `.scratch/<effort>/map.md`
  and tickets are files beside it.

## Files

| File | Purpose |
|---|---|
| [`SKILL.md`](SKILL.md) | Entry point: the loop, rules, provenance, phase routing, Advance |
| [`CHART.md`](CHART.md) | Chart and ticket format; the Chart phase |
| [`PREP.md`](PREP.md) | Building a probe's variant set |
| [`BRIEF.md`](BRIEF.md) | The agenda artifact and the capture format |
| `tracker-*.md` | Tracker templates (see above) |
| [`SPEC.md`](SPEC.md) | The specification: what is built |
| [`DECISIONS.md`](DECISIONS.md) | Design record: why it is built that way |
| [`PLAN.md`](PLAN.md) | The implementation plan |
| `check.sh` | Structural conformance checker |

The agent reads `SKILL.md` and the files it points to. The rest are design
records for humans.

## Verify

```sh
./check.sh
```

Each assertion prints `PASS` or `FAIL`. Any failure exits 1.
