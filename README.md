# Curl: Minimalistic Financial Tracker (PH Edition) 🇵🇭

![Curl Preview](img/mockup.png)

A high-fidelity, minimalistic financial tracking application built with **Flutter**. Designed specifically for the Philippine market with a focus on speed, privacy, and a premium user experience.

---

## 🏗️ Codebase Overview

Curl follows a **Local-First, Minimalist** architecture designed for the Philippine financial ecosystem.

### **Core Modules**
- **`lib/logic/transaction_manager.dart`**: The engine of the app. It handles all business logic, manages the user's selected banks, calculates balances, and provides data persistence via `shared_preferences`.
- **`lib/models/bank.dart`**: Contains pre-configured data for **20+ major Philippine banks** (BDO, GCash, Maya, etc.), categorized into traditional and digital types.
- **`lib/models/transaction.dart`**: A clean data model for both income and expenses with automatic ID generation and JSON serialization.
- **`lib/main.dart`**: The UI entry point. It manages state transitions between onboarding, the home dashboard, and the analysis tabs using standard Flutter `StatefulWidgets`.

### **Tech Stack**
- **Framework:** Flutter (Web/Mobile)
- **Persistence:** `shared_preferences` (Encrypted/Local storage)
- **UI Design:** "Paper/Slate" Aesthetic (Custom Slate theme + Bouncing physics)
- **Simulation:** `device_preview` (Enables the phone frame on web)

---

## ✨ Key Features

- **📱 Mobile Live Preview:** Experience the app in a realistic phone frame directly in your browser.
- **🎯 Interactive Onboarding:** Personalize your experience by selecting only the banks and wallets you actually use.
- **🏦 PH Bank Integration:** Deep support for top traditional and digital banks (BDO, Maya, GCash, GoTyme, etc.) + **Custom Bank** support.
- **📊 Smart Analysis & Budgeting:** 
  - **Configurable Budgets:** Set your total monthly goal and specific category limits.
  - **Live Progress Bar:** Monitor your spending in real-time directly on the dashboard.
- **📑 Bank-Specific Insights:** Tap any account to see its specific transaction history and balance.
- **⚡ Streamlined Logging:** Fast entry for expenses and category-free logging for deposits.
- **💾 Local Persistence:** Your data is yours. All logs are saved locally on your device for fast, offline access.
- **✨ Fluid UX:** Modern **Paper/Slate** theme with smooth transitions and **Swipe-to-Delete** gestures.

---

## 🚀 Experience it Now

Visit the live app: [https://ayayay555.github.io/tracker/](https://ayayay555.github.io/tracker/)

### **📥 How to "Download" to your Phone (PWA)**
Experience **Curl** like a native app without using an App Store:

**For iPhone (iOS):**
1. Open the link in **Safari**.
2. Tap the **Share** button (square with arrow).
3. Select **"Add to Home Screen"**.

**For Android:**
1. Open the link in **Chrome**.
2. Tap the **three dots (⋮)** menu.
3. Select **"Install app"** or **"Add to Home screen"**.

---

## 📈 Privacy & Security
Curl is built with **Privacy by Design**. 
- **Zero Tracking:** No external analytics or trackers.
- **Local Only:** Your transaction data never leaves your device.
- **No Cloud:** No sign-ups or servers required.

---

## 🛠️ Getting Started (Local Development)

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- Google Chrome

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ayayay555/tracker.git
    cd tracker
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run -d chrome
    ```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
