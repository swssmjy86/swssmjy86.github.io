# version-push.ps1
# Usage: ./scripts/version-push.ps1 "변경 내용 설명"
# Increments minor version, updates Last Updated, commits with tag, and pushes.

param(
    [Parameter(Mandatory = $false)]
    [string]$Description = "CV 업데이트"
)

$rootDir = Split-Path $PSScriptRoot -Parent
$versionFile = Join-Path $rootDir "version.txt"
$indexFile   = Join-Path $rootDir "index.md"

# --- 1. Version bump ---
$current = (Get-Content $versionFile -Raw).Trim()
if ($current -match '^v(\d+)\.(\d+)$') {
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2] + 1
    $newVersion = "v${major}.${minor}"
} else {
    $newVersion = "v1.1"
}
Set-Content -Path $versionFile -Value $newVersion -NoNewline
Write-Host "Version: $current -> $newVersion"

# --- 2. Update 'Last Updated' in index.md ---
$today = (Get-Date).ToString("MMMM d, yyyy")
$content = Get-Content $indexFile -Raw -Encoding UTF8
$content = $content -replace '\*\*Last Updated:\*\*[^\n]*', "**Last Updated:** $today"
[System.IO.File]::WriteAllText($indexFile, $content, [System.Text.Encoding]::UTF8)

# --- 3. Git commit + tag + push ---
git -C $rootDir add index.md version.txt
git -C $rootDir commit -m "[$newVersion] $Description"
git -C $rootDir tag -a $newVersion -m "$Description"
git -C $rootDir push origin master
git -C $rootDir push origin $newVersion

Write-Host "Pushed $newVersion : $Description"
