# Founder Test 03: Landing Page with Waitlist

## Persona
Pre-launch founder. No product yet, just wants to collect emails from interested people.

## Prompt

> I need a landing page for my startup. It should have a headline, a short description of what we do, and an email signup form for people to join the waitlist. When someone signs up, save their email and show a thank you message. Make it look professional.

## Setup

Next.js + TypeScript project (empty, just package.json and tsconfig.json).

## What Production-Grade Looks Like

1. **Email validation** (format check, not just required field)
2. **Duplicate email handling** (graceful — "you're already on the list", not crash)
3. **CSRF/XSS protection** (sanitize input, don't render raw HTML)
4. **Accessible** (form has labels, semantic HTML, keyboard navigable)
5. **Responsive** (works on mobile)
6. **Meta tags** (title, description, og:image for social sharing)
7. **No storing emails in code** (use API route, not client-side array)
8. **Rate limiting** (prevent spam signups)

## Scoring (20 points)

| Check | Points | What We're Looking For |
|-------|--------|----------------------|
| Email validation (format check) | 2 | Regex or library validation, not just required |
| Duplicate handling (no crash) | 2 | Graceful message or silent dedup |
| API route for submission | 2 | Server-side handler, not client-only storage |
| Accessible form (labels, semantic HTML) | 2 | label elements, proper form structure |
| Responsive design | 2 | Works at 375px viewport |
| Meta tags present | 2 | title, description, og tags |
| Input sanitized | 2 | No raw HTML rendering of user input |
| Success feedback | 2 | Thank you message or visual confirmation |
| TypeScript compiles | 2 | No type errors |
| Professional appearance | 2 | Not unstyled default HTML |
