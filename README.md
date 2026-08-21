# tweak-skill-set

Curated agent-skill set for coding work, installed live at `~/.agents/skills/`
via **symlinks into this repo** — tweak a skill here and every agent session
picks it up. ZCode (and Claude Code / Codex, if used later) discover skills
from `~/.agents/skills/`.

## Contents (23 skills)

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

## Install on another machine

```bash
git clone https://github.com/golfromeo-fr/tweak-skill-set.git ~/tweak-skill-set
cd ~/tweak-skill-set
for d in */; do ln -s "$PWD/$d" ~/.agents/skills/"$(basename "$d")"; done
```

If your agent doesn't discover skills through symlinks, run
`./restore-copies.sh` to replace them with real copies.

## Licenses

All skills are MIT from their upstreams; see `LICENSE.pstack` and
`LICENSE.mattpocock-skills`. No copyright changes made — this repo is a
curated redistribution with per-skill provenance metadata.
