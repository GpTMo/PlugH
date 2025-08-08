// Super H content script
(function() {
  const container = document.createElement('div');
  container.id = 'super-h-container';
  container.textContent = 'Super H active';

  const closeBtn = document.createElement('button');
  closeBtn.textContent = '\u00D7';
  closeBtn.title = 'Close Super H banner';
  closeBtn.addEventListener('click', () => container.remove());
  container.appendChild(closeBtn);

  document.body.appendChild(container);
})();

