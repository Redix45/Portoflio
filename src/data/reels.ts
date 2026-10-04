// Realizacje pokazywane w sekcji "Realizacje" na stronie głównej.
// Pusta lista = strona pokazuje puste sloty 9:16 z zaproszeniem do kontaktu.
//
// Dodanie rolki:
//   1. Wrzuć plik do public/reels/ (MP4 H.264, 1080x1920, najlepiej < 8 MB)
//      i klatkę podglądu (JPG/WebP, 1080x1920) obok.
//   2. Dopisz obiekt poniżej.
//
// {
//   title: 'Wesele Alicji i Kacpra',
//   category: 'Wesele',
//   track: 'v1',            // kolor etykiety: v1 | v2 | a1 | t1
//   src: '/reels/wesele.mp4',
//   srcHd: '/reels/wesele-hd.mp4',   // opcjonalnie, do powiększenia
//   poster: '/reels/wesele.jpg',
//   duration: '0:45',
// },

export interface Reel {
  title: string;
  category: string;
  track: 'v1' | 'v2' | 'a1' | 't1';
  src: string;
  srcHd?: string;          // wersja 1080x1920 do powiększenia (opcjonalnie)
  poster: string;
  duration: string;
}

export const reels: Reel[] = [
  {
    title: 'Kajaki Krupski Młyn',
    category: 'Reklama lokalnej firmy',
    track: 'v1',
    src: '/reels/kajaki.mp4',
    srcHd: '/reels/kajaki-hd.mp4',
    poster: '/reels/kajaki.jpg',
    duration: '0:44',
  },
  {
    title: 'Promo aplikacji Ogarnij Egzamin',
    category: 'Reklama aplikacji',
    track: 'a1',
    src: '/reels/ogarnijegzamin.mp4',
    srcHd: '/reels/ogarnijegzamin-hd.mp4',
    poster: '/reels/ogarnijegzamin.jpg',
    duration: '0:15',
  },
];

// Ile slotów pokazać łącznie (realizacje + puste sloty).
export const REEL_SLOTS = 4;
