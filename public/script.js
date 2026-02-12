document.addEventListener('DOMContentLoaded', () => {
    initLightbox();
    initLinkPrefetch();
    initSmartNav();
    disableDevTools();
});

/* --- OCHRONA PRZED DEVTOOLS --- */
function disableDevTools() {
    // Blokada prawego przycisku myszy
    document.addEventListener('contextmenu', e => e.preventDefault());
    
    // Blokada skrótów klawiszowych
    document.addEventListener('keydown', e => {
        // F12
        if (e.key === 'F12') {
            e.preventDefault();
            return false;
        }
        // Ctrl+Shift+I / Cmd+Option+I
        if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'I') {
            e.preventDefault();
            return false;
        }
        // Ctrl+Shift+J / Cmd+Option+J
        if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'J') {
            e.preventDefault();
            return false;
        }
        // Ctrl+Shift+C / Cmd+Option+C
        if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'C') {
            e.preventDefault();
            return false;
        }
        // Ctrl+U / Cmd+U (źródło strony)
        if ((e.ctrlKey || e.metaKey) && e.key === 'u') {
            e.preventDefault();
            return false;
        }
    });
}

/* --- 1. GALERIA (GENEROWANIE) --- */
function loadGallery(config) {
    const galleryContainer = document.getElementById(config.containerId || 'moja-galeria');
    if (!galleryContainer) return;

    // Koduj spacje na %20 aby obsłużyć foldery ze spacjami i polskimi znakami
    const folder = config.folder.replace(/ /g, '%20');
    const count = config.count;
    const extension = config.extension || '.jpg';
    const prefix = config.prefix || 'foto'; 
    const start = config.start || 1;

    for (let i = 1; i <= count; i++) {
        const div = document.createElement('div');
        div.className = 'masonry-item'; 

        const picture = document.createElement('picture');
        const img = document.createElement('img');
        const fileIndex = start + i - 1;
        const fileName = `${prefix} (${fileIndex})${extension}`;
        const basePath = `${folder}${prefix} (${fileIndex})`;

        // WebP source (lepsze kompresji) - z responsywnym srcset
        const webpSource = document.createElement('source');
        const isSmallScreen = window.innerWidth < 768;
        if (isSmallScreen) {
            webpSource.srcset = `${folder}thumbs/${prefix} (${fileIndex}).webp 300w`;
        } else {
            webpSource.srcset = `${folder}thumbs/${prefix} (${fileIndex}).webp 300w, ${basePath}.webp 1200w`;
        }
        webpSource.type = 'image/webp';

        // Fallback JPEG
        img.src = `${basePath}.jpg`;
        
        // Responsive srcset dla thumbnails i pełnych wersji (JPEG fallback)
        if (isSmallScreen) {
            img.srcset = `${folder}thumbs/${prefix} (${fileIndex}).jpg 300w`;
        } else {
            img.srcset = `${folder}thumbs/${prefix} (${fileIndex}).jpg 300w, ${basePath}.jpg 1200w`;
        }
        
        // SEO-friendly alt
        let altText = config.altTemplate || 'Fotografia eventowa Lubliniec';
        img.alt = `${altText} - zdjęcie ${fileIndex}`;
        img.dataset.index = i;

        // Lazy loading (eager tylko dla pierwszych 3)
        if (i <= 3) {
            img.loading = 'eager';
            if (i <= 2) {
                img.fetchPriority = 'high';
            }
        } else {
            img.loading = 'lazy';
        }
        img.decoding = 'async';

        img.onclick = () => openLightbox(folder, prefix, fileIndex, count, extension, start);

        img.onerror = function() { 
            console.warn('Nie znaleziono pliku:', this.src); 
            div.style.display = 'none'; 
        };

        picture.appendChild(webpSource);
        picture.appendChild(img);
        div.appendChild(picture);
        galleryContainer.appendChild(div);
    }
}

/* --- 2. LIGHTBOX (PEŁNY EKRAN) --- */
let currentImageIndex = 1;
let currentConfig = {};

function initLightbox() {
    if (!document.getElementById('lightbox')) {
        const lightboxHTML = `
            <div id="lightbox" class="lightbox">
                <span class="close">&times;</span>
                <div class="lightbox-content">
                    <img id="lightbox-img" src="" alt="">
                    <a class="prev" onclick="changeSlide(-1)">&#10094;</a>
                    <a class="next" onclick="changeSlide(1)">&#10095;</a>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', lightboxHTML);

        document.querySelector('.close').onclick = closeLightbox;
        document.getElementById('lightbox').onclick = (e) => {
            if(e.target.id === 'lightbox') closeLightbox();
        };

        document.addEventListener('keydown', (e) => {
            if (document.getElementById('lightbox').style.display === 'flex') {
                if (e.key === 'Escape') closeLightbox();
                if (e.key === 'ArrowLeft') changeSlide(-1);
                if (e.key === 'ArrowRight') changeSlide(1);
            }
        });
    }
}

function openLightbox(folder, prefix, index, total, extension, start = 1, images = null) {
    const lightbox = document.getElementById('lightbox');

    currentConfig = { folder, prefix, total, extension, start, images };
    currentImageIndex = index;

    updateLightboxImage();
    lightbox.style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

function closeLightbox() {
    document.getElementById('lightbox').style.display = 'none';
    document.body.style.overflow = 'auto';
}

function changeSlide(n) {
    const { images, start = 1, total = 1 } = currentConfig;
    
    if (images && images.length > 0) {
        // Nowy format: tablica zdjęć
        currentImageIndex += n;
        if (currentImageIndex > images.length) currentImageIndex = 1;
        if (currentImageIndex < 1) currentImageIndex = images.length;
    } else {
        // Stary format: numeracja zdjęć
        const end = start + total - 1;
        currentImageIndex += n;
        if (currentImageIndex > end) currentImageIndex = start;
        if (currentImageIndex < start) currentImageIndex = end;
    }
    updateLightboxImage();
}

function updateLightboxImage() {
    const img = document.getElementById('lightbox-img');
    const { folder, prefix, extension, images } = currentConfig;
    
    if (images && images.length > 0) {
        // Nowy format: tablica zdjęć z bezpośrednimi nazwami
        img.src = `${folder}${images[currentImageIndex - 1]}`;
    } else {
        // Stary format: prefix + numer w nawiasach
        img.src = `${folder}${prefix} (${currentImageIndex})${extension}`;
    }
}



/* --- 4. NAWIGACJA (SMART NAV & PREFETCH) --- */
function initSmartNav() {
    const nav = document.querySelector('nav');
    if (!nav) return;
    
    let lastScrollY = window.scrollY;

    window.addEventListener('scroll', () => {
        const currentScrollY = window.scrollY;
        if (currentScrollY > 50) {
            nav.classList.add('nav-scrolled');
        } else {
            nav.classList.remove('nav-scrolled');
        }
        lastScrollY = currentScrollY;
    });
}

function initLinkPrefetch() {
    const links = document.querySelectorAll('a');
    
    links.forEach(link => {
        link.addEventListener('mouseenter', function() {
            const url = this.getAttribute('href');
            if (!url || url.startsWith('http') || url.startsWith('#')) return;
            if (document.head.querySelector(`link[href="${url}"]`)) return;

            const prefetchLink = document.createElement('link');
            prefetchLink.rel = 'prefetch';
            prefetchLink.href = url;
            document.head.appendChild(prefetchLink);
        });
    });
}
