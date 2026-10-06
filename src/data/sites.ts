// Realizacje stron internetowych: strona główna (sekcja Realizacje) i /strony-internetowe/.
// Zrzuty ekranu: public/web/<img>.webp + .jpg, 1200x750.

export interface SiteStat {
  value: string;
  label: string;
}

export interface Site {
  name: string;
  url: string;
  img: string;
  tag: string;
  text: string;
  stats?: SiteStat[];
  statsNote?: string;
}

export const sites: Site[] = [
  {
    name: 'ogarnijegzamin.pl',
    url: 'https://ogarnijegzamin.pl/',
    img: '/web/ogarnijegzamin',
    tag: 'Projekt własny · aplikacja webowa',
    text: 'Platforma do nauki do egzaminów zawodowych: baza pytań z omówieniami, arkusze CKE i symulatory egzaminu praktycznego. Projekt, wykonanie i SEO.',
    stats: [
      { value: '~3,8 tys.', label: 'odwiedzających dziennie' },
      { value: '777', label: 'zarejestrowanych użytkowników' },
      { value: '906 tys.+', label: 'rozwiązanych pytań' },
    ],
    statsNote: 'Odwiedzający: Cloudflare Analytics, czerwiec 2026. Użytkownicy i pytania: panel strony, październik 2026.',
  },
  {
    name: 'jankobus.com',
    url: 'https://jankobus.com/',
    img: '/web/jankobus',
    tag: 'Strona-wizytówka',
    text: 'Strona, na której jesteś. Szybka strona statyczna, hosting na Cloudflare, dane strukturalne dla Google i podgląd linku pod Facebooka i Messengera.',
  },
];
