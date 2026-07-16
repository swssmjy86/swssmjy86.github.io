---
name: git-branch-workflow
description: Runs a feature-branch git workflow for this Jekyll resume repo — create a branch, commit, push, run a pre-merge validation checklist, then merge into master and clean up the branch. Use this whenever the user wants a larger or riskier change (CSS/SCSS, _sass, _layouts, scripts, or any multi-file edit) reviewed on a branch instead of going straight to master. The default flow in this repo (documented in CLAUDE.md) auto-commits and pushes index.md edits directly to master via a Stop hook — this skill is the deliberate alternative for anything that shouldn't skip review. Trigger on phrases like "브랜치 만들어서", "브랜치로 작업해줘", "머지 전에 검증", "브랜치 워크플로우", "PR로 올려줘", "feature branch", or whenever a change touches files outside index.md and the user wants it checked before it lands on master.
---

# Git Branch Workflow (swssmjy86.github.io)

This repo normally ships changes straight to `master`: editing `index.md` triggers the
Claude Stop hook (`.claude/hooks/auto-push.ps1`), which runs `scripts/version-push.ps1`
and pushes directly. That's fine for routine CV text edits, but it skips review — no
diff check, no build sanity check, nothing stopping a broken `_sass` import or a
missing YAML front matter from going live (this happened before: `css/main.scss` lost
its front matter for over a year and the live site served zero CSS because of it).

Use this skill when the change is bigger than a one-line CV update: layout, styles,
scripts, or anything touching more than `index.md`. It walks through five phases —
**branch → commit → push → validate → merge** — and treats push and merge as actions
that need the user's explicit go-ahead, same as anywhere else in this repo.

## Before you start

Check the working tree first:

```bash
git status
git branch --show-current
```

If there are unrelated uncommitted changes sitting around, stop and ask the user what
to do with them before creating a new branch on top of them — don't silently stash or
discard anything.

## Phase 1 — Create the branch

Branch from `master`, naming by what changed:

- `feature/<slug>` — new capability or structural change (e.g. `feature/timeline-css-fix`)
- `update/<slug>` — content/config update that's still going through review
- `fix/<slug>` — bug fix

```bash
git checkout master
git pull origin master
git checkout -b feature/<slug>
```

Derive `<slug>` from the user's description (short, kebab-case, English is fine even
in this Korean-content repo — branch names aren't user-facing).

## Phase 2 — Commit

Stage specific files by name — never `git add -A` blindly, this repo has scripts and
hook files that shouldn't get swept in by accident:

```bash
git add <file1> <file2> ...
git commit -m "<description>"
```

**Important — if `index.md` is part of this change, commit it as part of this same
step, before the turn ends.** The Stop hook fires on *any* uncommitted `index.md`
diff regardless of which branch is checked out — it doesn't know about feature
branches. If you leave `index.md` dirty at the end of a turn while on a feature
branch, the hook will commit it *on that branch*, bump `version.txt`, and create a
version tag pointing at a feature-branch commit that never reaches master through the
normal path. Committing it yourself here avoids that entirely.

Commit message style: plain and descriptive is fine (this branch will likely get
squash- or merge-committed, not tagged individually the way direct-to-master CV edits
are). Don't invent a `[vX.X]` version bump here — that convention belongs to the
`index.md` → master fast path; if this branch's merge should also bump the version,
handle that explicitly in Phase 5, not here.

## Phase 3 — Push

```bash
git push -u origin <branch-name>
```

This publishes the branch to the shared remote. **Confirm with the user before
running it** — pushing is visible to anyone with repo access, even on a feature
branch.

## Phase 4 — Validate before merge

This is the checkpoint that's supposed to catch what direct-to-master pushes skip.
Run every item that applies to the files this branch touched, and show the user a
pass/fail summary before proceeding to Phase 5. If anything fails, fix it and re-run
the checklist — don't merge on a partial pass.

**1. Tree and diff sanity (always run)**
```bash
git status
git diff master...<branch-name> --stat
```
Confirm nothing unintended is in scope, and the working tree is clean (no leftover
uncommitted work on the branch).

**2. `index.md` integrity (if `index.md` changed)**
- Front matter intact: file starts with `---\nlayout: default\n---`
- All five section headers still present: `## Contact Information`, `## Education`,
  `## Work Experience`, `## Notable Projects`, `## Personal Information`
- No leftover placeholders: search for `TODO`, `FIXME`, `Lorem ipsum`, empty links
  `]()`, or unresolved `mailto:` targets
- HTML balance in the timeline block: every `<div class="timeline-item ...">` has a
  matching `</div>` — an easy thing to break when hand-editing the work-experience
  timeline markup
- `**Last Updated:**` line still present at the bottom

**3. Stylesheet build integrity (if `css/main.scss` or anything in `_sass/` changed)**
- `css/main.scss` **must start with Jekyll front matter** (`---` on its own line,
  then another `---`) — without it, Jekyll silently skips Sass compilation and
  `css/main.css` 404s on the live site with zero warning. Check this explicitly,
  every time; it's exactly the bug that motivated this checklist.
- Every `@import` in any `.scss` file resolves to a partial that actually exists in
  `_sass/`
- No new file added to `_sass/` without something importing it (orphaned dead CSS)

**4. Script integrity (if anything in `scripts/` changed)**
```powershell
[System.Management.Automation.Language.Parser]::ParseFile("<path>", [ref]$null, [ref]$errors)
$errors
```
Confirm `$errors` is empty — this parses the script without running it.

**5. Version consistency (only if this branch is meant to carry a version bump)**
- `version.txt` matches `v{major}.{minor}` format
- If a tag is meant to accompany this merge, confirm no tag with that name already
  exists: `git tag -l <version>`

Report the checklist results to the user as a short pass/fail list before moving on.

## Phase 5 — Merge

Only merge after the Phase 4 checklist passes **and** the user has explicitly said to
proceed — merging into `master` deploys straight to the live GitHub Pages site, so
treat it like any other hard-to-reverse, shared-state action.

```bash
git checkout master
git pull origin master
git merge --no-ff <branch-name> -m "Merge branch '<branch-name>'"
git push origin master
```

(`gh` isn't installed in this environment, so this repo uses a local merge rather than
a GitHub PR. If the user later sets up `gh auth login`, `gh pr create` /
`gh pr merge` is a reasonable drop-in replacement for this phase — ask before assuming
which one they want.)

If this merge is meant to also bump the version and tag (see Phase 4.5), do that here
rather than relying on the Stop hook, since the hook only reacts to `index.md` and
this merge may involve more than that:

```bash
git tag -a <version> -m "<description>"
git push origin <version>
```

## Phase 6 — Clean up

Ask the user whether to delete the feature branch now that it's merged:

```bash
git branch -d <branch-name>
git push origin --delete <branch-name>
```

Don't delete it automatically — the user may want to keep it around a bit in case the
merge needs to be revisited.
