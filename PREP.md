# PREP.md — building a variant set

Read this at Prep time: one probe, one variant set, one Prep session.

## The rule

**Radical variation on the axis under test. Everything off-axis held
constant.**

This is checkable before you build anything: the ticket's `## Reaction
needed` field (see `CHART.md`) names the axis, so a difference between
variants that isn't on that axis is a bug in the variant set, catchable at
design time instead of discovered after the oracle reacts to noise.

## The two failure modes

- **Wallpaper** — variants differ only in degree. Nothing to react to.
- **Uninterpretable** — variants differ everywhere. You learn which one won,
  never why.

## The cap

At most 5 variants, at least 2 on-axis — therefore at most 3 breakers,
therefore a probe with 4+ load-bearing assumptions cannot be built. When the
cap binds, escalate, first rung that applies:

1. **Two axes?** Split into two probes. This is the commonest cause.
2. **Can the assumptions just be asked?** Promote them to `question` tickets
   and block the probe on them. Answers land as `predicted` — a real upgrade
   over agent invention, for seconds of budget.
3. **One assumption dominating?** Re-aim the probe at it directly. It was
   never a supporting assumption; it was the real question.
4. **None of the above?** It is **fog wearing a ticket's clothes.** Demote it
   to *Not yet specified*. A question statable only as "assuming A, B, C, D,
   then which?" is a conditional, not a precise statement — the conditions
   are the real frontier. **Assumption count is a measurable proxy for
   sharpness.**

## Assumptions

Recorded on the ticket **before** building, with load-bearing ones marked.
Listing them afterward is reconstruction, not a record.

A **breaker** is a variant built specifically to violate a load-bearing
assumption — a **gate**, not a competitor: it can void the whole on-axis
comparison rather than merely lose it.

## The reaction prompt

Ships with every variant set: 2–3 forced choices phrased so approval isn't
an available answer. Not "what do you think?" but "which would annoy you
first, and on which screen?" In domain language, not code.

## Prototype constraints

No tests, no error handling beyond runnability, no persistence, no
abstraction. A shared `<Header>` is fine; a shared `<Layout>` defeats the
point — it launders the axis you're supposed to be varying.

Gold-plating heuristic: **if you'd be sad to delete it, it's gold-plated.**
Variants are throwaway; treat anything you'd resist deleting as a signal
you've built past the probe.

## Session order

1. Claim the ticket.
2. Restate `## Question` and `## Reaction needed`. If no comparison would
   reveal the answer, reclassify as a `question` and **stop** — do not
   build.
3. List assumptions; mark load-bearing ones.
4. Fix the axis under test.
5. Build in the chart's sounding shape.
6. Write the reaction prompt.
7. Record `assumed` entries; label the ticket `prepped`, link the artifact.

## Sizing

Target **~5 minutes** of reaction per probe, aiming for 2–4 probes per
sounding. If one probe consumes a whole sounding, throughput drops to one
decision per contact and oracle latency dominates absolutely.

## When this goes wrong

**Contact never arriving.** Detector: the count and age of `prepped`
tickets. **Stop prepping** past roughly two soundings' worth — about 8
probes. More prep is not free: it multiplies decay and produces variant sets
that are stale on arrival. Shift the frontier to `research` and `task` work,
and raise "the oracle is unreachable" as a chart-level risk.

**Everything becoming a probe.** The session order above already catches
the obvious case — restate `## Reaction needed` and stop if no comparison
would reveal it. The subtler pull is probing what could simply be asked,
because a probe yields `sounded` and a question only yields `predicted`.
**Provenance quality is never a reason to spend contact budget.** Probe
load-bearing things; ask the rest.
