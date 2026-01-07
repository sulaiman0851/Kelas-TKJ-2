# 🎮 Game Zone - Multi-Game Platform

## Game List

### 1. **Fakeit** (Priority #1) 🔥
**Konsep**: Social deduction game - cari siapa yang FAKER!

**Flow**:
1. **Setup** (Teacher/Host):
   - Pilih kategori (Makanan, Tempat, Hewan, dll)
   - Set jumlah Faker (biasanya 1)
   - Start game

2. **Question Phase**:
   - System random pilih 1 pertanyaan dari kategori
   - Semua player (kecuali Faker) dapat pertanyaan
   - Faker cuma tau kategorinya aja
   - Timer: 30 detik baca

3. **Answer Phase**:
   - Semua player nulis jawaban (1-2 kalimat)
   - Faker harus ngakalin jawaban biar ga ketahuan
   - Timer: 60 detik

4. **Discussion Phase**:
   - Semua jawaban ditampilkan (anonymous/dengan nama)
   - Player diskusi siapa yang mencurigakan
   - Timer: 2 menit

5. **Voting Phase**:
   - Setiap player vote 1 orang yang dicurigai Faker
   - Hasil voting ditampilkan

6. **Reveal**:
   - Faker revealed!
   - Scoring:
     - Faker menang: +3 poin (kalau ga ketahuan atau vote salah)
     - Player menang: +1 poin (kalau berhasil tebak Faker)

### 2. **Impostor** (Already Built)
Game deduksi sosial dengan keyword & clues

### 3. **Future Games**
- Trivia Quiz
- Gartic Phone style
- Werewolf

---

## Database Schema for Fakeit

```sql
-- Game Types
CREATE TABLE game_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE NOT NULL, -- 'fakeit', 'impostor', 'trivia'
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true
);

-- Fakeit Categories
CREATE TABLE fakeit_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  icon TEXT
);

-- Fakeit Questions
CREATE TABLE fakeit_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID REFERENCES fakeit_categories(id),
  question TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Game Rooms (Updated)
ALTER TABLE game_rooms ADD COLUMN game_type_id UUID REFERENCES game_types(id);
ALTER TABLE game_rooms ADD COLUMN current_phase TEXT; -- 'waiting', 'question', 'answer', 'discussion', 'voting', 'reveal', 'finished'
ALTER TABLE game_rooms ADD COLUMN phase_ends_at TIMESTAMPTZ;

-- Fakeit Game State
CREATE TABLE fakeit_game_state (
  game_id UUID PRIMARY KEY REFERENCES game_rooms(id),
  category_id UUID REFERENCES fakeit_categories(id),
  question_id UUID REFERENCES fakeit_questions(id),
  faker_count INT DEFAULT 1
);

-- Fakeit Answers
CREATE TABLE fakeit_answers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID REFERENCES game_rooms(id),
  player_id UUID REFERENCES auth.users(id),
  answer TEXT NOT NULL,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Fakeit Votes
CREATE TABLE fakeit_votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID REFERENCES game_rooms(id),
  voter_id UUID REFERENCES auth.users(id),
  suspect_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(game_id, voter_id)
);

-- Player Scores
CREATE TABLE game_scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID REFERENCES game_rooms(id),
  player_id UUID REFERENCES auth.users(id),
  score INT DEFAULT 0,
  UNIQUE(game_id, player_id)
);
```

---

## UI/UX Design

### Game Zone Landing (`/game`)
```
┌─────────────────────────────────────┐
│  🎮 GAME ZONE                       │
│                                     │
│  ┌──────────┐  ┌──────────┐       │
│  │ 🎭       │  │ 🕵️        │       │
│  │ FAKEIT   │  │ IMPOSTOR │       │
│  │ 🔥 HOT   │  │          │       │
│  └──────────┘  └──────────┘       │
│                                     │
│  Active Rooms:                     │
│  • Kelas XII - Fakeit (3/8)       │
│  • TKJ 1 - Impostor (5/10)        │
└─────────────────────────────────────┘
```

### Fakeit Game Room
**Question Phase**:
```
┌─────────────────────────────────────┐
│  ⏱️ 00:25                           │
│                                     │
│  📝 PERTANYAAN ANDA:                │
│                                     │
│  ┌─────────────────────────────┐  │
│  │                             │  │
│  │  "Apa makanan favorit       │  │
│  │   kamu saat hujan?"         │  │
│  │                             │  │
│  └─────────────────────────────┘  │
│                                     │
│  💡 Kategori: MAKANAN              │
│                                     │
│  Hafalkan pertanyaan ini!          │
│  Jangan kasih tau orang lain!      │
└─────────────────────────────────────┘
```

**Faker View**:
```
┌─────────────────────────────────────┐
│  ⏱️ 00:25                           │
│                                     │
│  🎭 KAMU ADALAH FAKER!              │
│                                     │
│  ┌─────────────────────────────┐  │
│  │                             │  │
│  │  Kategori: MAKANAN          │  │
│  │                             │  │
│  │  Kamu TIDAK tahu            │  │
│  │  pertanyaannya!             │  │
│  │                             │  │
│  │  Tebak & jawab senatural    │  │
│  │  mungkin agar tidak         │  │
│  │  ketahuan!                  │  │
│  │                             │  │
│  └─────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## Implementation Priority

1. ✅ **Phase 1**: Multi-game selector UI
2. 🔨 **Phase 2**: Fakeit database schema
3. 🔨 **Phase 3**: Fakeit game flow
4. 🔨 **Phase 4**: Real-time updates
5. 🔨 **Phase 5**: Scoring system
