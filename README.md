# Portfolio Fotograficzne - Jan Kobus

Portfolio fotograficzne z optymalizacją wydajności ładowania obrazów.

## 🚀 Optymalizacje

### Zaimplementowane usprawnienia:

1. **Inteligentne ładowanie obrazów**
   - Pierwsze 2 obrazy: `loading="eager"` + `fetchpriority="high"` - ładują się natychmiast
   - Obrazy 3-4: `loading="eager"` - ładują się szybko
   - Pozostałe: `loading="lazy"` - ładują się gdy widoczne w viewport
   - Wszystkie: `decoding="async"` - asynchroniczne dekodowanie

2. **Preload i Preconnect**
   - Preload krytycznych zasobów CSS i pierwszego obrazu
   - Preconnect do Google Fonts, Font Awesome, CDN
   - Przyspiesza pierwsze renderowanie strony

3. **Kompresja obrazów**
   - Quality 85 (optymalna równowaga jakość/rozmiar)
   - Progressive JPEG (szybsze wizualne ładowanie)
   - Auto-resize do max 1920px szerokości
   - Usuwanie EXIF data

4. **Cache i kompresja serwera** (.htaccess)
   - Obrazy: cache 1 rok
   - CSS/JS: cache 1 miesiąc
   - Gzip compression dla wszystkich tekstów

## 📝 Jak używać

### Kompresja nowych obrazów

Gdy dodajesz nowe zdjęcia:

1. Wrzuć oryginalne zdjęcia do odpowiedniego folderu (np. `photos/operetka/`)
2. Uruchom skrypt kompresji:
   ```powershell
   .\compress-images.ps1
   ```
3. Oryginały zostaną zapisane w folderze `originals/`
4. Skompresowane wersje zastąpią oryginalne pliki

### Dodawanie nowej galerii

1. Stwórz folder w `photos/` (np. `photos/nowa_galeria/`)
2. Dodaj zdjęcia jako `foto (1).jpg`, `foto (2).jpg`, itd.
3. Uruchom kompresję: `.\compress-images.ps1`
4. Dodaj folder do listy w skrypcie (jeśli potrzeba)
5. Stwórz nową stronę HTML lub użyj funkcji `loadGallery()`:

```javascript
loadGallery({
    containerId: 'moja-galeria',
    folder: 'photos/nowa_galeria/',
    count: 20,  // liczba zdjęć
    prefix: 'foto',
    extension: '.jpg'
});
```

## 🔧 Wymagania

- **ImageMagick** do kompresji obrazów
  - Instalacja: `choco install imagemagick`
  - Lub: https://imagemagick.org/script/download.php#windows

## 📊 Sprawdź wydajność

Po wdrożeniu sprawdź wydajność na:
- https://pagespeed.web.dev/
- https://gtmetrix.com/

## 🎯 Najważniejsze zmiany

- ✅ Eager loading dla pierwszych 4 obrazów każdej galerii
- ✅ Fetchpriority="high" dla pierwszych 2 obrazów
- ✅ Preconnect do wszystkich zewnętrznych zasobów
- ✅ Zoptymalizowany skrypt kompresji (85 quality, resize, progressive)
- ✅ Cache headers w .htaccess
- ✅ Asynchroniczne dekodowanie wszystkich obrazów
- ✅ Preload krytycznych zasobów

## 📞 Kontakt

Jan Kobus
- Facebook: [Profil](https://www.facebook.com/profile.php?id=100069116356707)
- Instagram: [@redix.45](https://www.instagram.com/redix.45/)
