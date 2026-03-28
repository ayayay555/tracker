---
name: financial-tracker-expert
description: Expert guidance on building and optimizing financial tracking applications. Use when designing, developing, or improving a financial tracker app, including feature ideation, tech stack selection, and UX best practices for personal finance.
---

# Financial Tracker Expert

This skill provides specialized knowledge and workflows for creating a world-class financial tracking application. It covers everything from basic transaction management to advanced AI-driven features.

## Workflows

### 1. Feature Assessment & Roadmap
When starting or improving a tracker, assess the current implementation against modern standards:
1. **Analyze existing features:** (e.g., manual entry, basic history).
2. **Identify gaps:** Compare with [modern-features.md](references/modern-features.md).
3. **Prioritize:** Focus on high-impact features like automation and reliable syncing.

### 2. Tech Stack Selection
Choosing the right tools is critical for security and scalability:
- **Banking APIs:** See [tech-stack.md](references/tech-stack.md) for regional and global options.
- **AI Integration:** Use LLMs for categorization and natural language queries.
- **Security First:** Ensure MFA and encryption are part of the initial design.

### 3. UX Design for Finance
Personal finance can be stressful; great UX minimizes friction:
- **Minimize manual entry:** Automate through bank syncing or OCR for receipts.
- **Clear Visualizations:** Use charts to show trends over time, not just lists.
- **Actionable Insights:** Don't just show data; tell the user what it means (e.g., "You're over budget by 10% this week").

## Reference Material

- [Modern Features](references/modern-features.md): A comprehensive list of 2024-2025 financial app trends.
- [Recommended Tech Stack](references/tech-stack.md): Specific APIs and tools for building financial apps.

## Best Practices

- **Privacy by Design:** Always prioritize user data security. Never log or store plain-text credentials.
- **Offline First:** Ensure basic functionality (like balance checks and manual entry) works without a network connection.
- **Accuracy Matters:** Financial data must be precise. Avoid floating-point errors (use integers for cents or specialized libraries like `decimal.js`).
