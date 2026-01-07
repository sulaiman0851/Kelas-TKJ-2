# 🎭 Fakeit Game - Setup Guide

## Overview

**Fakeit** adalah game social deduction yang viral di TikTok, sekarang terintegrasi dengan **Gemini AI** untuk generate pertanyaan unlimited!

### Game Mechanics:
- **Host** buat room dengan pilih kategori
- **AI** generate pertanyaan unik setiap game
- **Faker** cuma tau kategori, BUKAN pertanyaan
- **Player biasa** tau pertanyaan lengkap
- Semua jawab → Diskusi → Vote → Reveal!

---

## 🚀 Quick Start

### 1. Setup Database

Jalankan SQL di Supabase SQL Editor:

```sql
-- Copy semua dari supabase/schema.sql
-- Bagian "5. FAKEIT GAME" (line 271-384)
```

Tables yang dibuat:
- `fakeit_categories` - Kategori game (Makanan, Tempat, dll)
- `fakeit_questions` - Fallback questions
- `fakeit_rooms` - Game rooms
- `fakeit_players` - Players dalam room
- `fakeit_votes` - Voting system

### 2. Get Gemini API Key (GRATIS!)

1. Buka: https://aistudio.google.com/apikey
2. Login dengan Google Account
3. Klik **"Create API Key"**
4. Copy API key

**Quota Gratis:**
- 1500 requests/day
- 60 requests/minute
- Lebih dari cukup untuk game!

### 3. Setup Environment Variables

Edit file `.env`:

```bash
# Supabase (sudah ada)
PUBLIC_SUPABASE_URL=your_supabase_url
PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Gemini AI - PASTE API KEY DI SINI
PUBLIC_GEMINI_API_KEY=AIzaSy...your_key_here
```

### 4. Restart Dev Server

```bash
# Stop server (Ctrl+C)
npm run dev
```

---

## 🎮 How to Play

### Host:
1. Buka `/game/fakeit`
2. Klik **"Buat Room Baru"**
3. Pilih kategori (Makanan, Tempat, dll)
4. Pilih jumlah Faker (1-2)
5. Share **kode room** (6 digit)
6. Tunggu min. 2 pemain
7. Klik **"Mulai Game"** → AI generate pertanyaan!

### Player:
1. Buka `/game/fakeit`
2. Masukkan **kode room**
3. Tunggu host start
4. Baca pertanyaan (atau kategori kalau Faker)
5. Jawab pertanyaan
6. Diskusi & vote siapa Faker!

---

## 🤖 AI Question Generation

### Cara Kerja:

```javascript
// 1. Host klik "Mulai Game"
startGame() {
  // 2. Call Gemini API
  const question = await generateAIQuestion(category);
  
  // 3. Save ke database
  await supabase.update({ ai_question: question });
  
  // 4. Semua player dapat pertanyaan yang sama!
}
```

### Fallback System:

Kalau API gagal (no internet, quota habis, dll):
- Auto pakai **fallback questions** dari database
- Game tetap jalan normal!

### Contoh AI Prompts:

**Input:**
```
Kategori: Makanan
```

**AI Output:**
```
"Makanan apa yang kamu makan diam-diam biar ga diminta orang lain?"
"Kalau dunia kiamat besok, makanan terakhir yang mau kamu makan apa?"
```

---

## 📊 Game Phases

### 1. **Waiting** ⏳
- Players join room
- Host tunggu min. 2 pemain
- Tampilkan kode room

### 2. **Question** 📝 (15 detik)
- AI generate pertanyaan
- **Player biasa:** Lihat pertanyaan lengkap
- **Faker:** Cuma tau kategori
- Hafalkan!

### 3. **Answer** ✍️ (60 detik)
- Semua ketik jawaban
- Faker harus ngeles!
- Host bisa skip kalau semua udah jawab

### 4. **Discussion** 💬 (2 menit)
- Baca semua jawaban
- Diskusi siapa yang mencurigakan
- Cari yang jawabannya aneh!

### 5. **Voting** 🗳️ (30 detik)
- Vote siapa yang Faker
- Ga bisa vote diri sendiri
- Host reveal kalau semua udah vote

### 6. **Reveal** 🎭
- Tampilkan hasil voting
- Reveal siapa Faker sebenarnya
- Tampilkan pertanyaan asli
- **Play Again** atau **Selesai**

---

## 🎨 Features

### ✅ Implemented:
- [x] AI-powered question generation (Gemini)
- [x] Realtime multiplayer (Supabase)
- [x] 6 kategori dengan icon
- [x] Fallback questions (25+)
- [x] Timer countdown setiap phase
- [x] Host controls (start, next phase)
- [x] Random faker assignment
- [x] Voting system dengan count
- [x] Play again feature
- [x] Responsive UI
- [x] Dark mode

