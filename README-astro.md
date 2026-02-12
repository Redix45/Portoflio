# Migracja do Astro — instrukcja

Krótkie kroki aby wykonać migrację i uruchomić lokalnie:

1. Zainstaluj zależności:

```bash
npm install
```

2. Uruchom skrypt migracji, który przekonwertuje pliki `.html` w katalogu głównym na pliki `.astro` w `src/pages` oraz skopiuje zasoby do `public/`:

```bash
npm run migrate
```

3. Uruchom Astro w trybie deweloperskim:

```bash
npm run dev
```

Pliki utworzone przez skrypt:
- `src/pages/*.astro` — wygenerowane strony
- `src/layouts/BaseLayout.astro` — podstawowy layout
- `public/*` — skopiowane zasoby (CSS/JS/photos)

Jeśli chcesz, mogę teraz uruchomić `npm install` i `npm run migrate` lokalnie (powiedz "tak"), albo przejść dalej i skonwertować layouty/komponenty lepiej ręcznie.
