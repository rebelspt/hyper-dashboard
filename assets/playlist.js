// Minibar callbacks stored outside classes to avoid proxy / reactivity issues.
const _minibarCb = new Map();

// ── MediaMinibar ─────────────────────────────────────────────────────────────
class MediaMinibar extends HTMLElement {
  #items = [];
  #container = null;

  connectedCallback() {
    const shadow = this.attachShadow({ mode: 'open' });
    shadow.innerHTML = `
      <style>
        :host { display: block; }
        .container {
          position: fixed; bottom: 1.5rem; left: 1.5rem; z-index: 150;
          display: flex; flex-direction: column; gap: 0.5rem; max-width: 280px;
        }
        .minibar-item {
          display: flex; align-items: center; gap: 0.5rem;
          padding: 0.35rem 0.5rem 0.35rem 0.35rem;
          background: var(--surface); border: 1px solid var(--border);
          border-radius: 2rem; cursor: pointer; color: var(--text);
          box-shadow: 0 4px 16px rgba(0,0,0,0.3); transition: background 0.15s;
        }
        .minibar-item:hover { background: var(--bg); }
        .minibar-thumb { width: 2rem; height: 2rem; border-radius: 1rem; object-fit: cover; flex-shrink: 0; }
        .minibar-label { font-size: 0.82rem; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .minibar-dismiss {
          flex-shrink: 0; background: none; border: none; color: var(--text-muted);
          cursor: pointer; font-size: 1rem; line-height: 1; padding: 0 0.2rem;
        }
        .minibar-dismiss:hover { color: var(--text); }
      </style>
      <div class="container"></div>
    `;
    this.#container = shadow.querySelector('.container');
    this.#render();
  }

