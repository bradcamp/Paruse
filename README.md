# Paruse
Paruse iOS viewer app by Istockhomes — browse and purchase only. No sign-in. No uploads.
# Paruse iOS — Viewer App

Paruse is a **viewer-only** iOS application.

Users can:
- browse items
- view details
- initiate purchases via external checkout

Users cannot:
- sign in
- upload content
- list items
- access admin tools

This repository exists to demonstrate:
- Swift / SwiftUI structure
- mobile-first UX
- calm, intentional design
- how viewer-only apps fit into the Istockhomes ecosystem

---

## Purchases

“Purchases are handled via secure PayPal checkout through Istockhomes infrastructure. The app never stores or processes payment credentials.”

No payment keys, credentials, or private infrastructure are included in this app.

---

## What is intentionally excluded

- authentication systems
- admin or upload flows
- payment routing logic
- API keys or secrets
- internal services

Those systems live in protected repositories.

---

## Context

Paruse is part of the broader Istockhomes platform.

If you are interested in how participation works for developers:
https://istockhomes.ca/pages/inside-istockhomes-developers

---

## For Developers

Paruse is intentionally published as a **working viewport**, not a demo.

This app is designed to help developers understand:
- the direction of the Istockhomes platform
- how real-world listings flow into a mobile storefront
- how value is surfaced without friction
- how participation can be **ongoing**, not contractual

### What you can do with this app

Developers are free to:
- download and run the app
- modify and re-skin the UI (white-label use is expected)
- adapt the look and feel for specific brands, stores, or entities
- give away or sell their customized version

Paruse is meant to be altered.

### How getting paid works (high level)

Paruse connects to Istockhomes’ **automatic payment distribution system**.

When a purchase occurs:
- the creator and operator decide how the majority of value is shared
- platform participation is handled automatically
- payouts are routed server-side through PayPal
- no developer is required to manage billing, invoicing, or collections

Developers, SEO contributors, marketing teams, and operators may participate
by being registered to an entity **before sales occur**.

Client-side code does not control payouts.

### Important boundaries

This repository does not include:
- authentication or admin systems
- upload or listing submission logic
- payment split logic
- private infrastructure

Those systems are intentionally protected and enforced server-side.

### Context

To understand how participation, entities, and revenue sharing fit together:
https://istockhomes.ca/pages/inside-istockhomes-developers
