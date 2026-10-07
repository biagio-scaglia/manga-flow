/**
 * MANGAFLOW LANDING PAGE INTERACTIVE ENGINE
 * Author: Biagio Scaglia
 */

document.addEventListener('DOMContentLoaded', () => {
  // 1. THEME SWITCHER (Night Ink vs Washi Paper)
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

  // 2. INTERACTIVE LIVE TRACKER DEMO
  let currentChapter = 140;
  const totalChapters = 232;
  let ownedVolumes = 16;
  const totalVolumes = 24;

  const chValEl = document.getElementById('ch-val');
  const chRatioEl = document.getElementById('chapter-ratio');
  const volValEl = document.getElementById('vol-val');
  const volRatioEl = document.getElementById('volume-ratio');
  const progressBarEl = document.getElementById('demo-progress-bar');
  const pctTextEl = document.getElementById('demo-pct-text');
  const feedbackEl = document.getElementById('demo-status-feedback');

  const btnChDec = document.getElementById('btn-ch-dec');
  const btnChInc = document.getElementById('btn-ch-inc');
  const btnChQuick = document.getElementById('btn-ch-quick');

  const btnVolDec = document.getElementById('btn-vol-dec');
  const btnVolInc = document.getElementById('btn-vol-inc');
  const btnVolMax = document.getElementById('btn-vol-max');

  const statusBtns = document.querySelectorAll('.status-btn');

  function updateTrackerUI() {
    if (chValEl) chValEl.textContent = currentChapter;
    if (chRatioEl) chRatioEl.textContent = `${currentChapter} / ${totalChapters}`;
    if (volValEl) volValEl.textContent = ownedVolumes;
    if (volRatioEl) volRatioEl.textContent = `${ownedVolumes} / ${totalVolumes}`;

    const pct = ((currentChapter / totalChapters) * 100).toFixed(1);
    if (progressBarEl) progressBarEl.style.width = `${pct}%`;
    if (pctTextEl) pctTextEl.textContent = `${pct}% COMPLETATO`;

    if (feedbackEl) {
      if (ownedVolumes === totalVolumes) {
        feedbackEl.textContent = `COLLEZIONE CARTACEA COMPLETA (${totalVolumes}/${totalVolumes} VOLUMI)`;
        feedbackEl.style.color = 'var(--gold-accent)';
      } else if (currentChapter === totalChapters) {
        feedbackEl.textContent = `LETTURA COMPLETATA (${totalChapters}/${totalChapters} CAPITOLI)`;
        feedbackEl.style.color = 'var(--gold-accent)';
      } else {
        feedbackEl.textContent = `INVARIANTE DI DOMINIO ATTIVA (MAX ${totalVolumes} VOLUMI)`;
        feedbackEl.style.color = 'var(--text-muted)';
      }
    }
  }

  // Chapter listeners
  if (btnChDec) {
    btnChDec.addEventListener('click', () => {
      if (currentChapter > 0) {
        currentChapter--;
        updateTrackerUI();
      }
    });
  }

  if (btnChInc) {
    btnChInc.addEventListener('click', () => {
      if (currentChapter < totalChapters) {
        currentChapter++;
        updateTrackerUI();
      }
    });
  }

  if (btnChQuick) {
    btnChQuick.addEventListener('click', () => {
      currentChapter = Math.min(totalChapters, currentChapter + 10);
      updateTrackerUI();
    });
  }

  // Volume listeners with Domain Invariant enforcement (ownedVolumes <= totalVolumes)
  if (btnVolDec) {
    btnVolDec.addEventListener('click', () => {
      if (ownedVolumes > 0) {
        ownedVolumes--;
        updateTrackerUI();
      }
    });
  }

  if (btnVolInc) {
    btnVolInc.addEventListener('click', () => {
      if (ownedVolumes < totalVolumes) {
        ownedVolumes++;
        updateTrackerUI();
      } else {
        if (feedbackEl) {
          feedbackEl.textContent = `BLOCCO: NON PUOI POSSEDERE PIÙ DI ${totalVolumes} VOLUMI!`;
          feedbackEl.style.color = 'var(--vermilion)';
        }
      }
    });
  }

  if (btnVolMax) {
    btnVolMax.addEventListener('click', () => {
      ownedVolumes = totalVolumes;
      updateTrackerUI();
    });
  }

  // Reading status switcher
  statusBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      statusBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const status = btn.getAttribute('data-status');
      if (status === 'completed') {
        currentChapter = totalChapters;
        ownedVolumes = totalVolumes;
      } else if (status === 'plan_to_read') {
        currentChapter = 0;
      }
      updateTrackerUI();
    });
  });

  updateTrackerUI();
});
