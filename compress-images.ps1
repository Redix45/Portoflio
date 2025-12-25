# Image Compression Script for Photography Portfolio
# Uses high quality settings to maintain visual quality while reducing file size

Write-Host "=== Photography Portfolio Image Optimizer ===" -ForegroundColor Cyan
Write-Host ""

# Check if ImageMagick is installed
$magickPath = Get-Command magick -ErrorAction SilentlyContinue

if (-not $magickPath) {
    Write-Host "ImageMagick is not installed." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install ImageMagick:" -ForegroundColor White
    Write-Host "1. Using Chocolatey (recommended):" -ForegroundColor Green
    Write-Host "   choco install imagemagick" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Or download from: https://imagemagick.org/script/download.php#windows" -ForegroundColor Green
    Write-Host ""
    Write-Host "After installation, restart PowerShell and run this script again." -ForegroundColor Yellow
    exit
}

Write-Host "ImageMagick found! Starting optimization..." -ForegroundColor Green
Write-Host ""

# Get all photo folders
$folders = @(
    "photos/operetka",
    "photos/dzien_niepodleglosci_kazik2025",
    "photos/koszecin_jarmark",
    "photos/kazik festiwal"
)

$totalOriginalSize = 0
$totalCompressedSize = 0
$totalFiles = 0

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        Write-Host "Skipping $folder (not found)" -ForegroundColor Yellow
        continue
    }

    Write-Host "Processing: $folder" -ForegroundColor Cyan
    
    # Create backup folder
    $backupFolder = "$folder/originals"
    if (-not (Test-Path $backupFolder)) {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        Write-Host "  Created backup folder: $backupFolder" -ForegroundColor Gray
    }

    # Get all jpg files
    $images = Get-ChildItem "$folder/*.jpg" -File | Where-Object { $_.DirectoryName -notlike "*originals*" }
    
    foreach ($img in $images) {
        $originalSize = $img.Length
        $backupPath = Join-Path $backupFolder $img.Name
        
        # Skip if already processed (backup exists)
        if (Test-Path $backupPath) {
            Write-Host "  Skipping $($img.Name) (already optimized)" -ForegroundColor DarkGray
            continue
        }

        # Backup original
        Copy-Item $img.FullName $backupPath -Force
        
        # Compress with high quality settings (quality 92, optimized for web)
        # -strip removes EXIF data
        # -quality 92 maintains excellent visual quality
        # -sampling-factor 4:2:0 is standard for web JPEGs
        & magick $img.FullName -strip -quality 92 -sampling-factor 4:2:0 -interlace Plane $img.FullName
        
        $newSize = (Get-Item $img.FullName).Length
        $savings = $originalSize - $newSize
        $savingsPercent = [math]::Round(($savings / $originalSize) * 100, 1)
        
        $totalOriginalSize += $originalSize
        $totalCompressedSize += $newSize
        $totalFiles++
        
        Write-Host "  OK $($img.Name): " -NoNewline -ForegroundColor Green
        Write-Host "$([math]::Round($originalSize/1MB,2))MB -> $([math]::Round($newSize/1MB,2))MB " -NoNewline
        Write-Host "(-$savingsPercent percent)" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Summary
Write-Host "=== Optimization Complete ===" -ForegroundColor Cyan
Write-Host "Files processed: $totalFiles" -ForegroundColor White
Write-Host "Original size: $([math]::Round($totalOriginalSize/1MB,2)) MB" -ForegroundColor White
Write-Host "Compressed size: $([math]::Round($totalCompressedSize/1MB,2)) MB" -ForegroundColor White
$totalSavings = $totalOriginalSize - $totalCompressedSize
$totalSavingsPercent = [math]::Round(($totalSavings / $totalOriginalSize) * 100, 1)
Write-Host "Space saved: $([math]::Round($totalSavings/1MB,2)) MB ($totalSavingsPercent percent)" -ForegroundColor Green
Write-Host ""
Write-Host "Original files backed up to originals folders" -ForegroundColor Gray
Write-Host "You can restore from the backups if needed" -ForegroundColor Gray
