// Super H content script
(function() {
  const container = document.createElement('div');
  container.id = 'super-h-container';
  container.textContent = 'Super H active';

  const panel = document.createElement('div');
  panel.id = 'super-h-panel';
  const list = document.createElement('ul');
  const prompts = [
    { name: 'Résumé', text: 'Résume le texte suivant :' },
    { name: 'Traduction', text: 'Traduire en anglais :' },
    { name: 'Brainstorming', text: 'Propose trois idées sur :' }
  ];
  prompts.forEach(p => {
    const li = document.createElement('li');
    li.textContent = p.name;
    li.addEventListener('click', () => {
      const textarea = document.querySelector('textarea');
      if (textarea) {
        textarea.value = p.text;
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
        textarea.focus();
      }
      panel.style.display = 'none';
    });
    list.appendChild(li);
  });
  panel.appendChild(list);
  document.body.appendChild(panel);

  const promptBtn = document.createElement('button');
  promptBtn.textContent = 'Prompts';
  promptBtn.title = 'Afficher la liste des invites';
  promptBtn.addEventListener('click', () => {
    panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
  });
  container.appendChild(promptBtn);

  const closeBtn = document.createElement('button');
  closeBtn.textContent = '\u00D7';
  closeBtn.title = 'Fermer la bannière Super H';
  closeBtn.addEventListener('click', () => container.remove());
  container.appendChild(closeBtn);

  document.body.appendChild(container);
})();
