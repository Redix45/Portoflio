# Advanced Image Compression Script for Photography Portfolio
# Handles Unicode folder names and optimizes all subfolders

Write-Host "=== Photography Portfolio Image Optimizer (Auto-Detect) ===" -ForegroundColor Cyan
Write-Host ""

# Check if ImageMagick is installed
$magickPath = Get-Command magick -ErrorAction SilentlyContinue

if (-not $magickPath) {
    Write-Host "ImageMagick is not installed." -ForegroundColor Yellow
    exit
}

Write-Host "ImageMagick found! Starting optimization..." -ForegroundColor Green
Write-Host ""

# Dynamically find all photo folders (skip real_estate for now, handle separately)
$photoRoot = "photos"
$folders = Get-ChildItem $photoRoot -Directory | Where-Object { $_.Name -ne "real_estate" } | ForEach-Object { Join-Path $photoRoot $_.Name }

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
    $backupFolder = Join-Path $folder "originals"
    if (-not (Test-Path $backupFolder)) {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        Write-Host "  Created backup folder: $backupFolder" -ForegroundColor Gray
    }

    # Get all jpg/JPG files
    $images = Get-ChildItem "$folder\*.jpg" -File | Where-Object { $_.DirectoryName -notlike "*originals*" }
    $images += Get-ChildItem "$folder\*.JPG" -File | Where-Object { $_.DirectoryName -notlike "*originals*" }
    
    foreach ($img in $images) {
        $originalSize = $img.Length
        $backupPath = Join-Path $backupFolder $img.Name
        
        # Skip if already processed (backup exists)
        if (Test-Path $backupPath) {
            Write-Host "  Skipping $($img.Name) (already optimized)" -ForegroundColor DarkGray
            continue
        }

        try {
            # Backup original
            Copy-Item $img.FullName $backupPath -Force
            
            # Compress original JPEG with high quality settings
            Write-Host "  Compressing $($img.Name)..." -ForegroundColor White
            & magick $img.FullName -strip -resize "1920x1920>" -quality 80 -sampling-factor 4:2:0 -interlace Plane $img.FullName
            
            $newSize = (Get-Item $img.FullName).Length
            $savings = $originalSize - $newSize
            $savingsPercent = [math]::Round(($savings / $originalSize) * 100, 1)
            
            # Create WebP version (better compression)
            $webpPath = $img.FullName -replace '\.(jpg|JPG)$', '.webp'
            Write-Host "  Creating WebP version..." -ForegroundColor White
            & magick $backupPath -strip -resize "1920x1920>" -quality 75 -define webp:lossless=false $webpPath
            $webpSize = (Get-Item $webpPath).Length
            
            # Create thumbnail folder and thumbnails
            $thumbDir = Join-Path $folder "thumbs"
            if (-not (Test-Path $thumbDir)) {
                New-Item -ItemType Directory -Path $thumbDir -Force | Out-Null
            }
            
            Write-Host "  Creating thumbnail..." -ForegroundColor White
            $thumbPath = Join-Path $thumbDir $img.Name
            & magick $backupPath -strip -resize "300x300>" -quality 80 -sampling-factor 4:2:0 $thumbPath
            $thumbSize = (Get-Item $thumbPath).Length
            
            # Create WebP thumbnail
            $webpThumbPath = $thumbPath -replace '\.(jpg|JPG)$', '.webp'
            & magick $backupPath -strip -resize "300x300>" -quality 75 -define webp:lossless=false $webpThumbPath
            
            $totalOriginalSize += $originalSize
            $totalCompressedSize += $newSize
            $totalFiles++
            
            Write-Host "  [OK] $($img.Name):" -ForegroundColor Green
            Write-Host "        JPEG: $([math]::Round($originalSize/1MB,2)) MB to $([math]::Round($newSize/1MB,2)) MB (save: $savingsPercent %)" -ForegroundColor White
            Write-Host "        WebP: $([math]::Round($webpSize/1MB,2)) MB | Thumb: $([math]::Round($thumbSize/1MB,2)) MB" -ForegroundColor Gray
        }
        catch {
            Write-Host "  [ERROR] $($img.Name): $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host "=== Optimization Complete ===" -ForegroundColor Cyan
Write-Host "Files processed: $totalFiles" -ForegroundColor White
if ($totalFiles -gt 0) {
    Write-Host "Original size: $([math]::Round($totalOriginalSize/1MB,2)) MB" -ForegroundColor White
    Write-Host "Compressed size: $([math]::Round($totalCompressedSize/1MB,2)) MB" -ForegroundColor White
    $totalSavings = $totalOriginalSize - $totalCompressedSize
    $totalSavingsPercent = [math]::Round(($totalSavings / $totalOriginalSize) * 100, 1)
    Write-Host "Space saved: $([math]::Round($totalSavings/1MB,2)) MB (savings: $totalSavingsPercent %)" -ForegroundColor Green
} else {
    Write-Host "No new files to optimize - all images already compressed!" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Backups: photos/*/originals/" -ForegroundColor Gray
Write-Host "Thumbnails: photos/*/thumbs/" -ForegroundColor Gray
Write-Host "WebP versions: photos/*/*.webp" -ForegroundColor Gray
