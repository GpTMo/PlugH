import './style.css';

// Super H content script
(() => {
  const container = document.createElement('div');
  container.id = 'super-h-banner';
  container.textContent = 'Super H active';
  document.body.appendChild(container);
})();
