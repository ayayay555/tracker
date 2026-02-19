# FinTrack — Finance Tracker

A PWA (Progressive Web App) to track your money across **GCash, GoTyme, Maribank, and Landbank**. Installable on Android directly from Chrome.

## Features
- 💰 Total balance with expandable bank breakdown
- ⬇️ Deposit to any bank
- ⬆️ Spend from any bank (with overdraft protection)
- 📋 Transaction history with bank filter
- 💾 Data saved locally on your device (localStorage)
- 📴 Works offline after first load (Service Worker)

## How to Install on Android

1. Open the live URL in **Chrome on Android**
2. Tap the **3-dot menu (⋮)** → **"Add to Home Screen"**
3. Tap **"Install"** → the app appears on your home screen!

## Deploy to GitHub Pages

> This gives you the live URL needed to install on Android.

1. Push this repo to GitHub
2. Go to repo **Settings → Pages**
3. Set Source: **Deploy from branch → main → / (root)**
4. Click **Save** — your URL will be: `https://YOUR_USERNAME.github.io/tracker/`

## Local Development

```bash
# Serve locally (required for service worker to work)
npx serve .
# Then open: http://localhost:3000
```

> ⚠️ Open via localhost, not by double-clicking index.html — service workers need HTTP.
