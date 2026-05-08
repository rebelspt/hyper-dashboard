// Automatically prefixes relative HTMX request paths with the value of the
// closest ancestor's `data-hx-base` attribute.  This lets API-widget templates
// use relative URLs (e.g. `hx-get="type/electric"`) that resolve to the
// widget's own route space (`/widget/<id>/type/electric`).

document.addEventListener('htmx:configRequest', function(evt) {
  const baseEl = evt.detail.elt.closest('[data-hx-base]');
  if (!baseEl) return;
  const base = baseEl.getAttribute('data-hx-base');
  const path = evt.detail.path;
  if (base && path != null && !path.startsWith('/') && !path.startsWith('http')) {
    evt.detail.path = base + path;
  }
});
