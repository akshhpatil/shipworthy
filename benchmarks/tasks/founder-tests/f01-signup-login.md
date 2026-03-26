# Founder Test 01: User Signup and Login

## Persona
Non-technical startup founder. Doesn't know what JWT, middleware, or bcrypt means. Describes what they want in business language.

## Prompt

> I need users to be able to create an account and log in to my app. They should sign up with their email and password, and once they're logged in they should stay logged in. If someone tries to access the app without logging in, they should be sent to the login page.

## Setup

Empty Express + TypeScript project with only package.json and tsconfig.json.

## What Production-Grade Looks Like

A non-technical founder wouldn't ask for any of these, but production code MUST have them:

1. **Passwords hashed** (bcrypt/argon2, NOT plain text or MD5)
2. **No password in API responses** (never return the password field)
3. **Input validation** (email format, password length minimums)
4. **Rate limiting on login** (prevent brute force)
5. **Secure session/token handling** (httpOnly cookies or JWT with expiry)
6. **Tests** (at least for: signup works, login works, wrong password fails, duplicate email rejected)
7. **No secrets in code** (JWT secret from env var)
8. **Proper error messages** (don't reveal whether email exists — "invalid credentials" for both)

## Scoring (20 points)

| Check | Points | What We're Looking For |
|-------|--------|----------------------|
| Passwords hashed (not plaintext) | 3 | bcrypt, argon2, or scrypt — NOT md5/sha |
| Password not in API responses | 2 | Response excludes password field |
| Input validation exists | 2 | Email format + password length checked |
| Rate limiting on login | 2 | Some form of attempt limiting |
| Tokens/sessions have expiry | 2 | Not permanent sessions |
| Tests exist and pass | 3 | At least 3 meaningful tests |
| Secrets from env vars | 2 | JWT_SECRET or equivalent from process.env |
| Safe error messages | 2 | "Invalid credentials" not "user not found" vs "wrong password" |
| Build compiles | 1 | tsc passes |
| No console.log in prod | 1 | Clean logging |

## Anti-Patterns (Founder Would Never Catch These)
- Storing passwords in plain text
- Returning password hash in user object
- JWT with no expiration
- Hardcoded secret key in source code
- Different error messages for "email not found" vs "wrong password" (enables user enumeration)
- No input validation (accepts empty email, 1-char password)
