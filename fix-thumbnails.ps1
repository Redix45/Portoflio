# Fix Thumbnails - regenerate with proper dimensions

$folders = @(
    "photos/operetka",
    "photos/dzien_niepodleglosci_kazik2025",
    "photos/koszecin_jarmark",
    "photos/kazik festiwal"
)

Write-Host "=== Fixing Thumbnails ===" -ForegroundColor Cyan

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        continue
    }
    
    Write-Host "Fixing: $folder" -ForegroundColor Yellow
    
    $thumbDir = "$folder/thumbs"
    $originalsDir = "$folder/originals"
    
    # Get original JPEG files
    $images = Get-ChildItem "$originalsDir/*.jpg" -File -ErrorAction SilentlyContinue
    
    foreach ($img in $images) {
        $thumbPath = Join-Path $thumbDir $img.Name
        
        # Regenerate thumbnail with fixed aspect ratio (fill to 300x300)
        & magick $img.FullName -strip -resize "300x300!" -quality 80 $thumbPath
        
        # Regenerate WebP thumbnail
        $webpThumbPath = $thumbPath -replace '\.jpg$', '.webp'
        & magick $img.FullName -strip -resize "300x300!" -quality 75 -define webp:lossless=false $webpThumbPath
        
        Write-Host "  Fixed: $($img.Name)" -ForegroundColor Green
    }
}

Write-Host "=== Done ===" -ForegroundColor Cyan
