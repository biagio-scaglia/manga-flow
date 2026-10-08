/**
 * MANGAFLOW COMMERCIAL LANDING ENGINE
 * Author: Biagio Scaglia
 */

document.addEventListener('DOMContentLoaded', () => {
  // 1. THEME TOGGLE (Night Ink 墨色 vs Washi Paper 和紙)
  const themeToggleBtn = document.getElementById('theme-toggle');
  const themeText = document.querySelector('.theme-mode-text');
  const themeIcon = document.querySelector('.theme-icon-box');
  const htmlRoot = document.documentElement;

  const savedTheme = localStorage.getItem('mangaflow_theme') || 'dark';
  applyTheme(savedTheme);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const currentTheme = htmlRoot.getAttribute('data-theme') || 'dark';
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      applyTheme(newTheme);
      localStorage.setItem('mangaflow_theme', newTheme);
    });
  }

  function applyTheme(theme) {
    htmlRoot.setAttribute('data-theme', theme);
    if (theme === 'light') {
      if (themeText) themeText.textContent = 'WASHI PAPER';
      if (themeIcon) themeIcon.textContent = '紙';
    } else {
      if (themeText) themeText.textContent = 'NIGHT INK';
      if (themeIcon) themeIcon.textContent = '墨';
    }
  }

  // 2. HERO MOCKUP SCREEN TABS SWITCHER
  const mockTabs = document.querySelectorAll('.mock-tab');
  const mockPanels = document.querySelectorAll('.mock-screen-panel');

  mockTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const targetScreen = tab.getAttribute('data-mock-screen');
      mockTabs.forEach(t => t.classList.remove('active'));
      mockPanels.forEach(p => p.classList.remove('active'));

      tab.classList.add('active');
      const targetPanel = document.getElementById(`panel-${targetScreen}`);
      if (targetPanel) {
        targetPanel.classList.add('active');
      }
    });
  });

  // 3. INTERACTIVE LIVE TRACKER SANDBOX ENGINE
  let currentChapter = 140;
  const totalChapters = 232;
  let ownedVolumes = 16;
  const totalVolumes = 24;
  let isFavorite = false;

  const chRatioEl = document.getElementById('sb-ch-ratio');
  const chValEl = document.getElementById('sb-ch-val');
  const volRatioEl = document.getElementById('sb-vol-ratio');
  const volValEl = document.getElementById('sb-vol-val');
  const progressBarFill = document.getElementById('sb-progress-bar-fill');
  const pctBadge = document.getElementById('sb-pct-badge');
  const feedbackEl = document.getElementById('sb-feedback');

  const btnChMinus = document.getElementById('sb-ch-minus');
  const btnChPlus = document.getElementById('sb-ch-plus');
  const btnChJump = document.getElementById('sb-ch-jump');

  const btnVolMinus = document.getElementById('sb-vol-minus');
  const btnVolPlus = document.getElementById('sb-vol-plus');
  const btnVolAll = document.getElementById('sb-vol-all');

  const btnFav = document.getElementById('btn-toggle-fav');
  const favIcon = document.getElementById('fav-icon');
  const favLabel = document.getElementById('fav-label');

  const statusBtns = document.querySelectorAll('.sb-status-btn');

  function updateSandbox() {
    if (chValEl) chValEl.textContent = currentChapter;
    if (chRatioEl) chRatioEl.textContent = `${currentChapter} / ${totalChapters}`;
    if (volValEl) volValEl.textContent = ownedVolumes;
    if (volRatioEl) volRatioEl.textContent = `${ownedVolumes} / ${totalVolumes}`;

    const pct = ((currentChapter / totalChapters) * 100).toFixed(1);
    if (progressBarFill) progressBarFill.style.width = `${pct}%`;
    if (pctBadge) pctBadge.textContent = `${pct}% COMPLETATO`;

    if (feedbackEl) {
      if (ownedVolumes === totalVolumes && currentChapter === totalChapters) {
        feedbackEl.textContent = `COLLEZIONE & LETTURA COMPLETATE CON SUCCESSO!`;
        feedbackEl.style.color = 'var(--gold-accent)';
      } else if (ownedVolumes === totalVolumes) {
        feedbackEl.textContent = `TUTTI I VOLUMI CARTACEI POSSEDUTI (${totalVolumes}/${totalVolumes})`;
        feedbackEl.style.color = 'var(--gold-accent)';
      } else {
        feedbackEl.textContent = `INVARIANTE DI DOMINIO ATTIVA: Max ${totalVolumes} volumi`;
        feedbackEl.style.color = 'var(--text-muted)';
      }
    }
  }

  // Favorite toggle (Pure Editorial Badge)
  if (btnFav) {
    btnFav.addEventListener('click', () => {
      isFavorite = !isFavorite;
      btnFav.classList.toggle('active', isFavorite);
      if (favLabel) favLabel.textContent = isFavorite ? 'IN PREFERITI [ON]' : 'PREFERITI [OFF]';
    });
  }

  // Chapter buttons
  if (btnChMinus) {
    btnChMinus.addEventListener('click', () => {
      if (currentChapter > 0) {
        currentChapter--;
        updateSandbox();
      }
    });
  }

  if (btnChPlus) {
    btnChPlus.addEventListener('click', () => {
      if (currentChapter < totalChapters) {
        currentChapter++;
        updateSandbox();
      }
    });
  }

  if (btnChJump) {
    btnChJump.addEventListener('click', () => {
      currentChapter = Math.min(totalChapters, currentChapter + 10);
      updateSandbox();
    });
  }

  // Volume buttons with strict domain bounds (ownedVolumes <= totalVolumes)
  if (btnVolMinus) {
    btnVolMinus.addEventListener('click', () => {
      if (ownedVolumes > 0) {
        ownedVolumes--;
        updateSandbox();
      }
    });
  }

  if (btnVolPlus) {
    btnVolPlus.addEventListener('click', () => {
      if (ownedVolumes < totalVolumes) {
        ownedVolumes++;
        updateSandbox();
      } else {
        if (feedbackEl) {
          feedbackEl.textContent = `BLOCCO RIGIDO: Non puoi possedere più di ${totalVolumes} volumi!`;
          feedbackEl.style.color = 'var(--vermilion)';
        }
      }
    });
  }

  if (btnVolAll) {
    btnVolAll.addEventListener('click', () => {
      ownedVolumes = totalVolumes;
      updateSandbox();
    });
  }

  // Status buttons
  statusBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      statusBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const status = btn.getAttribute('data-sb-status');
      if (status === 'completed') {
        currentChapter = totalChapters;
        ownedVolumes = totalVolumes;
      } else if (status === 'plan') {
        currentChapter = 0;
      }
      updateSandbox();
    });
  });

  // 4. PHONE MOCKUP INTERACTIVE TOUCH STEPPER
  let phoneJujutsuChap = 236;
  const phoneJujutsuTotal = 271;
  const phoneStepperBtn = document.getElementById('phone-quick-stepper');
  const phoneChapLabel = document.getElementById('phone-chap-label');
  const phonePctLabel = document.getElementById('phone-pct-label');
  const phoneFillBar = document.getElementById('phone-fill-bar');

  if (phoneStepperBtn) {
    phoneStepperBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      if (phoneJujutsuChap < phoneJujutsuTotal) {
        phoneJujutsuChap++;
      } else {
        phoneJujutsuChap = 236; // Loop back for continuous demo delight
      }
      const pct = Math.round((phoneJujutsuChap / phoneJujutsuTotal) * 100);
      if (phoneChapLabel) phoneChapLabel.textContent = `CAP. ${phoneJujutsuChap} / ${phoneJujutsuTotal}`;
      if (phonePctLabel) phonePctLabel.textContent = `${pct}%`;
      if (phoneFillBar) phoneFillBar.style.width = `${pct}%`;

      phoneStepperBtn.style.transform = 'scale(0.88)';
      setTimeout(() => {
        phoneStepperBtn.style.transform = 'scale(1)';
      }, 120);
    });
  }

  // 5. FIRST-VISIT COOKIE & PRIVACY MODAL
  const COOKIE_CONSENT_KEY = 'mangaflow_cookie_consent';
  const hasConsent = localStorage.getItem(COOKIE_CONSENT_KEY);

  if (!hasConsent) {
    const modal = document.createElement('div');
    modal.id = 'cookie-consent-modal';
    modal.className = 'cookie-modal-overlay';
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-labelledby', 'cookie-modal-title');
    modal.setAttribute('aria-describedby', 'cookie-modal-desc');

    modal.innerHTML = `
      <div class="cookie-modal-card">
        <div class="cookie-modal-header">
          <div class="cookie-hanko-box" aria-hidden="true">MF</div>
          <div>
            <h3 id="cookie-modal-title" class="cookie-title">COOKIE &amp; MEMORIA LOCALE</h3>
            <span class="cookie-sub">INFORMATIVA PRIVACY • 墨</span>
          </div>
        </div>
        <p id="cookie-modal-desc" class="cookie-desc">
          MangaFlow non usa cookie di profilazione o traccianti pubblicitari. Usiamo solo <strong>memoria tecnica locale (localStorage)</strong> per salvare le tue preferenze visive di tema (Night Ink / Washi Paper) e i dati offline.
        </p>
        <div class="cookie-actions-row">
          <button id="btn-cookie-accept" class="btn-cookie-primary" type="button">ACCETTA TUTTO</button>
          <button id="btn-cookie-essential" class="btn-cookie-secondary" type="button">SOLO TECNICI</button>
          <a href="privacy.html" class="cookie-policy-link">Privacy Policy &rarr;</a>
        </div>
      </div>
    `;

    document.body.appendChild(modal);

    setTimeout(() => {
      modal.classList.add('visible');
    }, 450);

    const closeConsent = () => {
      localStorage.setItem(COOKIE_CONSENT_KEY, 'accepted');
      modal.classList.remove('visible');
      setTimeout(() => {
        if (modal.parentNode) {
          modal.parentNode.removeChild(modal);
        }
      }, 350);
    };

    const btnAccept = document.getElementById('btn-cookie-accept');
    const btnEssential = document.getElementById('btn-cookie-essential');

    if (btnAccept) btnAccept.addEventListener('click', closeConsent);
    if (btnEssential) btnEssential.addEventListener('click', closeConsent);
  }

  updateSandbox();
});
