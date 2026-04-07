# Task 03: Payment Integration

## Prompt

> I want customers to be able to pay for my product. They should see a checkout page, enter their card info, and get a confirmation once it goes through. I need to know when a payment works so I can give them access. Use Stripe.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide an Express+TypeScript API with authentication already implemented and working.

**Directory structure before the task:**
```
payment-api/
  package.json
  tsconfig.json
  .env.example
  src/
    index.ts
    config.ts
    routes/
      health.ts
      auth.ts
    middleware/
      authenticate.ts
      errorHandler.ts
    models/
      user.ts
    services/
      auth.service.ts
    types/
      index.ts
  tests/
    auth.test.ts
    health.test.ts
```

**package.json** (key dependencies -- full file should be provided in actual setup):
```json
{
  "name": "payment-api",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest --forceExit --detectOpenHandles"
  },
  "dependencies": {
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/bcryptjs": "^2.4.6",
    "@types/jest": "^29.5.11",
    "@types/node": "^20.11.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.3.3",
    "supertest": "^6.3.3",
    "@types/supertest": "^6.0.2"
  }
}
```

**.env.example**
```
PORT=3000
JWT_SECRET=your-jwt-secret-here
```

**src/config.ts**
```typescript
export const config = {
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET || 'dev-secret',
};
```

The auth system uses an in-memory user store. Register and login endpoints work. The `authenticate` middleware verifies JWTs and attaches `req.user` to the request. All existing tests pass.

Run `npm install` and verify `npm test` passes before handing the project to the agent.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `src/routes/payment.ts` or `src/routes/checkout.ts` -- payment route definitions
- `src/routes/webhook.ts` or webhook handler within payment routes -- Stripe webhook endpoint
- `src/services/payment.service.ts` or `src/services/stripe.service.ts` -- Stripe SDK interaction logic
- Updated `.env.example` with `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET`
- Updated `src/config.ts` referencing Stripe env vars
- Test files for payment/webhook logic
- `stripe` package in `package.json` dependencies

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Stripe SDK used properly** | 2 | `stripe` is in `package.json` dependencies. SDK is initialized with the secret key from env vars: `new Stripe(process.env.STRIPE_SECRET_KEY)`. |
| 2 | **Webhook signature verification** | 3 | `stripe.webhooks.constructEvent(body, sig, webhookSecret)` is called. The webhook route uses `express.raw()` for the body parser, NOT `express.json()`. |
| 3 | **Idempotency handling** | 2 | Either Stripe idempotency keys are used on create calls, or the webhook handler checks for duplicate event processing (e.g. storing processed event IDs). |
| 4 | **No Stripe key in code** | 3 | `grep -r "sk_test_\|sk_live_\|whsec_" src/` returns 0 results. Keys come from env vars only. |
| 5 | **Error handling for payment failures** | 2 | Payment creation errors are caught and return appropriate HTTP status codes (400 for bad input, 402 for payment failure, 500 for Stripe service errors). |
| 6 | **Tests for webhook handler** | 2 | At least 2 test cases: one for a valid webhook event, one for an invalid signature. Tests mock the Stripe SDK. |
| 7 | **Proper HTTP status codes** | 2 | Checkout creation returns 201 or 200. Webhook returns 200 on success. Invalid webhook returns 400. Not found returns 404. |
| 8 | **Amount validation** | 2 | The checkout endpoint validates that the amount is a positive number and within acceptable bounds before sending to Stripe. |
| 9 | **Success/failure response types** | 2 | TypeScript types or interfaces are defined for API responses (e.g. `CheckoutSessionResponse`, `WebhookResponse`). |

**Total: 20 points**

## Anti-Patterns to Check

- **Stripe secret key hardcoded**: `sk_test_...` or `sk_live_...` literals anywhere in source files.
- **Webhook body parsed as JSON**: Using `express.json()` on the webhook route breaks signature verification. The raw body is required.
- **No signature verification on webhook**: Accepting any POST to the webhook endpoint without verifying the Stripe signature allows forged events.
- **No idempotency protection**: Processing the same webhook event multiple times could double-charge or double-fulfill.
- **Swallowed errors in webhook handler**: `catch (e) { res.status(200).send() }` -- always returning 200 even on failure hides bugs.
- **Amount as a float**: Stripe uses integer cents. Passing `19.99` instead of `1999` is a common bug.
- **No error types**: Payment errors returned as raw strings instead of structured error objects.
- **Missing env vars crash the app**: If `STRIPE_SECRET_KEY` is not set, the app throws an unhandled exception on startup instead of failing gracefully.
- **Auth not required on checkout**: The checkout endpoint should require authentication so payment is tied to a user.
- **Webhook endpoint behind auth middleware**: The webhook endpoint should NOT require JWT auth -- Stripe cannot provide one. It should use signature verification instead.