  #render() {
    if (!this.#container) return;
    this.#container.innerHTML = this.#items.map(item => `
      <div class="minibar-item" data-id="${this.#esc(item.id)}" title="${this.#esc(item.label)}">
        ${item.thumb ? `<img class="minibar-thumb" src="${this.#esc(item.thumb)}" alt="">` : ''}
        <span class="minibar-label">${this.#esc(item.label)}</span>
        <button class="minibar-dismiss" data-id="${this.#esc(item.id)}" title="Dismiss">&times;</button>
      </div>
    `).join('');

    this.#container.querySelectorAll('.minibar-item').forEach(el => {
      const id = el.dataset.id;
      el.addEventListener('click', () => this.#resume(id));
    });
    this.#container.querySelectorAll('.minibar-dismiss').forEach(btn => {
      btn.addEventListener('click', e => { e.stopPropagation(); this.#dismiss(btn.dataset.id); });
    });
  }

  #esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  addItem({ id, label, thumb, onResume, onDismiss }) {
    _minibarCb.set(id, { onResume, onDismiss });
    const entry = { id, label, thumb: thumb || '' };
    const idx = this.#items.findIndex(i => i.id === id);
    if (idx !== -1) this.#items[idx] = entry;
    else this.#items.push(entry);
    this.#render();
  }

  removeItem(id) {
    this.#items = this.#items.filter(i => i.id !== id);
    _minibarCb.delete(id);
    this.#render();
  }

  #resume(id) {
    const fn = _minibarCb.get(id)?.onResume;
    if (fn) fn();
    this.removeItem(id);
  }

  #dismiss(id) {
    const fn = _minibarCb.get(id)?.onDismiss;
    if (fn) fn();
    this.removeItem(id);
  }
}

customElements.define('media-minibar', MediaMinibar);

// ── MediaPlayer ───────────────────────────────────────────────────────────────
class MediaPlayer extends HTMLElement {
  #items = JSON.parse(localStorage.getItem('yt-queue') || '[]');
  #current = (() => {
    const c = parseInt(localStorage.getItem('yt-current') || '-1');
    const len = JSON.parse(localStorage.getItem('yt-queue') || '[]').length;
    return Math.min(c, len - 1);
  })();
  #visible = localStorage.getItem('yt-visible') === 'true';
  #w = parseInt(localStorage.getItem('yt-w') || '360');
  #h = parseInt(localStorage.getItem('yt-h') || '0') || null;
  #tx = parseFloat(localStorage.getItem('yt-tx') || '0');
  #ty = parseFloat(localStorage.getItem('yt-ty') || '0');

  #dragging = false; #dx = 0; #dy = 0; #tx0 = 0; #ty0 = 0;
  #resizing = false; #sx = 0; #sy = 0; #sw = 0; #sh = 0;

  #boundMove; #boundUp; #boundQueue;

  static #CSS = `
    :host { display: block; }
    .wrap {
      position: fixed; bottom: 1.5rem; right: 1.5rem; z-index: 200;
      min-width: 280px; min-height: 180px; max-height: 90vh;
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius); box-shadow: 0 8px 32px rgba(0,0,0,0.4);
      display: flex; flex-direction: column;
    }
    .resize-handle {
      position: absolute; top: 0; left: 0; width: 20px; height: 20px;
      cursor: nwse-resize; z-index: 1;
    }
    .resize-handle::after {
      content: ''; position: absolute; top: 5px; left: 5px;
      width: 8px; height: 8px;
      border-top: 2px solid var(--border); border-left: 2px solid var(--border);
      border-radius: 1px; transition: border-color 0.15s;
    }
    .resize-handle:hover::after { border-color: var(--accent); }
    .header {
      display: flex; align-items: center; justify-content: space-between;
      padding: 0.5rem 0.75rem; border-bottom: 1px solid var(--border); flex-shrink: 0;
      cursor: move; user-select: none;
    }
    .title { font-size: 0.75rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
    .actions { display: flex; align-items: center; gap: 0.1rem; }
    .btn-minimize, .btn-close {
      background: none; border: none; color: var(--text-muted);
      cursor: pointer; font-size: 1.25rem; line-height: 1; padding: 0 0.25rem;
    }
    .btn-minimize:hover, .btn-close:hover { color: var(--text); }
    .frame-wrap { position: relative; width: 100%; aspect-ratio: 16/9; flex-shrink: 0; }
    .frame { width: 100%; height: 100%; border: none; display: block; }
    .audio { width: 100%; display: block; padding: 0.75rem; background: var(--bg); border: none; box-sizing: border-box; }
    .playlist { overflow-y: auto; flex: 1; }
    .playlist-item {
      display: flex; align-items: center; gap: 0.6rem;
      padding: 0.6rem 0.75rem; cursor: pointer; border-bottom: 1px solid var(--border);
    }
    .playlist-item:hover, .playlist-item--active { background: var(--bg); }
    .playlist-thumb { width: 90px; height: 51px; object-fit: cover; border-radius: 3px; flex-shrink: 0; }
    .playlist-title {
      font-size: 0.85rem; flex: 1; overflow: hidden;
      display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
    }
    .playlist-remove { background: none; border: none; color: var(--text-muted); cursor: pointer; font-size: 0.9rem; flex-shrink: 0; }
    .playlist-remove:hover { color: var(--accent); }
    .drag-handle { color: var(--text-muted); cursor: grab; font-size: 1rem; padding: 0 0.25rem; flex-shrink: 0; user-select: none; }
    .drag-handle:active { cursor: grabbing; }
    .playlist-item[draggable='true'] { cursor: default; }
  `;

  connectedCallback() {
    const shadow = this.attachShadow({ mode: 'open' });
    shadow.innerHTML = `
      <style>${MediaPlayer.#CSS}</style>
      <div class="wrap">
        <div class="resize-handle" title="Drag to resize"></div>
        <div class="header">
          <span class="title">Queue</span>
          <div class="actions">
            <button class="btn-minimize" title="Minimize">&minus;</button>
            <button class="btn-close" title="Close">&times;</button>
          </div>
        </div>
        <div class="frame-wrap">
          <iframe class="frame"
            allow="autoplay; encrypted-media; picture-in-picture"
            allowfullscreen
            referrerpolicy="strict-origin-when-cross-origin"></iframe>
          <audio class="audio" controls></audio>
        </div>
        <div class="playlist"></div>
      </div>
    `;

    this.#applyVisibility();
    this.#applyStyle();
    this.#renderPlaylist();
    this.#updateMedia();

    shadow.querySelector('.btn-minimize').addEventListener('click', () => this.minimize());
    shadow.querySelector('.btn-close').addEventListener('click', () => this.close());

    shadow.querySelector('.resize-handle').addEventListener('mousedown', e => {
      e.preventDefault();
      this.#resizing = true;
      this.#sx = e.clientX; this.#sy = e.clientY;
      this.#sw = this.#w;
      this.#sh = shadow.querySelector('.wrap').offsetHeight;
    });

    shadow.querySelector('.header').addEventListener('mousedown', e => {
      e.preventDefault();
      this.#dragging = true;
      this.#dx = e.clientX; this.#dy = e.clientY;
      this.#tx0 = this.#tx; this.#ty0 = this.#ty;
    });

    this.#boundMove = this.#onMouseMove.bind(this);
    this.#boundUp   = this.#onMouseUp.bind(this);
    this.#boundQueue = this.#onQueue.bind(this);
    window.addEventListener('mousemove', this.#boundMove);
    window.addEventListener('mouseup',   this.#boundUp);
    document.addEventListener('media:queue', this.#boundQueue);
  }

  disconnectedCallback() {
    window.removeEventListener('mousemove', this.#boundMove);
    window.removeEventListener('mouseup',   this.#boundUp);
    document.removeEventListener('media:queue', this.#boundQueue);
  }

  #renderPlaylist() {
    const list = this.shadowRoot.querySelector('.playlist');
    if (!list) return;
    list.innerHTML = this.#items.map((item, i) => `
      <div class="playlist-item${i === this.#current ? ' playlist-item--active' : ''}"
           data-index="${i}" draggable="true">
        <div class="drag-handle">&#x2807;</div>
        <img class="playlist-thumb" src="${this.#esc(item.thumb)}" alt="">
        <span class="playlist-title">${this.#esc(item.title)}</span>
        <button class="playlist-remove" data-index="${i}" title="Remove">&times;</button>
      </div>
    `).join('');

    list.querySelectorAll('.playlist-item').forEach(row => {
      const i = parseInt(row.dataset.index);
      row.addEventListener('click', () => this.play(i));
      row.addEventListener('dragstart', e => {
        e.dataTransfer.setData('text/plain', String(i));
        e.dataTransfer.effectAllowed = 'move';
      });
      row.addEventListener('dragover', e => {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
      });
      row.addEventListener('drop', e => {
        e.preventDefault();
        this.reorder(parseInt(e.dataTransfer.getData('text/plain')), i);
      });
    });
    list.querySelectorAll('.playlist-remove').forEach(btn => {
      btn.addEventListener('click', e => {
        e.stopPropagation();
        this.remove(parseInt(btn.dataset.index));
      });
    });
  }

  #updateMedia() {
    const iframe = this.shadowRoot?.querySelector('.frame');
    const audio  = this.shadowRoot?.querySelector('.audio');
    if (!iframe || !audio) return;
    const item = this.#items[this.#current];

    if (item?.type === 'youtube') {
      iframe.style.display = 'block';
      audio.style.display  = 'none';
      const url = `https://www.youtube.com/embed/${item.id}?autoplay=1`;
      if (iframe.src !== url) iframe.src = url;
      audio.pause(); audio.src = '';
    } else if (item?.type === 'audio') {
      iframe.style.display = 'none';
      audio.style.display  = 'block';
      if (audio.src !== item.url) { audio.src = item.url; audio.load(); audio.play().catch(() => {}); }
      if (iframe.src) iframe.src = '';
    } else {
      iframe.style.display = 'none';
      audio.style.display  = 'none';
      if (iframe.src) iframe.src = '';
      audio.pause(); audio.src = '';
    }
  }

  #applyStyle() {
    const wrap = this.shadowRoot?.querySelector('.wrap');
    if (!wrap) return;
    wrap.style.width = this.#w + 'px';
    wrap.style.transform = `translate(${this.#tx}px,${this.#ty}px)`;
    wrap.style.height = this.#h ? this.#h + 'px' : '';
  }

  #applyVisibility() {
    const wrap = this.shadowRoot?.querySelector('.wrap');
    if (!wrap) return;
    wrap.style.display = this.#visible ? 'flex' : 'none';
  }

