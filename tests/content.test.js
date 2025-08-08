/** @jest-environment jsdom */
const path = require('path');

describe('content script', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
    jest.resetModules();
  });

  it('injects a banner into the page', () => {
    require(path.join('..', 'src', 'content.js'));
    const banner = document.getElementById('super-h-banner');
    expect(banner).not.toBeNull();
    expect(banner.textContent).toBe('Super H active');
  });
});
