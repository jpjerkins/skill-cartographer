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
  `01`. A `Kind:` line records the ticket kind
  (`probe`/`question`/`research`/`task`).
- **States**: `open` → `prepped` → `closed`, recorded in the child file's
  `Status:` line. A `prepped` ticket also carries a `carried: N` line,
  incremented by Brief each time the ticket falls below the cut line.
- **Blocking**: a `Blocked by: NN, NN` line near the top of the child file
  — the one place a body convention is used, since this tracker has no
  native dependency relation. A ticket is unblocked when every file it
  lists is `closed`.
- **Frontier query**: scan `.scratch/<effort>/issues/` for files that are
  `open`, unblocked (every file in `Blocked by:` is `closed`), and
  unclaimed (no `Claimed by:` line); first by number wins.
- **Eligible query**: scan the same directory for files that are `prepped`
  and whose `Oracle:` line names a role confirmed attending the next
  sounding.
- **Claim**: set `Claimed by: <name>` and save before any work — the
  session's first write.
- **Prepped**: set `Status: prepped`, add the variant set link, save.
- **Sounded decision lines**: appended to `map.md`'s Decisions so far,
  carrying all three links — variant set, commit or PR, brief file — as
  markdown links in the same line.
- **Resolve**: set `Status: closed` in the child file once its decision
  line is written to `map.md`.
