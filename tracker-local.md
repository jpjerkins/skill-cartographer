# Cartography operations — Local Markdown

Used by `/cartographer`. Append this section, heading included, to
`docs/agents/issue-tracker.md` if the doc already exists; use it as the
whole file when none exists yet. The **chart** is a file with one **child**
file per ticket.

## Cartography operations

- **Chart**: `.scratch/<effort>/map.md` — the destination / *Not yet
  specified* / *Out of scope* / Decisions so far / Oracle / Sounding shape
  body.
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from
  `01`. A `Kind:` line records the ticket kind — `CHART.md` defines the
  kinds and what each means.
- **States**: recorded in the child file's `Status:` line; `carried:` is an
  integer line beside it. `CHART.md` and `BRIEF.md` define the states and
  when `carried:` moves.
- **Blocking**: a `Blocked by: NN, NN` line near the top of the child file
  — the one place a body convention is used, since this tracker has no
  native dependency relation. A ticket is unblocked when every file it
  lists is `closed`.
- **Frontier query**: scan `.scratch/<effort>/issues/` for files that are
  `open`, unblocked (every file in `Blocked by:` is `closed`), and
  unclaimed (no `Claimed by:` line); first by number wins.
- **Eligible query**: scan the same directory for `prepped` files, then
  filter by their `Oracle:` line — see `BRIEF.md` for what makes a ticket
  eligible.
- **Claim**: set `Claimed by: <name>` and save before any work — the
  session's first write.
- **Prepped**: set `Status: prepped`, add the variant set link, save.
- **Sounded decision lines**: appended to `map.md`'s Decisions so far, with
  each required link as a markdown link in the same line. `CHART.md` states
  which links a `sounded` line carries.
- **Resolve**: set `Status: closed` in the child file once its decision
  line is written to `map.md`.
