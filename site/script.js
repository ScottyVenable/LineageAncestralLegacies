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

// --- MOBILE NAVIGATION & LOGIN/ACCOUNT BUTTON LOGIC ---
window.addEventListener('DOMContentLoaded', () => {
  // Hamburger menu toggle for mobile nav (REMOVED: not used, prevents blank button)

  // Login/Account button logic
  const loginArea = document.getElementById('login-area');
  if (loginArea) {
    // Check for session (demo: use loggedIn, username, and role)
    const isLoggedIn = sessionStorage.getItem('loggedIn') === 'true';
    const username = sessionStorage.getItem('username') || 'User';
    const role = sessionStorage.getItem('role') || 'user';
    // Show/hide Admin Center nav link if admin
    const mainNav = document.getElementById('main-nav');
    let adminLink = document.getElementById('nav-admin');
    if (mainNav) {
      if (role === 'admin') {
        if (!adminLink) {
          adminLink = document.createElement('a');
          adminLink.href = 'admin.html';
          adminLink.id = 'nav-admin';
          adminLink.textContent = 'Admin Center';
          mainNav.appendChild(adminLink);
        }
      } else {
        if (adminLink) adminLink.remove();
      }
    }
    if (isLoggedIn) {
      // Show 'Welcome, Username!' above the Account button
      loginArea.innerHTML = `<div class="account-welcome-label" style="text-align:center; font-size:0.98em; color:#ffe7a0; font-weight:600; margin-bottom:0.1em;">Welcome, ${username}!</div><a href="#" class="nav-link account-nav-link" id="account-btn" style="padding:0.18em 0.85em; font-size:1em; color:#ffe7a0; font-weight:bold;">Account</a>`;
      // Add click event to redirect to account page
      const accountBtn = document.getElementById('account-btn');
      if (accountBtn) {
        accountBtn.addEventListener('click', function(e) {
          e.preventDefault();
          window.location.href = 'account.html';
        });
      }
    } else {
      loginArea.innerHTML = '<a href="login.html" class="nav-link" style="color:#ffe7a0;">Login</a>';
    }
  }
});

// --- ADMIN PAGE SCRIPT ---
// This script runs only on the admin.html page
if (window.location.pathname.endsWith('admin.html')) {
  // Session check (demo: admin only if logged in as admin)
  const isLoggedIn = sessionStorage.getItem('loggedIn') === 'true';
  const role = sessionStorage.getItem('role');
  if (!isLoggedIn || role !== 'admin') {
    // Redirect to home page if not admin
    window.location.href = 'index.html';
  }

  // --- ADMIN UI INTERACTIONS ---
  // Simplified: just a logout button that appears if logged in
  const adminPanel = document.getElementById('admin-panel');
  if (adminPanel) {
    const logoutBtn = document.createElement('button');
    logoutBtn.id = 'admin-logout';
    logoutBtn.textContent = 'Logout';
    logoutBtn.className = 'admin-button';
    adminPanel.appendChild(logoutBtn);

    logoutBtn.addEventListener('click', () => {
      // Clear session and redirect to login
      sessionStorage.clear();
      window.location.href = 'login.html';
    });
  }
}

// --- LOGIN PAGE SCRIPT ---
// This script runs only on the login.html page
if (window.location.pathname.endsWith('login.html')) {
  const loginForm = document.getElementById('login-form');
  if (loginForm) {
    loginForm.addEventListener('submit', function(e) {
      e.preventDefault();
      const formData = new FormData(loginForm);
      const username = formData.get('username');
      const password = formData.get('password');
      // Demo logic: accept any non-empty username/password
      if (username && password) {
        sessionStorage.setItem('loggedIn', 'true');
        sessionStorage.setItem('username', username);
        sessionStorage.setItem('role', 'user'); // Default role
        // Redirect to account page (or admin page if admin credentials were used)
        window.location.href = username === 'admin' && password === 'admin' ? 'admin.html' : 'account.html';
      } else {
        alert('Please enter a valid username and password.');
      }
    });
  }
}

// --- ACCOUNT PAGE SCRIPT ---
// This script runs only on the account.html page
if (window.location.pathname.endsWith('account.html')) {
  const accountInfo = document.getElementById('account-info');
  if (accountInfo) {
    const username = sessionStorage.getItem('username');
    const role = sessionStorage.getItem('role');
    accountInfo.innerHTML = `<h2>Account Information</h2><p><strong>Username:</strong> ${username}</p><p><strong>Role:</strong> ${role}</p>`;
  }

  // Order history table (demo data)
  const orderHistory = document.getElementById('order-history');
  if (orderHistory) {
    const demoOrders = [
      { id: 1, date: '2023-10-01', total: 29.99, status: 'Shipped' },
      { id: 2, date: '2023-09-15', total: 49.99, status: 'Processing' },
      { id: 3, date: '2023-08-20', total: 19.99, status: 'Delivered' }
    ];
    demoOrders.forEach(order => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${order.id}</td><td>${order.date}</td><td>$${order.total.toFixed(2)}</td><td>${order.status}</td>`;
      orderHistory.appendChild(tr);
    });
  }
}

// --- HEADER ENTRANCE ANIMATION ---
document.addEventListener('DOMContentLoaded', function() {
  // Animate header elements in with staggered effect for a modern, polished look
  const header = document.getElementById('header-animate');
  if (header) {
    // Start hidden, then trigger animation
    setTimeout(() => {
      header.classList.add('header-animate-in');
    }, 80); // Slight delay for effect
  }

  // Staggered nav button animation
  const nav = document.getElementById('main-nav');
  if (nav) {
    const navLinks = nav.querySelectorAll('.nav-entrance');
    // Spread the animation so the total duration is about 2 seconds for all buttons
    // (e.g., 7 buttons, so ~285ms per button)
    const totalDuration = 2000; // ms
    const perButtonDelay = navLinks.length > 1 ? Math.floor(totalDuration / (navLinks.length - 1)) : 0;
    navLinks.forEach((link, i) => {
      setTimeout(() => {
        link.classList.add('nav-entrance-in');
      }, 200 + i * perButtonDelay); // 200ms initial delay for polish
    });
  }

  // --- HERO TITLE: NO ANIMATION, STATIC TEXT ---
  // Instantly show all hero-anim-text spans on every load (no animation, no session check)
  ['hero-anim-1','hero-anim-2','hero-anim-3'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.classList.add('visible');
  });
});
