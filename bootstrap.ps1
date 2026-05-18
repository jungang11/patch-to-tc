#Requires -Version 7
<#
.SYNOPSIS
    Install or update the mobile-build-tc-from-diff skill into a target project.

.DESCRIPTION
    Copies .claude/skills/mobile-build-tc-from-diff/ from this patch-to-tc
    repository into the target project's .claude/skills/. SHA-256 hash
    comparison is used to skip unchanged files. Safe to re-run.

.PARAMETER TargetProject
    Absolute path to the target project. Should be a git repository; the
    script warns (but does not block with -Force) if it is not.

.PARAMETER Force
    Skip confirmation prompts. Overwrites existing files without asking.

.PARAMETER WhatIf
    Show what would be done without making any changes. (PowerShell built-in.)

.EXAMPLE
    .\bootstrap.ps1 -TargetProject E:\Personal\my-unity-project

.EXAMPLE
    .\bootstrap.ps1 -TargetProject E:\Personal\my-unity-project -WhatIf

.EXAMPLE
    .\bootstrap.ps1 -TargetProject E:\Personal\my-unity-project -Force
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$TargetProject,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Resolve paths
$ScriptRoot = Split-Path -Parent $PSCommandPath
$SourceSkill = Join-Path $ScriptRoot '.claude\skills\mobile-build-tc-from-diff'

if (-not (Test-Path $SourceSkill)) {
    Write-Error "Source skill not found at $SourceSkill - run this script from the patch-to-tc repository root."
    exit 1
}

if (-not (Test-Path $TargetProject)) {
    Write-Error "Target project path does not exist: $TargetProject"
    exit 1
}

$TargetProject = (Resolve-Path $TargetProject).Path
$TargetSkill = Join-Path $TargetProject '.claude\skills\mobile-build-tc-from-diff'
$SourceRoot = (Resolve-Path $ScriptRoot).Path

# Safety: refuse to bootstrap into patch-to-tc itself
if ($SourceRoot -eq $TargetProject) {
    Write-Error "Target is the patch-to-tc repository itself. Specify a different project."
    exit 2
}

# Safety: target should be a git repository
if (-not (Test-Path (Join-Path $TargetProject '.git'))) {
    Write-Warning "Target $TargetProject is not a git repository."
    if (-not $Force) {
        $confirm = Read-Host "Continue anyway? [y/N]"
        if ($confirm -ne 'y') { exit 3 }
    }
}

# Ensure target .claude/skills exists
$TargetSkillsDir = Join-Path $TargetProject '.claude\skills'
if (-not (Test-Path $TargetSkillsDir)) {
    if ($PSCmdlet.ShouldProcess($TargetSkillsDir, "Create skills directory")) {
        New-Item -ItemType Directory -Path $TargetSkillsDir -Force | Out-Null
    }
}

# Walk source files and compare hashes
$SourceFiles = Get-ChildItem -Path $SourceSkill -Recurse -File
$copied = 0
$updated = 0
$skipped = 0

foreach ($file in $SourceFiles) {
    $relPath = $file.FullName.Substring($SourceSkill.Length + 1)
    $targetFile = Join-Path $TargetSkill $relPath

    $srcHash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
    $existed = Test-Path $targetFile

    if ($existed) {
        $tgtHash = (Get-FileHash -Path $targetFile -Algorithm SHA256).Hash
        if ($srcHash -eq $tgtHash) {
            $skipped++
            continue
        }
    }

    $action = if ($existed) { "update" } else { "copy new" }
    if ($PSCmdlet.ShouldProcess($targetFile, $action)) {
        $tgtDir = Split-Path -Parent $targetFile
        if (-not (Test-Path $tgtDir)) {
            New-Item -ItemType Directory -Path $tgtDir -Force | Out-Null
        }
        Copy-Item -Path $file.FullName -Destination $targetFile -Force
        if ($existed) { $updated++ } else { $copied++ }
    }
}

Write-Host ""
Write-Host "Bootstrap complete:" -ForegroundColor Green
Write-Host "  - $copied new file(s)"
Write-Host "  - $updated updated file(s)"
Write-Host "  - $skipped unchanged file(s) skipped"
Write-Host ""
Write-Host "Next step:"
Write-Host "  cd `"$TargetProject`""
Write-Host "  claude"
Write-Host "  > /mobile-build-tc-from-diff"
