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

document.getElementById('show-language-demo').addEventListener('click', function() {
    const demo = document.getElementById('language-demo');
    demo.classList.toggle('hidden');
    if (!demo.classList.contains('hidden')) {
        const list = document.getElementById('proto-words-list');
        list.innerHTML = '';
        protoWords.forEach(item => {
            const li = document.createElement('li');
            li.innerHTML = `<strong>${item.concept}:</strong> <span class="tribal-word">${item.word}</span>`;
            list.appendChild(li);
        });
    }
});

// Section fade-in on scroll
const sections = document.querySelectorAll('section');
function revealSections() {
  const trigger = window.innerHeight * 0.85;
  sections.forEach(sec => {
    const rect = sec.getBoundingClientRect();
    if (rect.top < trigger) sec.classList.add('visible');
  });
}
window.addEventListener('scroll', revealSections);
window.addEventListener('DOMContentLoaded', () => {
  // Animate hero text
  document.querySelector('#hero h2').style.animationPlayState = 'running';
  document.querySelector('#hero .elevator-pitch').style.animationPlayState = 'running';
  revealSections();
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

// Patch language demo to use fire icon
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
