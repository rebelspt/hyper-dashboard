import '../config/models.dart';

class ThemeRenderer {
  static String toCss(ThemeConfig t) => '''
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg:         ${t.background};
  --surface:    ${t.surface};
  --border:     ${t.border};
  --text:       ${t.text};
  --text-muted: ${t.textMuted};
  --accent:     ${t.accent};
  --font:       ${t.font};
  --radius:     ${t.radius};
}

body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  font-size: 14px;
  line-height: 1.5;
  min-height: 100vh;
}

a { color: var(--accent); text-decoration: none; }
a:hover { text-decoration: underline; }

/* ── Header ── */
.header {
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  position: sticky; top: 0; z-index: 100;
}
.header-inner {
  max-width: 1600px; margin: 0 auto; padding: 0 1.5rem;
  display: flex; align-items: center; gap: 2rem; height: 3rem;
}
.header-logo { font-weight: 700; font-size: 1rem; color: var(--text); }

.nav-tabs {
  display: flex; gap: 0.25rem;
  overflow-x: auto;
  scrollbar-width: none;
  -ms-overflow-style: none;
  -webkit-overflow-scrolling: touch;
  flex: 1;
  mask-image: linear-gradient(to right, black 95%, transparent 100%);
  -webkit-mask-image: linear-gradient(to right, black 95%, transparent 100%);
}
.nav-tabs::-webkit-scrollbar { display: none; }
.nav-tab {
  color: var(--text-muted); padding: 0.35rem 0.75rem;
  border-radius: var(--radius); font-size: 0.875rem;
  transition: color 0.15s, background 0.15s;
  white-space: nowrap; flex-shrink: 0;
}
.nav-tab:hover { color: var(--text); background: rgba(255,255,255,0.05); text-decoration: none; }
.nav-tab--active { color: var(--text); background: rgba(255,255,255,0.08); }

@media (max-width: 640px) {
  .header-inner { padding: 0 1rem; gap: 1rem; }
  .header-logo { flex-shrink: 0; }
}

/* ── Layout ── */
.main { max-width: 1600px; margin: 0 auto; padding: 1.5rem; }
.columns { display: flex; gap: 1.5rem; align-items: flex-start; }

.column--small { width: 300px; flex-shrink: 0; }
.column--full  { flex: 1; min-width: 0; }

@media (max-width: 768px) {
  .main { padding: 1rem; }
  .columns { flex-direction: column; gap: 1rem; align-items: stretch; }
  .column--small, .column--full { width: 100%; }
  .widget { padding: 0.875rem; margin-bottom: 0.875rem; }
}

@media (max-width: 480px) {
  .main { padding: 0.75rem; }
  .columns { gap: 0.75rem; }
  .widget { padding: 0.75rem; margin-bottom: 0.75rem; }
  .widget-header { margin-bottom: 0.5rem; }
  
  /* Clock - smaller on phones */
  .clock-time { font-size: 2.5rem; }
  
  /* Feed grid - single column on small phones */
  .feed-grid { grid-template-columns: 1fr; }
  
  /* Smaller thumbnails on mobile */
  .feed-thumb { width: 60px; height: 40px; }
  .feed-media-thumb { width: 32px; height: 46px; }
}

/* ── Widget frame ── */
.widget {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 1rem;
  margin-bottom: 1rem;
  transition: opacity 0.2s;
}
.widget.htmx-request { opacity: 0.6; pointer-events: none; }

.widget-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 0.75rem;
}
.widget-title {
  font-size: 0.7rem; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.08em;
  color: var(--text-muted);
}
.widget-refresh {
  background: none; border: none; cursor: pointer;
  color: var(--text-muted); font-size: 1rem;
  padding: 0.1rem 0.3rem; border-radius: 4px;
  transition: color 0.15s, background 0.15s, transform 0.3s;
  line-height: 1;
}
.widget-refresh:hover { color: var(--text); background: rgba(255,255,255,0.05); }
.widget.htmx-request .widget-refresh { transform: rotate(360deg); }

.widget-error { color: #f7768e; font-size: 0.875rem; padding: 0.5rem 0; }
.widget-empty { color: var(--text-muted); font-size: 0.875rem; text-align: center; padding: 1.5rem 0; }

/* Skeleton loading */
.widget--loading .widget-body { display: flex; flex-direction: column; gap: 0.5rem; }
.widget-skeleton {
  height: 0.9rem; width: 100%;
  background: linear-gradient(90deg, var(--border) 25%, rgba(255,255,255,0.06) 50%, var(--border) 75%);
  background-size: 200% 100%; border-radius: 4px;
  animation: shimmer 1.4s infinite;
}
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }

/* ── Clock ── */
.clock { text-align: center; padding: 0.75rem 0; }
.clock-time {
  font-size: 3.5rem; font-weight: 700; letter-spacing: -0.03em;
  font-variant-numeric: tabular-nums; color: var(--text);
}
.clock-date { color: var(--text-muted); font-size: 0.9rem; margin-top: 0.35rem; }
.clock-list { display: flex; flex-direction: column; }
.clock-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0.45rem 0; border-bottom: 1px solid var(--border); font-size: 0.9rem;
}
.clock-row:last-child { border-bottom: none; padding-bottom: 0; }
.clock-row:first-child { padding-top: 0; }
.clock-row-label { color: var(--text-muted); }
.clock-row-time { font-variant-numeric: tabular-nums; font-weight: 600; color: var(--text); font-size: 1rem; }

/* ── Feed Items ── */

/* Containers */
.feed-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.feed-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 0.75rem; }

/* Article layout: plain text list — HackerNews, Lobsters */
.feed-item--article { border-bottom: 1px solid var(--border); padding: 0.6rem 0; }
.feed-item--article:first-child { padding-top: 0; }
.feed-item--article:last-child { border-bottom: none; padding-bottom: 0; }

/* Feed layout: optional left thumbnail — RSS, Reddit */
.feed-item--feed { display: flex; align-items: flex-start; gap: 0.6rem; border-bottom: 1px solid var(--border); padding: 0.6rem 0; }
.feed-item--feed:first-child { padding-top: 0; }
.feed-item--feed:last-child { border-bottom: none; padding-bottom: 0; }
.feed-thumb { width: 72px; height: 48px; object-fit: cover; border-radius: 4px; flex-shrink: 0; }

/* Card layout: 16:9 thumbnail top, entire card is a link — Videos */
.feed-item--card { position: relative; display: flex; flex-direction: column; border-radius: var(--radius); overflow: hidden; border: 1px solid var(--border); transition: border-color 0.15s; }
.feed-item--card:hover { border-color: var(--accent); text-decoration: none; }
.feed-card-thumb { width: 100%; aspect-ratio: 16/9; object-fit: cover; display: block; }
.feed-card-info { padding: 0.5rem; }

/* Media layout: portrait thumbnail left — Audiobookshelf */
.feed-item--media { display: flex; align-items: center; gap: 0.6rem; border-bottom: 1px solid var(--border); padding: 0.4rem 0; position: relative; }
.feed-item--media:first-child { padding-top: 0; }
.feed-item--media:last-child { border-bottom: none; padding-bottom: 0; }
.feed-media-thumb { width: 36px; height: 52px; object-fit: cover; border-radius: 3px; flex-shrink: 0; }

/* Shared content column */
.feed-content { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 0.15rem; }

/* Title — <a> for article/feed/media, <div> inside <a> for card */
.feed-title { font-size: 0.875rem; color: var(--text); line-height: 1.4; }
a.feed-title { display: block; }
a.feed-title:hover { color: var(--accent); text-decoration: none; }
.feed-item--card:hover .feed-title { color: var(--accent); }
.feed-item--card .feed-title { font-size: 0.8rem; line-height: 1.3; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.feed-item--media .feed-title { font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Subtitle */
.feed-subtitle { font-size: 0.75rem; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Meta row */
.feed-meta { display: flex; gap: 0.75rem; color: var(--text-muted); font-size: 0.75rem; margin-top: 0.2rem; flex-wrap: wrap; }
.feed-meta-link { color: var(--text-muted); }
.feed-meta-link:hover { color: var(--accent); }

/* Progress bar */
.feed-progress { height: 3px; background: var(--border); border-radius: 2px; overflow: hidden; margin-top: 0.25rem; }
.feed-progress-bar { height: 100%; background: var(--accent); border-radius: 2px; }

/* Thumbnail placeholder (missing or broken image) */
.feed-thumb--empty { background: var(--surface); flex-shrink: 0; display: flex; align-items: center; justify-content: center; }
.feed-thumb--empty::after {
  content: ''; width: 40%; height: 40%; opacity: 0.2;
  background-color: var(--text-muted);
  -webkit-mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M21 3H3C1.9 3 1 3.9 1 5v14c0 1.1.9 2 2 2h18c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H3V5h18v14zM8.5 13.5l2.5 3 3.5-4.5 4.5 6H5z'/%3E%3C/svg%3E") no-repeat center / contain;
  mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M21 3H3C1.9 3 1 3.9 1 5v14c0 1.1.9 2 2 2h18c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H3V5h18v14zM8.5 13.5l2.5 3 3.5-4.5 4.5 6H5z'/%3E%3C/svg%3E") no-repeat center / contain;
}

/* Alpine.js — hide cloaked elements until Alpine initialises */
[x-cloak] { display: none !important; }

/* ── Filter bar component ── */
.filter-bar { display: flex; gap: 0.25rem; margin-bottom: 0.5rem; flex-wrap: wrap; }
.filter-btn {
  background: none; border: 1px solid var(--border); border-radius: var(--radius);
  color: var(--text-muted); cursor: pointer; font-size: 0.75rem; font-family: var(--font);
  padding: 0.2rem 0.6rem; transition: color 0.15s, background 0.15s, border-color 0.15s;
}
.filter-btn:hover { color: var(--text); border-color: var(--text-muted); }
.filter-btn--active { color: var(--text); background: rgba(255,255,255,0.07); border-color: var(--accent); }
.filter-panel { display: flex; flex-direction: column; }

/* ── Tabs component ── */
.tabs { display: flex; flex-direction: column; }
.tabs-bar { display: flex; border-bottom: 1px solid var(--border); margin-bottom: 0.5rem; }
.tab-btn {
  background: none; border: none; border-bottom: 2px solid transparent;
  color: var(--text-muted); cursor: pointer; font-size: 0.8rem; font-family: var(--font);
  padding: 0.3rem 0.8rem; margin-bottom: -1px;
  transition: color 0.15s, border-color 0.15s;
}
.tab-btn:hover { color: var(--text); }
.tab-btn--active { color: var(--text); border-bottom-color: var(--accent); }
.tab-panel { display: flex; flex-direction: column; }

/* See more */
.feed-more-btn {
  display: block; width: 100%; margin-top: 0.5rem; padding: 0.35rem 0;
  background: none; border: 1px solid var(--border); border-radius: var(--radius);
  color: var(--text-muted); font-size: 0.75rem; cursor: pointer; transition: border-color 0.15s, color 0.15s;
}
.feed-more-btn:hover { border-color: var(--accent); color: var(--accent); }

/* ── YouTube Player ── */
.yt-add-btn {
  position: absolute; top: 0.4rem; right: 0.4rem;
  background: rgba(0,0,0,0.65); color: #fff; border: none; border-radius: 50%;
  width: 2rem; height: 2rem; cursor: pointer; font-size: 0.7rem;
  display: flex; align-items: center; justify-content: center;
  opacity: 0; transition: opacity 0.15s;
}
.feed-item--card:hover .yt-add-btn, .feed-item--media:hover .yt-add-btn { opacity: 1; }
/* ── Bookmarks ── */
.bookmark-group { margin-bottom: 1rem; }
.bookmark-group:last-child { margin-bottom: 0; }
.bookmark-group-name {
  font-size: 0.7rem; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.08em; color: var(--text-muted); margin-bottom: 0.4rem;
}
.bookmark-list { list-style: none; display: flex; flex-direction: column; gap: 0.1rem; }
.bookmark-item a {
  display: flex; align-items: center; gap: 0.5rem;
  color: var(--text); font-size: 0.875rem;
  padding: 0.3rem 0.5rem; border-radius: 6px;
  transition: background 0.15s;
}
.bookmark-item a:hover { background: rgba(255,255,255,0.05); text-decoration: none; }
.bookmark-icon { width: 14px; height: 14px; opacity: 0.75; filter: invert(1); }

/* ── Calendar ── */
.cal-nav {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 0.5rem;
}
.cal-nav-title { font-size: 0.8rem; font-weight: 600; }
.cal-nav-btn {
  background: none; border: none; cursor: pointer; color: var(--text);
  font-size: 1rem; padding: 0 0.3rem; opacity: 0.6; line-height: 1;
}
.cal-nav-btn:hover { opacity: 1; }
.cal-grid { display: grid; grid-template-columns: repeat(7,1fr); gap: 2px; }
.cal-day-name {
  text-align: center; font-size: 0.65rem; font-weight: 600;
  text-transform: uppercase; color: var(--text-muted); padding: 0.2rem 0;
}
.cal-day {
  font-size: 0.8rem; border-radius: 4px; color: var(--text);
  display: flex; align-items: center; justify-content: center; aspect-ratio: 1;
}
.cal-today { background: var(--accent); color: var(--bg); font-weight: 700; border-radius: 50%; }
.cal-other-month { color: var(--text-muted); opacity: 0.4; }

/* ── Search ── */
.search-widget { display: flex; flex-direction: column; gap: 0.75rem; }
.search-input {
  width: 100%; background: var(--bg); border: 1px solid var(--border);
  border-radius: var(--radius); color: var(--text); font-size: 0.9rem;
  padding: 0.5rem 0.75rem; outline: none; font-family: var(--font);
}
.search-input:focus { border-color: var(--accent); }
.search-engines { display: flex; flex-wrap: wrap; gap: 0.4rem; }
.search-engine-btn {
  font-size: 0.7rem; color: var(--text-muted); background: var(--bg);
  border: 1px solid var(--border); border-radius: 4px;
  padding: 0.2rem 0.6rem; cursor: pointer; transition: color 0.15s, border-color 0.15s, background 0.15s;
}
.search-engine-btn:hover {
  color: var(--accent); border-color: var(--accent);
}
.search-engine-btn--active {
  color: var(--accent); border-color: var(--accent); background: rgba(127,127,127,0.1);
}
.search-bangs { display: flex; flex-wrap: wrap; gap: 0.4rem; }
.search-bang {
  font-size: 0.7rem; color: var(--text-muted); background: var(--bg);
  border: 1px solid var(--border); border-radius: 4px;
  padding: 0.15rem 0.5rem; cursor: pointer; transition: color 0.15s, border-color 0.15s;
}
.search-bang:hover { color: var(--accent); border-color: var(--accent); text-decoration: none; }

/* ── Monitor ── */
.monitor-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.monitor-site {
  display: flex; align-items: center; gap: 0.6rem;
  border-bottom: 1px solid var(--border); padding: 0.5rem 0; font-size: 0.875rem;
}
.monitor-site:first-child { padding-top: 0; }
.monitor-site:last-child { border-bottom: none; padding-bottom: 0; }
.monitor-dot {
  width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
}
.monitor-dot--up   { background: #4ade80; box-shadow: 0 0 6px #4ade8066; }
.monitor-dot--down { background: #f87171; box-shadow: 0 0 6px #f8717166; }
.monitor-status { flex: 1; color: var(--text); }
.monitor-time  { color: var(--text-muted); font-size: 0.75rem; margin-left: auto; }


/* ── Weather ── */
.weather { display: flex; flex-direction: column; gap: 1rem; }
.weather-current { display: flex; align-items: center; gap: 0.75rem; }
.weather-icon { font-size: 2.5rem; line-height: 1; }
.weather-temp { font-size: 2.5rem; font-weight: 700; letter-spacing: -0.03em; }
.weather-details { display: flex; flex-direction: column; gap: 0.15rem; color: var(--text-muted); font-size: 0.8rem; }
.weather-forecast { display: flex; flex-direction: column; gap: 0.3rem; border-top: 1px solid var(--border); padding-top: 0.75rem; }
.weather-day { display: flex; align-items: center; gap: 0.5rem; font-size: 0.8rem; }
.weather-day--link { cursor: pointer; border-radius: 4px; padding: 0.1rem 0.2rem; margin: 0 -0.2rem; }
.weather-day--link:hover { background: rgba(255,255,255,0.05); }
.weather-day-name { width: 2.75rem; color: var(--text-muted); }
.weather-day-name--today { color: var(--accent); font-weight: 600; }
.weather-day-icon { font-size: 1rem; }
.weather-day-range { margin-left: auto; color: var(--text-muted); font-variant-numeric: tabular-nums; }
.weather-day-arrow { color: var(--text-muted); opacity: 0.4; font-size: 0.9rem; margin-left: 0.25rem; }
.weather-nav {
  display: flex; align-items: center; gap: 0.75rem;
  border-bottom: 1px solid var(--border); padding-bottom: 0.75rem; margin-bottom: 0.25rem;
}
.weather-nav-btn {
  background: none; border: none; cursor: pointer; color: var(--text);
  font-size: 1.1rem; padding: 0 0.2rem; opacity: 0.6; line-height: 1; flex-shrink: 0;
}
.weather-nav-btn:hover { opacity: 1; }
.weather-nav-title { display: flex; flex-direction: column; gap: 0.1rem; }
.weather-nav-title span:first-child { font-size: 0.85rem; font-weight: 600; }
.weather-nav-subtitle { font-size: 0.75rem; color: var(--text-muted); }
.weather-hours { display: flex; flex-direction: column; gap: 0.3rem; }
.weather-hour {
  display: flex; align-items: center; gap: 0.5rem; font-size: 0.8rem;
  padding: 0.15rem 0;
}
.weather-hour-time { width: 3rem; color: var(--text-muted); font-variant-numeric: tabular-nums; }
.weather-hour-icon { font-size: 1rem; }
.weather-hour-temp { width: 2.5rem; font-variant-numeric: tabular-nums; }
.weather-hour-precip { margin-left: auto; color: var(--text-muted); font-variant-numeric: tabular-nums; }

/* ── Markets ── */
.markets-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.markets-item {
  display: flex; align-items: center; gap: 0.6rem;
  border-bottom: 1px solid var(--border); padding: 0.45rem 0; font-size: 0.875rem;
}
.markets-item:first-child { padding-top: 0; }
.markets-item:last-child { border-bottom: none; padding-bottom: 0; }
.markets-name { flex: 1; color: var(--text); min-width: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.markets-spark { width: 80px; height: 32px; flex-shrink: 0; }
.markets-spark-svg { width: 100%; height: 100%; display: block; }
.markets-price { font-variant-numeric: tabular-nums; color: var(--text); flex-shrink: 0; }
.markets-change { font-size: 0.8rem; font-variant-numeric: tabular-nums; min-width: 4.5rem; text-align: right; flex-shrink: 0; }
.markets-change--pos { color: #4ade80; }
.markets-change--neg { color: #f87171; }

/* ── Releases ── */
.releases-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.releases-item { border-bottom: 1px solid var(--border); padding: 0.55rem 0; font-size: 0.875rem; }
.releases-item:first-child { padding-top: 0; }
.releases-item:last-child { border-bottom: none; padding-bottom: 0; }
.releases-repo { font-size: 0.7rem; color: var(--text-muted); }
.releases-tag { color: var(--accent); font-size: 0.875rem; }
.releases-date { float: right; color: var(--text-muted); font-size: 0.75rem; }

/* ── Repository ── */
.repo { display: flex; flex-direction: column; gap: 0.75rem; }
.repo-stats { display: flex; gap: 1rem; color: var(--text-muted); font-size: 0.8rem; }
.repo-desc { color: var(--text-muted); font-size: 0.8rem; }
.repo-section-title {
  font-size: 0.65rem; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.08em; color: var(--text-muted); margin-bottom: 0.35rem;
}
.repo-list { list-style: none; display: flex; flex-direction: column; gap: 0.25rem; }
.repo-list li { font-size: 0.8rem; color: var(--text); }
.repo-meta { color: var(--text-muted); font-size: 0.75rem; }

/* ── Group (tabs) ── */
.group-tabs { display: flex; gap: 0.25rem; margin-bottom: 0.75rem; flex-wrap: wrap; }
.group-tab {
  background: none; border: 1px solid var(--border); border-radius: var(--radius);
  color: var(--text-muted); cursor: pointer; font-size: 0.75rem; font-family: var(--font);
  padding: 0.25rem 0.75rem; transition: color 0.15s, background 0.15s, border-color 0.15s;
}
.group-tab:hover { color: var(--text); border-color: var(--text-muted); }
.group-tab--active { color: var(--text); background: rgba(255,255,255,0.07); border-color: var(--accent); }

/* ── Split column ── */
.split-col { display: grid; grid-template-columns: repeat(var(--split-cols, 2), 1fr); gap: 1rem; }
@media (max-width: 768px) { .split-col { grid-template-columns: 1fr; } }

/* ── Twitch ── */
.twitch-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.twitch-channel {
  display: flex; align-items: center; gap: 0.6rem;
  border-bottom: 1px solid var(--border); padding: 0.5rem 0;
}
.twitch-channel:first-child { padding-top: 0; }
.twitch-channel:last-child { border-bottom: none; padding-bottom: 0; }
.twitch-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; }
.twitch-info { flex: 1; min-width: 0; }
.twitch-name { color: var(--text); font-size: 0.875rem; font-weight: 500; }
.twitch-game { color: var(--text-muted); font-size: 0.75rem; }
.twitch-offline { font-style: italic; }
.twitch-viewers { font-size: 0.75rem; color: var(--text-muted); white-space: nowrap; }
.twitch-badge {
  font-size: 0.6rem; font-weight: 700; letter-spacing: 0.05em;
  padding: 0.1rem 0.4rem; border-radius: 3px;
}
.twitch-badge--live { background: #9147ff; color: #fff; }
.tgames-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.tgames-item {
  display: flex; align-items: center; gap: 0.6rem;
  border-bottom: 1px solid var(--border); padding: 0.4rem 0;
}
.tgames-item:first-child { padding-top: 0; }
.tgames-item:last-child { border-bottom: none; padding-bottom: 0; }
.tgames-art { width: 26px; height: 36px; object-fit: cover; border-radius: 3px; }
.tgames-name { flex: 1; font-size: 0.875rem; color: var(--text); }
.tgames-rank { font-size: 0.75rem; color: var(--text-muted); }

/* ── HTML / iframe ── */
.html-content { font-size: 0.875rem; }
.iframe-wrap { width: 100%; }

/* ── Docker ── */
.docker-list { list-style: none; display: flex; flex-direction: column; gap: 0; }
.docker-item {
  display: flex; align-items: center; gap: 0.6rem;
  border-bottom: 1px solid var(--border); padding: 0.5rem 0; font-size: 0.875rem;
}
.docker-item:first-child { padding-top: 0; }
.docker-item:last-child  { border-bottom: none; padding-bottom: 0; }

.docker-status { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.docker-status--running  { background: #4ade80; box-shadow: 0 0 6px #4ade8066; }
.docker-status--exited   { background: #565f89; }
.docker-status--paused   { background: #e0af68; box-shadow: 0 0 6px #e0af6866; }

.docker-info { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 0.1rem; }
.docker-name   { color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.docker-image  { font-size: 0.75rem; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.docker-uptime { font-size: 0.75rem; color: var(--text-muted); }

.docker-actions { display: flex; gap: 0.2rem; flex-shrink: 0; }
.docker-action-btn {
  background: none; border: 1px solid var(--border); border-radius: 4px;
  color: var(--text-muted); cursor: pointer; font-size: 0.7rem;
  padding: 0.15rem 0.4rem; transition: color 0.15s, border-color 0.15s, background 0.15s;
}
.docker-action-btn:hover { color: var(--text); border-color: var(--text-muted); background: rgba(255,255,255,0.05); }


/* ── Docker detail / logs ── */
.docker-item-btn {
  flex: 1; min-width: 0; display: flex; align-items: center; gap: 0.6rem;
  background: none; border: none; cursor: pointer; padding: 0; text-align: left;
  color: inherit;
}
.docker-item-btn:hover .docker-name { color: var(--accent); }

.docker-detail { display: flex; flex-direction: column; }
.docker-detail-header {
  display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem;
}
.docker-back-btn {
  background: none; border: 1px solid var(--border); border-radius: 4px;
  color: var(--text-muted); cursor: pointer; font-size: 0.75rem; font-family: var(--font);
  padding: 0.2rem 0.5rem; flex-shrink: 0;
  transition: color 0.15s, border-color 0.15s;
}
.docker-back-btn:hover { color: var(--text); border-color: var(--text-muted); }
.docker-detail-title {
  display: flex; align-items: center; gap: 0.4rem;
  font-size: 0.875rem; font-weight: 500; color: var(--text); flex: 1; min-width: 0;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}

.docker-log-view {
  overflow-y: auto; max-height: 320px;
  background: rgba(0,0,0,0.25); border-radius: var(--radius); padding: 0.5rem;
}
.docker-log-output {
  font-size: 0.7rem; line-height: 1.6; white-space: pre-wrap; word-break: break-all;
  color: var(--text-muted);
}

.docker-info-view { padding-top: 0.1rem; }
.docker-info-table { display: flex; flex-direction: column; gap: 0.45rem; font-size: 0.8rem; }
.docker-info-row { display: flex; gap: 0.6rem; align-items: baseline; }
.docker-info-label { color: var(--text-muted); flex-shrink: 0; width: 4.5rem; }
.docker-info-value { color: var(--text); word-break: break-all; white-space: pre-wrap; }
''';
}
