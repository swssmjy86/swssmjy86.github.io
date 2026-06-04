# auto-push.ps1 — Claude Code Stop hook
# Runs when Claude finishes responding.
# If index.md has uncommitted changes, auto-bumps version and pushes.

$rootDir = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

$status = git -C $rootDir status --porcelain index.md 2>&1
if (-not $status) { exit 0 }

# Build a description from changed section headers in the diff
$diff = git -C $rootDir diff HEAD -- index.md 2>&1
if (-not $diff) {
    $diff = git -C $rootDir diff -- index.md 2>&1
}

$added = $diff |
    Where-Object { $_ -match '^\+' -and $_ -notmatch '^\+\+\+' } |
    Where-Object { $_ -match '^\+\*\*|^\+#' } |
    ForEach-Object { ($_ -replace '^\+', '').Trim() -replace '\*\*', '' -replace '^#+\s*', '' } |
    Select-Object -Unique -First 3

$description = if ($added) { ($added -join ', ') + ' 업데이트' } else { 'CV 업데이트' }

& (Join-Path $rootDir "scripts\version-push.ps1") $description
