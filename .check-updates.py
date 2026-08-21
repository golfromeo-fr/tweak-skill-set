#!/usr/bin/env python3
"""Check installed skills against their upstream repos.

Each skill dir carries an .upstream.json recording the repo URL, path, and the
commit it was installed from. This script clones/fetches each unique repo into
a /tmp cache and reports which skills changed upstream since that commit.

Usage: python3 ~/.agents/skills/.check-updates.py [-v]
  -v prints the per-file diffstat for changed skills
"""
import json
import os
import subprocess
import sys
import urllib.parse

SKILLS_DIR = os.path.dirname(os.path.abspath(__file__))
CACHE_DIR = "/tmp/skill-update-cache"


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def repo_cache(url):
    name = urllib.parse.urlparse(url).path.strip("/").replace("/", "-")
    dest = os.path.join(CACHE_DIR, name)
    if os.path.isdir(os.path.join(dest, ".git")):
        r = run(["git", "-C", dest, "fetch", "--quiet", "origin"])
        if r.returncode != 0:
            print(f"  ! fetch failed for {url}: {r.stderr.strip()}")
    else:
        os.makedirs(CACHE_DIR, exist_ok=True)
        r = run(["git", "clone", "--quiet", url, dest])
        if r.returncode != 0:
            print(f"  ! clone failed for {url}: {r.stderr.strip()}")
            return None
    return dest


def head_of(dest):
    r = run(["git", "-C", dest, "rev-parse", "origin/HEAD"])
    if r.returncode == 0:
        return r.stdout.strip()
    return run(["git", "-C", dest, "rev-parse", "HEAD"]).stdout.strip()


def main():
    verbose = "-v" in sys.argv[1:]
    entries = []
    for name in sorted(os.listdir(SKILLS_DIR)):
        meta = os.path.join(SKILLS_DIR, name, ".upstream.json")
        if os.path.isfile(meta):
            with open(meta) as f:
                entries.append((name, json.load(f)))

    if not entries:
        print("no skills with .upstream.json found")
        return

    repos = {}
    for name, meta in entries:
        repos.setdefault(meta["repo"], []).append((name, meta))

    changed, uptodate, errors = [], [], []
    for url, skills in sorted(repos.items()):
        print(f"\n== {url} ({len(skills)} skills)")
        dest = repo_cache(url)
        if not dest:
            errors.extend(s[0] for s in skills)
            continue
        for name, meta in skills:
            diff = run(["git", "-C", dest, "diff", "--stat",
                        f"{meta['commit']}..HEAD", "--", meta["path"]])
            if diff.returncode != 0:
                errors.append(name)
                print(f"  ? {name}: cannot diff (commit gone upstream? "
                      f"recorded {meta['commit'][:12]}): {diff.stderr.strip()}")
                continue
            if not diff.stdout.strip():
                uptodate.append(name)
                print(f"  = {name}: up to date")
            else:
                changed.append(name)
                lines = [l for l in diff.stdout.strip().splitlines() if l.strip()]
                print(f"  * {name}: CHANGED ({len(lines)} files)")
                if verbose:
                    for l in lines:
                        print(f"      {l}")

    print(f"\nsummary: {len(uptodate)} up to date, {len(changed)} changed, {len(errors)} unknown")
    if changed:
        print("to update a skill: copy <repo-cache>/<path>/* over "
              f"{SKILLS_DIR}/<skill>/ and refresh the commit in its .upstream.json")


if __name__ == "__main__":
    main()
