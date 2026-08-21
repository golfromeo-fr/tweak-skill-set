# tweak-skill-set

Curated agent-skill set for coding work, installed live at `~/.agents/skills/`
via **symlinks into this repo** — tweak a skill here and every agent session
picks it up. ZCode (and Claude Code / Codex, if used later) discover skills
from `~/.agents/skills/`.

## Contents (24 skills)

**Original (1)** — authored in this repo, no upstream:

- `mcp-live-tool-test` — agent-driven live MCP testing: the agent calls every
  exposed `mcp__<server>__<function>` tool itself (full sweep, PASS/FAIL/SKIP
  table), incl. the ZCode stale-session ("Session not found") failure mode and
  recovery. Written for the supreme-mcp-tools workspace but the procedure is
  generic.

**19 from [cursor/plugins](https://github.com/cursor/plugins) → `pstack/skills/`** (by poteto, MIT)
— installed from commit `51a96e0dd838`:

- Principles (11): `principle-prove-it-works`, `principle-subtract-before-you-add`,
  `principle-outcome-oriented-execution`, `principle-fix-root-causes`,
  `principle-make-operations-idempotent`, `principle-sequence-verifiable-units`,
  `principle-guard-the-context-window`, `principle-boundary-discipline`,
  `principle-laziness-protocol`, `principle-encode-lessons-in-structure`,
  `principle-model-the-domain`
- Workflow (8): `create-verification-skill`, `maintain-verification-skill`,
  `blast-radius`, `unslop`, `technical-writing`, `tdd`, `show-me-your-work`,
  `figure-it-out`

**4 from [mattpocock/skills](https://github.com/mattpocock/skills) → `skills/engineering/`** (Matt Pocock, MIT)
— installed from commit `0ab1b63a410a`:

- `diagnosing-bugs`, `code-review`, `prototype`, `research`

Every skill dir carries a `.upstream.json` (repo, path, commit, license) so
provenance travels with the files.

## Curation notes

- **`tdd` collision**: both sources ship one; pstack's bug-fix/regression
  variant was kept (evidence-first, escape hatch when a failing test is
  impractical).
- **Deliberately excluded from pstack** (Cursor-coupled: `poteto-agent`
  subagent type, Cursor model names, or the cursor-team-kit plugin):
  `poteto-mode` + playbooks, `setup-pstack`, `architect`, `arena`, `swarm`,
  `interrogate`, `how`, `why`, `reflect`, `automate-me`, `no-comments`
  (needs a "Comment Sicko" subagent), `teach` and `recall` (both call
  `how`/`why`), `typescript-best-practices`.
- **Deliberately excluded from Matt**: the tracker-centric pipeline
  (`to-spec`, `to-tickets`, `triage`, `wayfinder`, `implement`, `ask-matt`,
  `setup-matt-pocock-skills`, `grill-with-docs` — depends on `grilling` in
  another category).

## Update checks

```bash
python3 ~/tweak-skill-set/.check-updates.py    # -v for per-file diffstats
```

Clones/fetches both upstream repos into `/tmp/skill-update-cache` and reports
per skill whether upstream changed since the recorded commit. To take an
update: copy the upstream dir over the one here, refresh the `commit` field in
its `.upstream.json`, commit.

## Install & sync

GitHub is the source of truth. Clone, then install:

```bash
git clone https://github.com/golfromeo-fr/tweak-skill-set.git ~/tweak-skill-set
cd ~/tweak-skill-set
./install.sh
```

- **Link mode** (default) symlinks each skill into `~/.agents/skills`.
  `git pull` is then the whole deployment — pulled changes are live at the
  next session start, and an edit made through a symlink is an edit to this
  repo's working copy, so `git status` here reveals live edits before a push.
- **Copy mode** (`./install.sh --copy`) deploys real directory copies for
  platforms/filesystems where links aren't wanted. Re-run it after every
  pull, and never edit the live copy — drift is invisible in this mode.
- Both modes are idempotent. An existing dir that *differs* from the repo
  (usually local edits) is warned about and skipped, never clobbered —
  `--force` to overwrite. `--uninstall` removes this repo's symlinks.
- **Windows**: `install.ps1` — link mode uses directory junctions (no admin
  rights or Developer Mode needed), `-Mode Copy` for copies.
- `restore-copies.sh` converts an existing symlink install to real copies
  (escape hatch if an agent's skill scanner doesn't follow links).

To take an upstream update into this repo: run the checker below, copy the
upstream dir over, refresh the `commit` field in its `.upstream.json`,
commit, push.

## Licenses

All skills are MIT from their upstreams; see `LICENSE.pstack` and
`LICENSE.mattpocock-skills`. No copyright changes made — this repo is a
curated redistribution with per-skill provenance metadata.
