$ErrorActionPreference = "Continue"
$TargetDir = "D:\NET35_Offline"
$Downloads = "$env:USERPROFILE\Downloads"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  .NET 3.5 sxs Extraction (Auto)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$isoFiles = @(Get-ChildItem -Path $Downloads -Filter "Win*.iso" -ErrorAction SilentlyContinue)

if ($isoFiles.Count -eq 0) {
    Write-Host "[X] No Win*.iso found in Downloads" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($isoFiles.Count) ISO(s) in Downloads:" -ForegroundColor Green
$isoFiles | ForEach-Object { Write-Host "  - $($_.Name) ($([math]::Round($_.Length/1GB,1)) GB)" -ForegroundColor White }
Write-Host ""

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

foreach ($iso in $isoFiles) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Processing: $($iso.Name)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    
    # Mount ISO
    Write-Host "  Mounting ISO..." -ForegroundColor Green
    try {
        $mount = Mount-DiskImage -ImagePath $iso.FullName -PassThru -ErrorAction Stop
        Start-Sleep -Seconds 2  # Wait for mount to complete
        $vol = $mount | Get-Volume
        if (-not $vol) {
            # Try alternate method
            $dl = (Get-DiskImage -ImagePath $iso.FullName | Get-Volume).DriveLetter
        } else {
            $dl = $vol.DriveLetter
        }
        $drivePath = "${dl}:\"
        Write-Host "  Mounted at $drivePath" -ForegroundColor Gray
    } catch {
        Write-Host "  [X] Mount failed: $_" -ForegroundColor Red
        continue
    }
    
    # Check for sxs
    $sxsSource = "${drivePath}sources\sxs"
    if (-not (Test-Path $sxsSource)) {
        Write-Host "  [X] No sources\sxs found in ISO" -ForegroundColor Red
        Dismount-DiskImage -ImagePath $iso.FullName | Out-Null
        continue
    }
    
    # Detect version from build number
    $build = 0
    $dismPath = "${drivePath}sources\dism.exe"
    if (Test-Path $dismPath) {
        $build = (Get-Item $dismPath).VersionInfo.FileBuildPart
    }
    if ($build -eq 0) {
        $setupPath = "${drivePath}sources\setuphost.exe"
        if (Test-Path $setupPath) {
            $build = (Get-Item $setupPath).VersionInfo.FileBuildPart
        }
    }
    
    # Map build -> version name
    if ($build -ge 26100) { $verName = "Win11_25H2" }
    elseif ($build -ge 22621 -and $build -lt 26100) { $verName = "Win11_24H2" }
    elseif ($build -ge 22621) { $verName = "Win11_23H2" }
    elseif ($build -ge 22000) { $verName = "Win11_22H2" }
    elseif ($build -ge 19041) { $verName = "Win10_22H2" }
    else { $verName = "Unknown_build${build}" }
    
    Write-Host "  Detected: $verName (build $build)" -ForegroundColor Cyan
    
    # Copy sxs
    $destDir = "$TargetDir\$verName\sxs"
    Write-Host "  Copying sxs to $destDir ..." -ForegroundColor Green
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    
    try {
        Copy-Item -Path "$sxsSource\*" -Destination $destDir -Recurse -Force -ErrorAction Stop
        $cabCount = @(Get-ChildItem -Path $destDir -Filter "*.cab").Count
        Write-Host "  Done! $cabCount CAB files copied" -ForegroundColor Green
    } catch {
        Write-Host "  [X] Copy failed: $_" -ForegroundColor Red
    }
    
    # Dismount
    Write-Host "  Dismounting ISO..." -ForegroundColor Gray
    Dismount-DiskImage -ImagePath $iso.FullName | Out-Null
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Extraction Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Contents of $TargetDir :" -ForegroundColor Cyan

Get-ChildItem -Path $TargetDir -Directory | ForEach-Object {
    $sxsPath = Join-Path $_.FullName "sxs"
    if (Test-Path $sxsPath) {
        $cabCount = @(Get-ChildItem -Path $sxsPath -Filter "*.cab" -ErrorAction SilentlyContinue).Count
        Write-Host "  $($_.Name)\sxs\  ($cabCount CABs)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Ready! Run install.bat on any client machine." -ForegroundColor Yellow
