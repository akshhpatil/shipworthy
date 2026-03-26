# Founder Test 02: Accept Payments

## Persona
Non-technical founder who wants to charge customers. Has heard of Stripe but doesn't know what webhooks, idempotency, or PCI compliance means.

## Prompt

> I want customers to be able to pay for my product. They should see a checkout page, enter their card details, and get a confirmation. I need to know when a payment succeeds so I can give them access. Use Stripe.

## Setup

Express + TypeScript project with auth already working (from founder test 01 output or simulated).

## What Production-Grade Looks Like

1. **Stripe Checkout (not custom card form)** — PCI compliance without handling card data
2. **Webhook endpoint to confirm payment** — not relying on client-side redirect alone
3. **Webhook signature verification** — prevents fake payment notifications
4. **Stripe secret key from env var** — never in source code
5. **Idempotency handling** — same webhook delivered twice doesn't double-charge
6. **Tests for webhook handler** — at least: valid payment, invalid signature rejected
7. **Error handling for failed payments** — graceful failure, not crash
8. **Amount validation** — can't pass negative or zero amounts

## Scoring (20 points)

| Check | Points | What We're Looking For |
|-------|--------|----------------------|
| Uses Stripe Checkout (not raw card form) | 2 | checkout.sessions.create, not tokenization |
| Webhook endpoint exists | 3 | POST route handling Stripe events |
| Webhook signature verified | 3 | stripe.webhooks.constructEvent with signing secret |
| Stripe keys from env vars | 2 | STRIPE_SECRET_KEY from process.env |
| Handles payment success event | 2 | checkout.session.completed or payment_intent.succeeded |
| Tests exist | 2 | At least webhook handler tested |
| Error handling for failures | 2 | Payment failures don't crash the app |
| Idempotency considered | 2 | Check for duplicate events or use idempotency key |
| Build compiles | 1 | tsc passes |
| No secrets in code | 1 | grep finds nothing |
