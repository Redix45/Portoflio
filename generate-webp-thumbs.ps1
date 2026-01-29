# Generate WebP and Thumbnails from existing JPEG files
# For already compressed images

Write-Host "=== Generating WebP and Thumbnails ===" -ForegroundColor Cyan
Write-Host ""

$folders = @(
    "photos/operetka",
    "photos/dzien_niepodleglosci_kazik2025",
    "photos/koszecin_jarmark",
    "photos/kazik festiwal",
    "photos/real_estate/apartamenty/apartament_01",
    "photos/real_estate/apartamenty/apartament_02",
    "photos/real_estate/apartamenty/apartament_03",
    "photos/real_estate/domy/dom_01",
    "photos/real_estate/domy/dom_02",
    "photos/real_estate/komercyjne/biuro_01",
    "photos/real_estate/komercyjne/lokal_01"
)

$totalWebP = 0
$totalThumbs = 0

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        continue
    }
    
    # Skip originals and thumbs folders
    if ($folder -like "*originals*" -or $folder -like "*thumbs*") {
        continue
    }

    Write-Host "Processing: $folder" -ForegroundColor Cyan
    
    # Create thumb directory
    $thumbDir = "$folder/thumbs"
    if (-not (Test-Path $thumbDir)) {
        New-Item -ItemType Directory -Path $thumbDir -Force | Out-Null
    }

    # Process each JPG file
    $images = Get-ChildItem "$folder/*.jpg" -File | Where-Object { $_.DirectoryName -notlike "*originals*" -and $_.DirectoryName -notlike "*thumbs*" }
    
    foreach ($img in $images) {
        # Create WebP
        $webpPath = $img.FullName -replace '\.jpg$', '.webp'
        if (-not (Test-Path $webpPath)) {
            & magick $img.FullName -strip -resize "1920x1920>" -quality 75 -define webp:lossless=false $webpPath
            $webpSize = (Get-Item $webpPath).Length
            Write-Host "  WebP: $($img.Name) - $([math]::Round($webpSize/1KB,1)) KB" -ForegroundColor Green
            $totalWebP++
        }
        
        # Create thumbnail
        $thumbPath = Join-Path $thumbDir $img.Name
        if (-not (Test-Path $thumbPath)) {
            & magick $img.FullName -strip -resize "300x300>" -quality 80 -sampling-factor 4:2:0 $thumbPath
            $thumbSize = (Get-Item $thumbPath).Length
            Write-Host "  Thumb: $($img.Name) - $([math]::Round($thumbSize/1KB,1)) KB" -ForegroundColor Yellow
            $totalThumbs++
        }
        
        # Create WebP thumbnail
        $webpThumbPath = $thumbPath -replace '\.jpg$', '.webp'
        if (-not (Test-Path $webpThumbPath)) {
            & magick $img.FullName -strip -resize "300x300>" -quality 75 -define webp:lossless=false $webpThumbPath
        }
    }
    
    Write-Host ""
}

Write-Host "=== Generation Complete ===" -ForegroundColor Cyan
Write-Host "WebP versions created: $totalWebP" -ForegroundColor Green
Write-Host "Thumbnails created: $totalThumbs" -ForegroundColor Green
