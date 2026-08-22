# Cartography operations — GitHub

Used by `/cartographer`. Append this section, heading included, to
`docs/agents/issue-tracker.md` if the doc already exists; use it as the
whole file when none exists yet. The **chart** is a single issue with
**child** issues as tickets.

## Cartography operations

- **Chart**: a single issue labelled `cartographer:map`, holding the
  destination / *Not yet specified* / *Out of scope* / Decisions so far /
  Oracle / Sounding shape body. `gh issue create --label cartographer:map`.
- **Child ticket**: an issue linked to the chart as a GitHub sub-issue (`gh
  api` on the sub-issues endpoint). Where sub-issues aren't enabled, add the
  child to a task list in the chart body and put `Part of #<chart>` at the
  top of the child body. Kind labels: `cartographer:<kind>`
  (`probe`/`question`/`research`/`task`). Once claimed, the ticket is
  assigned to the driving dev.
- **States**: `open` → `prepped` → `closed`, tracked via the issue's own
  open/closed state plus a `cartographer:prepped` label for the middle
  state, which GitHub has no native equivalent for. A `prepped` ticket also
  carries a `carried: N` line in its body, incremented by Brief each time
  the ticket falls below the cut line.
- **Blocking**: GitHub's **native issue dependencies** — the canonical,
  UI-visible representation. Add an edge with `gh api --method POST
  repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F
  issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's
  numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq
  .id`, _not_ the `#number` or `node_id`). GitHub reports
  `issue_dependencies_summary.blocked_by` (open blockers only — the live
  gate). Where dependencies aren't available, fall back to a `Blocked by:
  #<n>, #<n>` line at the top of the child body. A ticket is unblocked when
  every blocker is closed.
- **Frontier query**: `gh issue list --state open` scoped to the chart's
  children, keeping only those with no open blocker
  (`issue_dependencies_summary.blocked_by == 0`, or no open issue in a
  `Blocked by` line), no assignee, and no `cartographer:prepped` label;
  first in chart order wins.
- **Eligible query**: the same child set filtered to
  `cartographer:prepped`, then to those whose body names an oracle role
  confirmed attending the next sounding.
- **Claim**: `gh issue edit <n> --add-assignee @me` — the session's first
  write.
- **Prepped**: `gh issue edit <n> --add-label cartographer:prepped`, with
  the variant set link added to the ticket body.
- **Sounded decision lines**: appended to the chart issue's Decisions so
  far (direct body edit, or `gh issue comment <chart>` cross-linked into
  the body) carrying all three links — variant set, commit or PR, brief
  file — as markdown links in the same line.
- **Resolve**: `gh issue close <n>` once its decision line is written.
