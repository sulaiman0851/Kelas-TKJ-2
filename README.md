# Kelas TKJ - Astro + Supabase

Website kelas dengan sistem absensi dan game deduksi sosial (Impostor).

## Tech Stack
- **Framework:** Astro 5
- **Styling:** TailwindCSS 4
- **Backend:** Supabase (Auth, DB, Realtime)

## Setup
1.  **Dependencies**: `npm install` (Already done)
2.  **Environment Variables**:
    Create `.env` file in the root directory:
    ```env
    PUBLIC_SUPABASE_URL=your_supabase_url
    PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
    ```
3.  **Database Setup**:
    - Go to Supabase SQL Editor.
    - Copy content from `supabase/schema.sql`.
    - Run the script to create tables and policies.
    - IMPORTANT: Enable Realtime for `game_rooms`, `game_players`, `game_clues` in Supabase Dashboard -> Database -> Replication.

## Running
```bash
npm run dev
```

## Features
- **Auth**: Login dengan username atau email
- **Absensi**: Siswa Check-in, Guru Validasi
- **Game**: Realtime Impostor gameplay
- **RBAC**: Admin, Teacher, Student roles
- **Username System**: Unique username untuk setiap user
