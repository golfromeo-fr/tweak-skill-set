# Install skills from this repo into an agent skills directory (Windows).
#
#   .\install.ps1              link mode (default): directory junctions
#   .\install.ps1 -Mode Copy   real directory copies
#   .\install.ps1 -Force       replace targets that differ from the repo
#
# Junctions need no admin rights or Developer Mode (true NTFS symlinks need
# Developer Mode). Link mode makes `git pull` the deployment; an edit made
# through a junction is an edit to this repo's working copy, visible in
# `git status`. Existing real dirs that differ from the repo are skipped with
# a warning unless -Force (a differing dir usually means local edits).
param(
  [ValidateSet('Link', 'Copy')] [string]$Mode = 'Link',
  [switch]$Force,
  [string]$Destination = "$env:USERPROFILE\.agents\skills"
)

$repo = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$stats = @{ linked = 0; copied = 0; already = 0; replaced = 0; warned = 0 }

foreach ($d in Get-ChildItem -Directory $repo) {
  if (-not (Test-Path (Join-Path $d.FullName 'SKILL.md'))) { continue }
  $target = Join-Path $Destination $d.Name
  $existing = if (Test-Path $target) { Get-Item $target -Force } else { $null }

  if ($Mode -eq 'Link') {
    if ($existing) {
      $isOurs = ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -and
                ($existing.Target -eq $d.FullName)
      if ($isOurs) { $stats.already++; continue }
      if (-not $Force) {
        $stats.warned++
        Write-Warning "$($d.Name): exists and is not a junction to this repo - skipping (use -Force)"
        continue
      }
      Remove-Item -Recurse -Force $target
      $stats.replaced++
    }
    New-Item -ItemType Junction -Path $target -Value $d.FullName | Out-Null
    if (-not $existing) { $stats.linked++ }
  }
  else {
    if ($existing) {
      $same = -not (Compare-Object `
        (Get-ChildItem -Recurse -File $target | Get-FileHash) `
        (Get-ChildItem -Recurse -File $d.FullName | Get-FileHash))
      if ($same) { $stats.already++; continue }
      if (-not $Force) {
        $stats.warned++
        Write-Warning "$($d.Name): existing dir differs from repo - skipping (use -Force)"
        continue
      }
      Remove-Item -Recurse -Force $target
      $stats.replaced++
    }
    Copy-Item -Recurse $d.FullName $target
    if (-not $existing) { $stats.copied++ }
  }
}

Write-Host "$Mode mode -> $Destination: linked=$($stats.linked) copied=$($stats.copied) already_ok=$($stats.already) replaced=$($stats.replaced) warned=$($stats.warned)"
