// Dashboard Clock Web Component
// Usage:
//   <hyper-dashboard-clock timezone="America/New_York"></hyper-dashboard-clock>
//   <hyper-dashboard-clock timezones='[{"timezone":"America/New_York","label":"NYC"},{"timezone":"Europe/London","label":"London"}]'></hyper-dashboard-clock>

class DashboardClock extends HTMLElement {
  #timezones = [];
  #intervalId = null;
  #shadow = null;

  #hourFormat = '24';

  static get observedAttributes() {
    return ['timezone', 'timezones', 'hour-format'];
  }

  connectedCallback() {
    this.#shadow = this.attachShadow({ mode: 'open' });
    this.#parseAttributes();
    this.#render();
    this.#startTicking();
  }

  disconnectedCallback() {
    this.#stopTicking();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) return;
    this.#parseAttributes();
    this.#render();
    if (!this.#intervalId) {
      this.#startTicking();
    }
  }

  #parseAttributes() {
    const singleTz = this.getAttribute('timezone');
    const multiTz = this.getAttribute('timezones');
    const hourFormat = this.getAttribute('hour-format');

    this.#hourFormat = hourFormat === '12' ? '12' : '24';

    if (multiTz) {
      try {
        const parsed = JSON.parse(multiTz);
        this.#timezones = Array.isArray(parsed) ? parsed : [];
      } catch (e) {
        console.error('Invalid timezones JSON:', e);
        this.#timezones = [];
      }
    } else if (singleTz) {
      this.#timezones = [{ timezone: singleTz, label: null }];
    } else {
      this.#timezones = [{ timezone: 'UTC', label: null }];
    }
  }

  #render() {
    const isMulti = this.#timezones.length > 1;
    
    this.#shadow.innerHTML = `
      <style>
        :host { display: block; }
        .clock {
          display: flex;
          flex-direction: column;
          align-items: center;
          text-align: center;
        }
        .clock-time {
          font-size: 3rem;
          font-weight: 700;
          color: var(--text, #e0e0e0);
          line-height: 1;
          font-variant-numeric: tabular-nums;
        }
        .clock-date {
          font-size: 0.9rem;
          color: var(--text-muted, #888);
          margin-top: 0.25rem;
          text-transform: uppercase;
          letter-spacing: 0.02em;
        }
        .clock-list {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
          width: 100%;
        }
        .clock-row {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0.5rem 0;
          border-bottom: 1px solid var(--border, rgba(255,255,255,0.06));
        }
        .clock-row:last-child {
          border-bottom: none;
        }
        .clock-row-label {
          font-size: 0.85rem;
          color: var(--text-muted, #888);
          text-transform: uppercase;
          letter-spacing: 0.02em;
        }
        .clock-row-time {
          font-size: 1.1rem;
          font-weight: 600;
          color: var(--text, #e0e0e0);
          font-variant-numeric: tabular-nums;
        }
      </style>
      ${isMulti ? this.#renderMulti() : this.#renderSingle()}
    `;
  }

  #renderSingle() {
    const tz = this.#timezones[0]?.timezone || 'UTC';
    return `
      <div class="clock">
        <div class="clock-time" data-timezone="${this.#esc(tz)}">--:--</div>
        <div class="clock-date"></div>
      </div>
    `;
  }

  #renderMulti() {
    const rows = this.#timezones.map((tz, i) => {
      const label = tz.label || tz.timezone;
      return `
        <div class="clock-row">
          <span class="clock-row-label">${this.#esc(label)}</span>
          <span class="clock-row-time" data-timezone="${this.#esc(tz.timezone)}" data-index="${i}">--:--</span>
        </div>
      `;
    }).join('');
    
    return `<div class="clock-list">${rows}</div>`;
  }

  #startTicking() {
    this.#tick();
    const now = new Date();
    const msUntilNextSecond = 1000 - (now.getMilliseconds() % 1000);
    
    // Align to the next second
    setTimeout(() => {
      this.#tick();
      this.#intervalId = setInterval(() => this.#tick(), 1000);
    }, msUntilNextSecond);
  }

  #stopTicking() {
    if (this.#intervalId) {
      clearInterval(this.#intervalId);
      this.#intervalId = null;
    }
  }

  #tick() {
    const now = new Date();
    const is12Hour = this.#hourFormat === '12';
    
    // Update all time elements
    const timeElements = this.#shadow.querySelectorAll('[data-timezone]');
    timeElements.forEach(el => {
      const tz = el.getAttribute('data-timezone');
      try {
        el.textContent = now.toLocaleTimeString('en-GB', {
          hour: '2-digit',
          minute: '2-digit',
          timeZone: tz,
          hour12: is12Hour
        });
      } catch (e) {
        // Fallback for invalid timezone
        el.textContent = '--:--';
      }
    });

    // Update date for single clock
    const dateEl = this.#shadow.querySelector('.clock-date');
    if (dateEl) {
      dateEl.textContent = this.#formatDate(now);
    }
  }

  #formatDate(dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return `${days[dt.getDay() === 0 ? 6 : dt.getDay() - 1]}, ${months[dt.getMonth()]} ${dt.getDate()}`;
  }

  #esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
}

customElements.define('hyper-dashboard-clock', DashboardClock);
