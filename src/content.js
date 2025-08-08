// Super H content script
(function() {
  const container = document.createElement('div');
  container.id = 'super-h-container';
  container.textContent = 'Super H active';

  const demoBtn = document.createElement('button');
  demoBtn.textContent = 'Prompt demo';
  demoBtn.title = 'Insérer un message de démonstration';
  demoBtn.addEventListener('click', () => {
    const textarea = document.querySelector('textarea');
    if (textarea) {
      textarea.value = 'Bonjour, ceci est une invite de démonstration Super H';
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      textarea.focus();
    }
  });
  container.appendChild(demoBtn);

  const closeBtn = document.createElement('button');
  closeBtn.textContent = '\u00D7';
  closeBtn.title = 'Fermer la bannière Super H';
  closeBtn.addEventListener('click', () => container.remove());
  container.appendChild(closeBtn);

  document.body.appendChild(container);
})();
