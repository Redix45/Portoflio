# Regenerate WebP files - fix corrupted WebP

$folders = @(
    "photos/operetka",
    "photos/dzien_niepodleglosci_kazik2025",
    "photos/koszecin_jarmark",
    "photos/kazik festiwal"
)

Write-Host "=== Regenerating WebP Files ===" -ForegroundColor Cyan

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        continue
    }
    
    Write-Host "Processing: $folder" -ForegroundColor Yellow
    
    $originalsDir = "$folder/originals"
    
    # Get original JPEG files
    $images = Get-ChildItem "$originalsDir/*.jpg" -File -ErrorAction SilentlyContinue
    
    foreach ($img in $images) {
        # Regenerate full-size WebP
        $webpPath = "$folder/$($img.Name)" -replace '\.jpg$', '.webp'
        Write-Host "  Creating WebP: $($img.Name)" -ForegroundColor Green
        & magick $img.FullName -strip -resize "1920x1920>" -quality 75 -define webp:lossless=false -define webp:method=6 $webpPath
        
        # Regenerate thumbnail WebP
        $thumbDir = "$folder/thumbs"
        $webpThumbPath = Join-Path $thumbDir $($img.Name) -replace '\.jpg$', '.webp'
        & magick $img.FullName -strip -resize "300x300!" -quality 75 -define webp:lossless=false -define webp:method=6 $webpThumbPath
    }
}

Write-Host "=== Done ===" -ForegroundColor Cyan
