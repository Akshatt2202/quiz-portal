# Quiz Portal

A full-stack quiz system with real-time student tracking, built with Node.js + Prisma + Redis + React.

## Prerequisites
- Node.js 18+
- PostgreSQL (running locally)
- Redis (running locally)

## Setup

### 1. Backend
```bash
cd backend
cp .env .env.local   # edit DATABASE_URL and REDIS_URL
npm install
npx prisma migrate dev --name init   # creates all tables
npm run dev          # starts on port 4000
```

### 2. Create first admin user
```bash
cd backend
npx ts-node src/scripts/create-admin.ts admin@school.com admin123 Admin
```

### 3. Frontend
```bash
cd frontend
npm install
npm run dev     # starts on port 5173
```

## Production Deployment (free tier)

| Piece | Service |
|---|---|
| Frontend | Netlify (`netlify.toml`) |
| API | Render free web service (`render.yaml`) |
| PostgreSQL | Neon free |
| Redis | Upstash free |

1. **Neon**: create a project and copy both connection strings: pooled (`-pooler` in host) and direct.
2. **Upstash**: create a Redis database and copy the TCP URL (`rediss://...`).
3. **Render**: New, then Blueprint, then select this repo. Fill in `DATABASE_URL` (pooled), `DIRECT_URL` (direct), `REDIS_URL`, and `FRONTEND_URL` (leave as a placeholder until step 4). Migrations run during the build. Keep one instance only, so the cron jobs don't run twice.
4. **Netlify**: import the repo and set `VITE_API_BASE_URL=https://<render-service>.onrender.com/api`. Deploy, then set Render's `FRONTEND_URL` to the Netlify origin.
5. **Admin user**: `cd backend && npx ts-node src/scripts/create-admin.ts <email> <password> <name>` with `DATABASE_URL` pointing at Neon.

Free-tier notes: the Render API sleeps after 15 min idle (the first request takes ~50 s), so open the site a few minutes before a quiz. Logins are CPU-heavy on the free instance, so have students log in in batches rather than all at once.

## Usage Flow

### Admin
1. Login at http://localhost:5173
2. Dashboard → Create Quiz → set title, duration, shuffle option
3. Manage Quiz → Add Questions (MCQ with 4 options, mark correct answer)
4. Activate Quiz when ready
5. View Results → per-student report with time spent per question, visit count, answer changes

### Students
1. Login at http://localhost:5173
2. See available quizzes → Start Quiz
3. Answer questions — timer counts down, answers auto-saved every 5s
4. Submit or auto-submit when timer expires
5. View result with score

## Tech Stack
- **Backend**: Node.js, Express, TypeScript, Prisma ORM, PostgreSQL, Redis, node-cron
- **Frontend**: React 18, Vite, React Router, Axios
- **Auth**: JWT (8h expiry)

## Key Design Decisions
- Events batched every 5s from browser → minimal DB load
- Redis stores live answer buffer + session timer
- Background job auto-submits expired sessions every 10s
- Buffer flushed to Postgres every 30s as backup
