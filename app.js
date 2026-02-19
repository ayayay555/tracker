/* FinTrack — app.js */

// ── State ──────────────────────────────────────────────────────────────────
const BANKS = ['gcash', 'gotyme', 'maribank', 'landbank'];

const BANK_LABELS = {
    gcash: 'GCash', gotyme: 'GoTyme', maribank: 'Maribank', landbank: 'Landbank'
};

function loadState() {
    try {
        const saved = localStorage.getItem('fintrack_state');
        if (saved) return JSON.parse(saved);
    } catch { }
    return {
        balances: { gcash: 0, gotyme: 0, maribank: 0, landbank: 0 },
        transactions: []        // { id, type, bank, amount, date }
    };
}

function saveState(state) {
    localStorage.setItem('fintrack_state', JSON.stringify(state));
}

let state = loadState();

// ── Selected banks ─────────────────────────────────────────────────────────
let selectedDeposit = null;
let selectedSpend = null;

// ── DOM refs ───────────────────────────────────────────────────────────────
const totalBalanceEl = document.getElementById('totalBalance');
const bankBreakdown = document.getElementById('bankBreakdown');
const balanceCard = document.getElementById('balanceCard');
const chevron = document.getElementById('chevron');

const depositAmountEl = document.getElementById('depositAmount');
const spendAmountEl = document.getElementById('spendAmount');
const depositBtn = document.getElementById('depositBtn');
const spendBtn = document.getElementById('spendBtn');

const historyBtn = document.getElementById('historyBtn');
const modalOverlay = document.getElementById('modalOverlay');
const modalClose = document.getElementById('modalClose');
const modalBody = document.getElementById('modalBody');
const modalTabs = document.getElementById('modalTabs');
const toast = document.getElementById('toast');

// ── Helpers ────────────────────────────────────────────────────────────────
function fmt(n) {
    return '₱' + Number(n).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function formatDate(iso) {
    const d = new Date(iso);
    return d.toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' })
        + ' · '
        + d.toLocaleTimeString('en-PH', { hour: '2-digit', minute: '2-digit' });
}

let toastTimer = null;
function showToast(msg, type = '') {
    toast.textContent = msg;
    toast.className = 'toast show ' + type;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { toast.className = 'toast'; }, 2800);
}

// ── Render ─────────────────────────────────────────────────────────────────
function renderBalances() {
    const total = BANKS.reduce((s, b) => s + state.balances[b], 0);
    totalBalanceEl.textContent = fmt(total);

    BANKS.forEach(b => {
        const el = document.getElementById('bal-' + b);
        if (el) el.textContent = fmt(state.balances[b]);
    });
}

// ── Balance card toggle ────────────────────────────────────────────────────
let expanded = false;
function toggleBreakdown() {
    expanded = !expanded;
    bankBreakdown.classList.toggle('open', expanded);
    chevron.classList.toggle('open', expanded);
    balanceCard.setAttribute('aria-expanded', String(expanded));
}

balanceCard.addEventListener('click', toggleBreakdown);
balanceCard.addEventListener('keydown', e => {
    if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggleBreakdown(); }
});

// ── Bank pill selection ────────────────────────────────────────────────────
function setupPills(containerId, group) {
    const pills = document.querySelectorAll(`#${containerId} .pill`);
    pills.forEach(pill => {
        pill.addEventListener('click', () => {
            pills.forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
            if (group === 'deposit') selectedDeposit = pill.dataset.bank;
            else selectedSpend = pill.dataset.bank;
        });
    });
}

setupPills('depositBankPills', 'deposit');
setupPills('spendBankPills', 'spend');

// ── Deposit ────────────────────────────────────────────────────────────────
depositBtn.addEventListener('click', () => {
    const raw = parseFloat(depositAmountEl.value);

    if (!selectedDeposit) { showToast('Please select a bank first.', 'error'); return; }
    if (!raw || raw <= 0) { showToast('Enter a valid amount.', 'error'); return; }

    const amount = Math.round(raw * 100) / 100;
    state.balances[selectedDeposit] += amount;

    state.transactions.unshift({
        id: crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(),
        type: 'deposit',
        bank: selectedDeposit,
        amount,
        date: new Date().toISOString()
    });

    // Keep last 100 transactions
    if (state.transactions.length > 100) state.transactions.length = 100;

    saveState(state);
    renderBalances();

    showToast(`Deposited ${fmt(amount)} to ${BANK_LABELS[selectedDeposit]}!`, 'success');
    depositAmountEl.value = '';
});

// ── Spend ──────────────────────────────────────────────────────────────────
spendBtn.addEventListener('click', () => {
    const raw = parseFloat(spendAmountEl.value);

    if (!selectedSpend) { showToast('Please select a bank first.', 'error'); return; }
    if (!raw || raw <= 0) { showToast('Enter a valid amount.', 'error'); return; }

    const amount = Math.round(raw * 100) / 100;

    if (state.balances[selectedSpend] < amount) {
        showToast(`Insufficient balance in ${BANK_LABELS[selectedSpend]}.`, 'error');
        return;
    }

    state.balances[selectedSpend] -= amount;
    state.balances[selectedSpend] = Math.round(state.balances[selectedSpend] * 100) / 100;

    state.transactions.unshift({
        id: crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(),
        type: 'spend',
        bank: selectedSpend,
        amount,
        date: new Date().toISOString()
    });

    if (state.transactions.length > 100) state.transactions.length = 100;

    saveState(state);
    renderBalances();

    showToast(`Spent ${fmt(amount)} from ${BANK_LABELS[selectedSpend]}.`, 'success');
    spendAmountEl.value = '';
});

// ── Transaction History Modal ──────────────────────────────────────────────
let activeFilter = 'all';

function renderHistory() {
    const txs = activeFilter === 'all'
        ? state.transactions
        : state.transactions.filter(t => t.bank === activeFilter);

    if (txs.length === 0) {
        modalBody.innerHTML = '<p class="empty-state">No transactions yet.</p>';
        return;
    }

    modalBody.innerHTML = txs.map(tx => `
    <div class="tx-item">
      <div class="tx-left">
        <span class="tx-icon ${tx.type}">
          ${tx.type === 'deposit' ? '⬇️' : '⬆️'}
        </span>
        <div class="tx-info">
          <span class="tx-type">${BANK_LABELS[tx.bank]}</span>
          <span class="tx-meta">${formatDate(tx.date)}</span>
        </div>
      </div>
      <span class="tx-amount ${tx.type}">
        ${tx.type === 'deposit' ? '+' : '-'}${fmt(tx.amount)}
      </span>
    </div>
  `).join('');
}

historyBtn.addEventListener('click', () => {
    renderHistory();
    modalOverlay.classList.add('open');
    modalOverlay.setAttribute('aria-hidden', 'false');
});

function closeModal() {
    modalOverlay.classList.remove('open');
    modalOverlay.setAttribute('aria-hidden', 'true');
}

modalClose.addEventListener('click', closeModal);
modalOverlay.addEventListener('click', e => { if (e.target === modalOverlay) closeModal(); });

// Tab filter
modalTabs.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        modalTabs.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        activeFilter = tab.dataset.filter;
        renderHistory();
    });
});

// Keyboard close
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeModal();
});

// ── Service Worker ─────────────────────────────────────────────────────────
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('service-worker.js')
            .catch(err => console.warn('SW registration failed:', err));
    });
}

// ── Init ───────────────────────────────────────────────────────────────────
renderBalances();
