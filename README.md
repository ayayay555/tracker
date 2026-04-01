# Curl: Premium Financial Companion 🍌🇵🇭

![Curl Preview](img/mockups.png)

**Curl** is a high-fidelity, premium financial tracking application built with **Flutter**. Reimagined with a vibrant mascot-driven aesthetic and designed specifically for the Philippine market, Curl combines high-end UX with 100% offline privacy.

---

## 🏗️ Premium Architecture

Curl follows a **Local-First, Immersive** architecture designed for speed and security.

### **Core Modules**
- **`lib/logic/transaction_manager.dart`**: The engine. Manages itemized budgets, bank balances, and local persistence via `shared_preferences`.
- **`lib/models/bank.dart`**: Registry for **20+ Philippine banks** (Traditional & Digital) with custom support.
- **`lib/main.dart`**: The premium UI container. Features a custom theme engine, animated transitions, and cross-platform asset handling.

### **Tech Stack**
- **Framework:** Flutter (Immersive Fullscreen Mode)
- **Typography:** `Plus Jakarta Sans` (Google Fonts)
- **Persistence:** `shared_preferences` (100% Offline)
- **Assets:** `image_picker` for cross-platform profile personalization.

---

## ✨ Premium Features

- **🍌 Mascot-Driven Branding:** Meet our "Banana" companion! Integrated as the official app icon across Android, iOS, and Web.
- **🎯 Dynamic Onboarding:** A beautiful 3-step journey to personalize your username, bank list, and visual vibe.
- **🎨 Elite Theming:** Switch instantly between **Banana Yellow**, **Sleek Dark**, or **System Default** modes with a high-contrast theme engine.
- **📊 Itemized Budget Planner:** Don't just set a limit—plan your month. Add specific items (Rent, Food, etc.) and track progress in real-time.
- **🏦 Intelligent Banking:**
  - **Bank Breakdown:** Tap your balance island to see a detailed modal of funds per bank.
  - **Safety First:** Built-in **Insufficient Funds** warnings for withdrawals and transfers.
- **💸 Intuitive Transfers:** Swap funds between accounts with a sleek, animated stacked-card interface.
- **📸 Personalized Profile:** Fully editable personal info with cross-platform profile picture upload support.
- **📑 Activity Islands:** Smart, expandable transaction history that keeps your dashboard clean and focused.

---

## 🚀 Experience it Now

Visit the live app: [https://ayayay555.github.io/tracker/](https://ayayay555.github.io/tracker/)

### **📥 Installation (PWA)**
Curl is a **Progressive Web App**. Install it for a native experience:

**iOS:** Open in Safari ➔ Tap **Share** ➔ **Add to Home Screen**.  
**Android:** Open in Chrome ➔ Tap **(⋮)** ➔ **Install app**.

---

## 📈 Privacy & Security
- **No Cloud:** Your financial data never leaves your device.
- **Zero Tracking:** No analytics, no accounts, no ads.
- **Local-Only:** Privacy by design.

---

## 🛠️ Local Development

1.  **Clone & Enter:**
    ```bash
    git clone https://github.com/ayayay555/tracker.git
    cd tracker
    ```
2.  **Sync Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run:**
    ```bash
    flutter run -d chrome # or your mobile device
    ```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
