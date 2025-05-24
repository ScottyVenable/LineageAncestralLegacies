// Language Demo: Generate example proto-words for core concepts
const protoWords = [
    { concept: 'MEAT', word: 'Gro' },
    { concept: 'BERRY', word: 'Kama' },
    { concept: 'WATER', word: 'Zul' },
    { concept: 'FIRE', word: 'Nak' },
    { concept: 'DANGER', word: 'Fep' },
    { concept: 'POP', word: 'See' },
    { concept: 'YES', word: 'Voo' },
    { concept: 'NO', word: 'Ril' }
];

// --- FIRE ICON FOR FIRE PROTO-WORD ---
const origRenderProtoWords = (list, protoWords) => {
  list.innerHTML = '';
  protoWords.forEach(item => {
    const li = document.createElement('li');
    if(item.concept === 'FIRE') {
      li.innerHTML = `<strong>${item.concept}:</strong> <span class="tribal-word">${item.word}<span class='fire-emoji'>🔥</span></span>`;
    } else {
      li.innerHTML = `<strong>${item.concept}:</strong> <span class="tribal-word">${item.word}</span>`;
    }
    list.appendChild(li);
  });
};

// Only add event listener if the element exists (prevents JS errors on pages without the demo button)
const showLangDemoBtn = document.getElementById('show-language-demo');
if (showLangDemoBtn) {
  showLangDemoBtn.addEventListener('click', function() {
    const demo = document.getElementById('language-demo');
    demo.classList.toggle('hidden');
    if (!demo.classList.contains('hidden')) {
      const list = document.getElementById('proto-words-list');
      origRenderProtoWords(list, protoWords);
    }
  });
}

// Section fade-in on scroll (robust: always reveal on load, even if later JS fails)
const sections = document.querySelectorAll('section');
function revealSections() {
  const trigger = window.innerHeight * 0.85;
  sections.forEach(sec => {
    const rect = sec.getBoundingClientRect();
    // Always add 'visible' on load, and toggle on scroll
    if (rect.top < trigger) sec.classList.add('visible');
    else sec.classList.remove('visible');
  });
}
window.addEventListener('scroll', revealSections);
window.addEventListener('DOMContentLoaded', () => {
  revealSections(); // Always reveal sections first
  // Animate hero text (guarded for missing elements)
  const heroH2 = document.querySelector('#hero h2');
  const heroPitch = document.querySelector('#hero .elevator-pitch');
  if(heroH2) heroH2.style.animationPlayState = 'running';
  if(heroPitch) heroPitch.style.animationPlayState = 'running';
});

// Smooth scroll for nav
Array.from(document.querySelectorAll('nav a')).forEach(link => {
  link.addEventListener('click', e => {
    const href = link.getAttribute('href');
    if (href.startsWith('#')) {
      e.preventDefault();
      document.querySelector(href).scrollIntoView({ behavior: 'smooth' });
    }
  });
});

// Back to top button
const backToTop = document.createElement('button');
backToTop.id = 'back-to-top';
backToTop.title = 'Back to top';
backToTop.innerHTML = '↑';
document.body.appendChild(backToTop);

window.addEventListener('scroll', () => {
  if (window.scrollY > 300) {
    backToTop.classList.add('visible');
  } else {
    backToTop.classList.remove('visible');
  }
});
backToTop.addEventListener('click', () => {
  window.scrollTo({ top: 0, behavior: 'smooth' });
});

// Navigation highlighting for multi-page site
// This script highlights the nav link for the current page, even when using .html files
const navLinks = document.querySelectorAll('nav a');
const current = window.location.pathname.split('/').pop() || 'index.html';
navLinks.forEach(link => {
    // For index.html, also highlight if href is just '' or '/'
    if (
        (current === 'index.html' && (link.getAttribute('href') === 'index.html' || link.getAttribute('href') === '' || link.getAttribute('href') === '/')) ||
        link.getAttribute('href') === current
    ) {
        link.classList.add('active');
    }
});

// --- CONTACT FORM SUBMISSION HANDLING ---
const contactForm = document.querySelector('.contact-form');
if (contactForm) {
  contactForm.addEventListener('submit', async function(e) {
    e.preventDefault();
    // Fade out the form
    contactForm.classList.add('fade-out');
    // After fade, show thank you message
    setTimeout(() => {
      contactForm.style.display = 'none';
      let thankYou = document.getElementById('contact-thankyou');
      if (!thankYou) {
        thankYou = document.createElement('div');
        thankYou.id = 'contact-thankyou';
        thankYou.innerHTML = '<h2>Thank you</h2><p>Your form has been submitted successfully.</p>';
        contactForm.parentNode.appendChild(thankYou);
      }
      thankYou.classList.add('visible');
    }, 600);

    // Send email via Formspree (or similar service)
    // NOTE: Replace 'YOUR_FORMSPREE_ENDPOINT' with your actual Formspree endpoint
    const formData = new FormData(contactForm);
    fetch('https://formspree.io/f/YOUR_FORMSPREE_ENDPOINT', {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json'
      }
    });
    // No need to await, UX is instant
  });
}