### 🔮 Future Ideas:
- [ ] Custom categories
- [ ] Leaderboard/stats
- [ ] Sound effects
- [ ] Chat system
- [ ] Spectator mode
- [ ] Room password

---

## 🐛 Troubleshooting

### "AI Generating Question..." stuck?

**Penyebab:**
- API key salah/expired
- No internet connection
- Quota habis

**Solusi:**
1. Check `.env` - API key benar?
2. Check console - ada error?
3. Fallback akan auto-trigger
4. Refresh page & try again

### Pertanyaan tidak muncul?

**Solusi:**
```javascript
// Check di browser console:
console.log(room.ai_question); // Should show question
localStorage.clear(); // Clear cache
```

### Players tidak sync?

**Penyebab:**
- Realtime subscription gagal

**Solusi:**
1. Refresh semua player
2. Check Supabase dashboard - RLS policies OK?
3. Check network tab - websocket connected?

---

## 📝 Database Schema

### `fakeit_rooms`

```sql
id              uuid
code            text (6 chars, unique)
host_id         uuid → auth.users
category_id     uuid → fakeit_categories
question_id     uuid → fakeit_questions (fallback)
ai_question     text (AI-generated)  ← NEW!
status          enum (waiting, question, answer, discussion, voting, reveal, finished)
faker_count     int (1-2)
phase_ends_at   timestamptz
created_at      timestamptz
```

### `fakeit_players`

```sql
id              uuid
room_id         uuid → fakeit_rooms
user_id         uuid → auth.users
is_faker        boolean
answer          text
answered_at     timestamptz
joined_at       timestamptz
```

---

## 🔐 Security (RLS Policies)

### Categories & Questions:
```sql
-- Everyone can read
create policy "fakeit_categories_read" on fakeit_categories for select using (true);
```

### Rooms:
```sql
-- Everyone can read rooms
create policy "fakeit_rooms_read" on fakeit_rooms for select using (true);

-- Only host can create/update
create policy "fakeit_rooms_insert" on fakeit_rooms for insert 
  with check (auth.uid() = host_id);
```

### Players:
```sql
-- Everyone can see players
create policy "fakeit_players_read" on fakeit_players for select using (true);

-- Can only join as yourself
create policy "fakeit_players_insert" on fakeit_players for insert 
  with check (auth.uid() = user_id);
```

---

## 💡 Tips & Best Practices

### For Teachers:
1. **Test first** - Main sendiri dulu sebelum pakai di kelas
2. **Prepare backup** - Siapkan fallback questions kalau API down
3. **Monitor quota** - Check Gemini dashboard usage
4. **Set rules** - Jelaskan aturan sebelum main

### For Players:
1. **Be creative** - Jawaban yang unik lebih seru!
2. **Watch carefully** - Perhatikan jawaban yang aneh
3. **Don't reveal** - Jangan kasih tau kalau kamu Faker
4. **Have fun** - It's just a game!

---

## 📚 API Reference

### Gemini AI

**Endpoint:**
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent
```

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Body:**
```json
{
  "contents": [{
    "parts": [{ "text": "prompt here" }]
  }],
  "generationConfig": {
    "temperature": 0.9,
    "maxOutputTokens": 100
  }
}
```

**Response:**
```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "text": "Generated question here"
      }]
    }
  }]
}
```

---

## 🎯 Game Strategy

### As Normal Player:
- Jawab spesifik & detail
- Kasih context yang jelas
- Jangan terlalu umum

### As Faker:
- Jawab yang safe & umum
- Hindari detail spesifik
- Ikutin pola jawaban orang
- Jangan terlalu cepat/lambat jawab

### When Voting:
- Cari jawaban yang terlalu umum
- Cari yang ga nyambung sama kategori
- Perhatikan timing jawaban
- Trust your instinct!

---

## 🚀 Deployment

### Production Checklist:

1. **Environment Variables:**
```bash
PUBLIC_GEMINI_API_KEY=your_production_key
PUBLIC_SUPABASE_URL=your_production_url
PUBLIC_SUPABASE_ANON_KEY=your_production_key
```

2. **Build:**
```bash
npm run build
```

3. **Deploy:**
- Vercel: Auto-deploy from GitHub
- Netlify: Drag & drop `dist/`
- Cloudflare Pages: Connect repo

4. **Monitor:**
- Gemini quota: https://aistudio.google.com
- Supabase usage: Dashboard
- Error logs: Console

---

## 📞 Support

**Issues?**
- Check console errors
- Check Supabase logs
- Check Gemini quota
- Clear cache & retry

**Need Help?**
- Read this guide again
- Check GAME_DESIGN.md
- Ask teacher/admin

---

## 🎉 Credits

- **Game Design:** Inspired by viral TikTok Fakeit
- **AI:** Google Gemini 2.0 Flash
- **Database:** Supabase
- **Framework:** Astro + TypeScript
- **Styling:** Tailwind CSS

---

**Happy Gaming! 🎭🔥**
