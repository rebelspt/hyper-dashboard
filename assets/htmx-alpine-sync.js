// Injects Alpine filter/tab state into every HTMX request so that
// auto-refresh and action buttons preserve the active panel.
document.addEventListener('alpine:init', () => {
  document.addEventListener('htmx:configRequest', function(evt) {
    const widget = evt.detail.elt.closest('.widget') || evt.detail.elt;
    widget.querySelectorAll('[data-htmx-sync]').forEach(function(el) {
      const param = el.getAttribute('data-htmx-sync');
      try {
        const data = Alpine.$data(el);
        if (data && param in data) {
          const url = new URL(evt.detail.path, location.href);
          url.searchParams.delete(param);
          evt.detail.path = url.pathname + url.search;
          evt.detail.parameters[param] = String(data[param]);
        }
      } catch (_) {}
    });
  });
});
