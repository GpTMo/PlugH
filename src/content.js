// Super H content script
(function() {
  const container = document.createElement('div');
  container.id = 'super-h-banner';
  container.style.position = 'fixed';
  container.style.top = '10px';
  container.style.right = '10px';
  container.style.zIndex = '9999';
  container.style.background = '#ffeb3b';
  container.style.color = '#000';
  container.style.padding = '4px 8px';
  container.style.borderRadius = '4px';
  container.style.fontSize = '12px';
  container.textContent = 'Super H active';
  document.body.appendChild(container);
})();
