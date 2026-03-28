# Recommended Tech Stack for Great Financial Trackers

## 1. Banking API & Syncing
- **Global:** [Plaid](https://plaid.com/), [Salt Edge](https://www.saltedge.com/), [Yodlee](https://www.yodlee.com/).
- **Southeast Asia (Relevant for GCash/Landbank):** [Brankas](https://brankas.com/), [Finantier](https://finantier.co/).
- **Fallback:** CSV/JSON import with smart parser for statements.

## 2. Artificial Intelligence (AI)
- **OpenAI API (GPT-4o/o1):** For transaction categorization, conversational queries, and spending insights.
- **Claude API (Sonnet):** For deep financial reasoning and complex analysis.
- **TensorFlow/PyTorch:** For custom predictive models if data volume is high.

## 3. Database & Storage
- **PostgreSQL:** With [TimescaleDB](https://www.timescale.com/) for high-performance transaction/time-series data.
- **Supabase/Firebase:** For quick backend setup with built-in auth (MFA).

## 4. Frontend & Mobile
- **React Native / Expo:** For a single codebase across iOS/Android with native performance.
- **D3.js / Recharts:** For high-quality, interactive financial data visualization.
- **Ionic / Capacitor:** If the user prefers staying with web technologies (like the current project).

## 5. Security & Compliance
- **Auth0 / Clerk:** For robust authentication and MFA.
- **AES-256-GCM:** For encrypting sensitive user data (e.g., bank keys) at the application level.
- **TLS 1.3:** For all network communication.

## 6. Real-time Notifications
- **OneSignal / Firebase Cloud Messaging:** For budget alerts and suspicious activity notifications.
- **Twilio:** For SMS-based MFA or critical alerts.
