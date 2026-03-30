---
name: e-commerce
description: E-commerce domain patterns — cart management, inventory, pricing, order lifecycle, fulfillment, and refunds. Activates when the project involves selling products or services online.
version: 1.0.0
activate_when: Project involves shopping cart, product catalog, checkout, payments, orders, or inventory management.
---

# E-Commerce Extension

## What This Adds

Domain-specific engineering guidance for e-commerce applications:

- **Cart Patterns** — state management, inventory reservation, price calculation, abandonment handling
- **Order Lifecycle** — state machines, fulfillment flows, refund/return handling, email notifications

## When This Activates

Automatically when the project contains signals like:
- Cart/checkout related files or routes
- Product/order database models
- Payment integration (Stripe, PayPal, etc.)
- Inventory management code

## Skills Included

| Skill | Purpose |
|-------|---------|
| `cart-patterns` | Cart state, inventory checks, pricing rules, tax calculation |
| `order-lifecycle` | Order states, fulfillment, cancellation, refunds |
