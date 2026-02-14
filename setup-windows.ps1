$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Preflight: fail fast when symbolic link creation is not permitted.
$testTarget = Join-Path $env:TEMP ("dotfiles_link_target_{0}.txt" -f ([guid]::NewGuid().ToString("N")))
$testLink = Join-Path $env:TEMP ("dotfiles_link_test_{0}.txt" -f ([guid]::NewGuid().ToString("N")))
New-Item -ItemType File -Path $testTarget -Force | Out-Null
try {
  New-Item -ItemType SymbolicLink -Path $testLink -Target $testTarget | Out-Null
} finally {
  if (Test-Path -LiteralPath $testLink) { Remove-Item -LiteralPath $testLink -Force }
  if (Test-Path -LiteralPath $testTarget) { Remove-Item -LiteralPath $testTarget -Force }
}

Get-ChildItem -Path $repoDir -Force |
  Where-Object {
    $_.Name.StartsWith(".") -and $_.Name -notin @(".", "..", ".git")
  } |
  ForEach-Object {
    $src = $_.FullName
    $dest = Join-Path $env:USERPROFILE $_.Name

    if (Test-Path -LiteralPath $dest) {
      $item = Get-Item -LiteralPath $dest -Force
      if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Remove-Item -LiteralPath $dest -Force
      } else {
        throw "Real file or directory already exists at $dest"
      }
    }

    $itemType = if ($_.PSIsContainer) { "Junction" } else { "SymbolicLink" }
    New-Item -ItemType $itemType -Path $dest -Target $src | Out-Null
    Write-Host "Linked: $dest -> $src"
  }

$gitConfigSrc = Join-Path $repoDir ".gitconfig.windows"
$gitConfigDest = Join-Path $env:USERPROFILE ".gitconfig"

if (Test-Path -LiteralPath $gitConfigDest) {
  $item = Get-Item -LiteralPath $gitConfigDest -Force
  if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
    Remove-Item -LiteralPath $gitConfigDest -Force
  } else {
    throw "Real file or directory already exists at $gitConfigDest"
  }
}

$itemType = if (Test-Path -LiteralPath $gitConfigSrc -PathType Container) { "Junction" } else { "SymbolicLink" }
New-Item -ItemType $itemType -Path $gitConfigDest -Target $gitConfigSrc | Out-Null
Write-Host "Linked: $gitConfigDest -> $gitConfigSrc"

Write-Host "Done."