  #persist() {
    localStorage.setItem('yt-queue',   JSON.stringify(this.#items));
    localStorage.setItem('yt-current', String(this.#current));
    localStorage.setItem('yt-visible', String(this.#visible));
  }

  #getMinibar() {
    return document.querySelector('media-minibar');
  }

  #onQueue(e) { this.add(e.detail); }

  static queue(video) {
    document.querySelector('media-player')?.add(video);
  }

  #onMouseMove(e) {
    if (this.#resizing) {
      this.#w = Math.max(280, this.#sw - (e.clientX - this.#sx));
      this.#h = Math.max(180, this.#sh - (e.clientY - this.#sy));
      this.#applyStyle();
    }
    if (this.#dragging) {
      this.#tx = this.#tx0 + (e.clientX - this.#dx);
      this.#ty = this.#ty0 + (e.clientY - this.#dy);
      this.#applyStyle();
    }
  }

  #onMouseUp() {
    if (this.#resizing) {
      this.#resizing = false;
      localStorage.setItem('yt-w', this.#w);
      localStorage.setItem('yt-h', this.#h || '');
    }
    if (this.#dragging) {
      this.#dragging = false;
      localStorage.setItem('yt-tx', this.#tx);
      localStorage.setItem('yt-ty', this.#ty);
    }
  }

  #esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  add(video) {
    const same = (a, b) => a.type === b.type && (a.type === 'audio' ? a.url === b.url : a.id === b.id);
    const idx = this.#items.findIndex(v => same(v, video));
    if (idx === -1) { this.#items.push(video); if (this.#current === -1) this.#current = 0; }
    else { this.#current = idx; }
    this.#visible = true;
    this.#getMinibar()?.removeItem('playlist');
    this.#persist();
    this.#renderPlaylist();
    this.#updateMedia();
    this.#applyVisibility();
  }

  play(i) {
    this.#current = i;
    localStorage.setItem('yt-current', i);
    this.#renderPlaylist();
    this.#updateMedia();
  }

  remove(i) {
    this.#items.splice(i, 1);
    if (this.#current >= this.#items.length) this.#current = this.#items.length - 1;
    if (this.#items.length === 0) this.#visible = false;
    this.#persist();
    this.#renderPlaylist();
    this.#updateMedia();
    this.#applyVisibility();
  }

  reorder(from, to) {
    if (from === to || from < 0 || to < 0) return;
    const item = this.#items.splice(from, 1)[0];
    this.#items.splice(to, 0, item);
    if (this.#current === from) this.#current = to;
    else if (from < to && this.#current > from && this.#current <= to) this.#current--;
    else if (from > to && this.#current >= to && this.#current < from) this.#current++;
    this.#persist();
    this.#renderPlaylist();
  }

  minimize() {
    const item = this.#items[this.#current];
    this.#getMinibar()?.addItem({
      id: 'playlist',
      label: item ? item.title : 'Queue',
      thumb: item ? item.thumb : '',
      onResume: () => this.show(),
      onDismiss: () => this.close(),
    });
    this.#visible = false;
    localStorage.setItem('yt-visible', 'false');
    this.#applyVisibility();
  }

  show() {
    this.#visible = true;
    localStorage.setItem('yt-visible', 'true');
    this.#getMinibar()?.removeItem('playlist');
    this.#applyVisibility();
  }

  close() {
    this.#visible = false; this.#items = []; this.#current = -1;
    this.#getMinibar()?.removeItem('playlist');
    this.#persist();
    this.#renderPlaylist();
    this.#updateMedia();
    this.#applyVisibility();
  }
}

customElements.define('media-player', MediaPlayer);

