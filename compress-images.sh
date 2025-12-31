#!/bin/bash
# Skrypt kompresji obrazów dla portfolio fotograficznego
# Używa ustawień wysokiej jakości, aby zachować jakość wizualną przy jednoczesnym zmniejszeniu rozmiaru pliku.

set -e # Przerwij skrypt, jeśli którekolwiek polecenie zwróci błąd

echo "=== Optymalizator obrazów portfolio ==="
echo ""

# Sprawdź, czy ImageMagick (polecenie 'convert') jest zainstalowany
if ! command -v convert &> /dev/null
then
    echo "ImageMagick nie jest zainstalowany. Proszę go zainstalować."
    exit 1
fi

echo "Znaleziono ImageMagick! Rozpoczynanie optymalizacji..."
echo ""

# Foldery ze zdjęciami do przetworzenia
folders=(
    "photos/operetka"
    "photos/dzien_niepodleglosci_kazik2025"
    "photos/koszecin_jarmark"
    "photos/kazik festiwal"
)

totalOriginalSize=0
totalCompressedSize=0
totalFiles=0

for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
        echo "Pomijam $folder (nie znaleziono)"
        continue
    fi

    echo "Przetwarzanie: $folder"
    
    # Znajdź wszystkie pliki .jpg/.jpeg w folderze (bez wchodzenia do podfolderów)
    find "$folder" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r img_path; do
        img_name=$(basename "$img_path")
        originalSize=$(stat -c%s "$img_path")

        # Kompresja z ustawieniami wysokiej jakości (jakość 85 zoptymalizowana dla internetu)
        # -strip usuwa dane EXIF (zmniejsza rozmiar)
        # -quality 85 utrzymuje doskonałą jakość wizualną, znacznie zmniejszając rozmiar
        # -sampling-factor 4:2:0 to standard dla plików JPEG w internecie
        # -interlace Plane tworzy progresywne JPEG (ładują się szybciej wizualnie)
        # -resize zmniejsza wymiary, jeśli obraz jest bardzo duży (maks. 1920px szerokości/wysokości)
        convert "$img_path" -strip -resize "1920x1920>" -quality 85 -sampling-factor 4:2:0 -interlace Plane "$img_path"
        
        newSize=$(stat -c%s "$img_path")
        
        if [ "$newSize" -ge "$originalSize" ]; then
            echo "  POMINIĘTO $img_name: Nie udało się zmniejszyć rozmiaru (lub plik jest już zoptymalizowany)."
            continue
        fi

        savings=$((originalSize - newSize))
        savingsPercent=$(awk "BEGIN {printf \"%.1f\", ($savings / $originalSize) * 100}")
        
        totalOriginalSize=$((totalOriginalSize + originalSize))
        totalCompressedSize=$((totalCompressedSize + newSize))
        totalFiles=$((totalFiles + 1))
        
        originalSizeMB=$(awk "BEGIN {printf \"%.2f\", $originalSize/1024/1024}")
        newSizeMB=$(awk "BEGIN {printf \"%.2f\", $newSize/1024/1024}")

        echo "  OK $img_name: ${originalSizeMB}MB -> ${newSizeMB}MB (-$savingsPercent%)"
    done
    
    echo ""
done

# Podsumowanie
echo "=== Optymalizacja zakończona ==="
echo "Przetworzono plików: $totalFiles"
if [ $totalFiles -gt 0 ]; then
    totalOriginalSizeMB=$(awk "BEGIN {printf \"%.2f\", $totalOriginalSize/1024/1024}")
    totalCompressedSizeMB=$(awk "BEGIN {printf \"%.2f\", $totalCompressedSize/1024/1024}")
    totalSavingsMB=$(awk "BEGIN {printf \"%.2f\", ($totalOriginalSize - $totalCompressedSize)/1024/1024}")
    totalSavingsPercent=$(awk "BEGIN {printf \"%.1f\", (($totalOriginalSize - $totalCompressedSize) / $totalOriginalSize) * 100}")

    echo "Rozmiar oryginalny: $totalOriginalSizeMB MB"
    echo "Rozmiar skompresowany: $totalCompressedSizeMB MB"
    echo "Zaoszczędzone miejsce: $totalSavingsMB MB ($totalSavingsPercent%)"
else
    echo "Nie znaleziono nowych plików do optymalizacji."
fi
echo ""