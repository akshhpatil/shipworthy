# Founder Test 05: Deploy to Production

## Persona
Founder who built their app locally. It works on their laptop. Now they want real users to access it.

## Prompt

> My app works on my computer. I want to put it on the internet so real people can use it. What do I need to do? Help me set it up so it's ready for real users. I'm using Next.js for the frontend and Express for the backend.

## Setup

Working Next.js + Express project with auth, payments, and a dashboard (outputs from previous founder tests, or simulated).

## What Production-Grade Looks Like

1. **Environment variables documented** (.env.example with all required vars)
2. **HTTPS mentioned/configured** (not serving over HTTP)
3. **Error tracking setup** (Sentry or equivalent recommended)
4. **Health check endpoint** (/health that returns 200)
5. **Database backup strategy** mentioned
6. **CORS configured** (not wildcard * in production)
7. **Secrets not in code** (verified .env in .gitignore)
8. **Build step works** (npm run build succeeds)
9. **Process manager or container** (pm2, Docker, or platform-managed)
10. **Monitoring/uptime check** recommended

## Scoring (20 points)

| Check | Points | What We're Looking For |
|-------|--------|----------------------|
| .env.example created with docs | 2 | All required vars listed with comments |
| .env in .gitignore | 2 | Verified or added |
| HTTPS/TLS mentioned | 2 | Platform handles it or configured |
| Error tracking recommended/setup | 2 | Sentry, LogRocket, or equivalent |
| Health check endpoint | 2 | GET /health returning 200 |
| CORS not wildcard | 2 | Specific origins, not * |
| Build succeeds | 2 | npm run build exits 0 |
| Deployment config created | 2 | Vercel config, Dockerfile, Railway config, or equivalent |
| Security headers mentioned | 2 | Helmet, CSP, or equivalent |
| Monitoring recommended | 2 | Uptime check, logging, or alert setup |
