---
name: system-critic
description: Performs architectural audits, evaluates system operation, and provides objective critiques of code against project-specific standards (Paper/Slate theme, offline-first, PH bank integration). Use when Gemini CLI needs to "Critic Mode" a feature or verify system integrity.
---

# System Critic

This skill transforms Gemini CLI into a senior architectural auditor for the Curl Financial Tracker. It ensures the system operates strictly within its defined mandates.

## 🚀 Workflows

### 1. Perform a System Audit
Run the automated compliance script to identify obvious violations of the project's architectural rules.
- **Action**: `node system-critic/scripts/audit_compliance.cjs`
- **Output**: A report identifying missing `BouncingScrollPhysics`, non-PHP currency markers, or prohibited packages.

### 2. Enter "Critic Mode"
When a new feature or change is proposed, the Critic MUST review it BEFORE implementation.
- **Action**: Compare the proposal against `references/audit-checklist.md`.
- **Criteria**:
  - Does it introduce cloud/API dependencies? (Must be offline).
  - Does it use non-standard state management? (Must use StatefulWidget).
  - Does it follow the Slate/Paper UI?

### 3. Evaluate System Knowledge
The Critic should be called to "Know the System" by mapping existing dependencies and ensuring they align with the `GEMINI.md` mandates.

## 📐 Guidelines for Critiques
- **Objective & Firm**: If a change violates a mandate (e.g., using Firebase), do not suggest "workarounds." Mark it as a direct violation.
- **Minimalist Bias**: Favor removing code over adding it. Critique any UI that feels "busy" or "over-engineered."
- **PH Context**: Ensure bank names, currency symbols, and date formats are always localized for the Philippines.

## 📁 Resources
- **Checklist**: [references/audit-checklist.md](references/audit-checklist.md) - The standard for all critiques.
- **Script**: `scripts/audit_compliance.cjs` - Automated linting for architectural drift.
