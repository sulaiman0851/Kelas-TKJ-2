-- Enable UUID extension
create extension if not exists "uuid-ossp";

--------------------------------------------------------------------------------
-- 1. AUTH & ROLES
--------------------------------------------------------------------------------

-- Roles table
create table public.roles (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique check (name in ('admin', 'teacher', 'student'))
);

-- User Roles (Many-to-Many but usually 1 user has key roles)
create table public.user_roles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  role_id uuid references public.roles(id) on delete cascade not null,
  unique (user_id, role_id)
);

-- Profiles (Public user data)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text,
  avatar_url text,
  created_at timestamptz default now()
);

-- Create index for faster username lookups
create index idx_profiles_username on public.profiles(username);


-- Helper function to check role safely in RLS
create or replace function public.has_role(role_name text)
returns boolean as $$
begin
  return exists (
    select 1 from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid()
    and r.name = role_name
  );
end;
$$ language plpgsql security definer;

-- Trigger to create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name)
  values (
    new.id, 
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'full_name'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Function to get email from username (for login)
create or replace function public.get_email_from_username(username_input text)
returns text as $$
declare
  user_email text;
begin
  select email into user_email
  from auth.users
  where id = (
    select id from public.profiles
    where username = username_input
    limit 1
  );
  
  return user_email;
end;
$$ language plpgsql security definer;

--------------------------------------------------------------------------------
-- 2. ATTENDANCE SYSTEM
--------------------------------------------------------------------------------

create table public.classes (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    description text,
    created_by uuid references auth.users(id),
    created_at timestamptz default now()
);

create table public.class_members (
    id uuid primary key default uuid_generate_v4(),
    class_id uuid references public.classes(id) on delete cascade,
    user_id uuid references auth.users(id) on delete cascade,
    joined_at timestamptz default now(),
    unique(class_id, user_id)
);

create table public.attendance_status (
    id uuid primary key default uuid_generate_v4(),
    code text unique not null,
    label text not null,
    color text default '#888888',
    is_active boolean default true
);

-- Seed default statuses (Can be done via migration, but here for reference)
-- insert into attendance_status (code, label) values ('present', 'Hadir'), ('late', 'Terlambat'), ('sick', 'Sakit'), ('absent', 'Alpa');

create table public.attendance (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id),
    class_id uuid references public.classes(id),
    status_id uuid references public.attendance_status(id),
    date date not null default current_date,
    check_in_time timestamptz default now(),
    status_id uuid references public.attendance_status(id),
    note text,
    created_at timestamptz default now(),
    unique(user_id, class_id, date)
);

--------------------------------------------------------------------------------
-- 3. IMPOSTOR GAME
--------------------------------------------------------------------------------

create table public.game_rooms (
    id uuid primary key default uuid_generate_v4(),
    class_id uuid references public.classes(id) on delete cascade,
    created_by uuid references auth.users(id),
    status text check (status in ('waiting', 'playing', 'finished')) default 'waiting',
    impostor_count int default 1,
    -- Keyword logic: We can store it here but need strict RLS or separate table.
    -- To simplify, we keep it here but RLS will hide this row or column if possible.
    -- Since PG RLS on columns is tricky, we use a separate table for the secret.
    created_at timestamptz default now()
);

create table public.game_secrets (
    game_id uuid primary key references public.game_rooms(id) on delete cascade,
    keyword text not null
);

create table public.game_players (
    id uuid primary key default uuid_generate_v4(),
    game_id uuid references public.game_rooms(id) on delete cascade not null,
    user_id uuid references auth.users(id) on delete cascade not null,
    role text check (role in ('impostor', 'crewmate')),
    is_alive boolean default true,
    joined_at timestamptz default now(),
    unique(game_id, user_id)
);

create table public.game_guesses (
    id uuid primary key default uuid_generate_v4(),
    game_id uuid references public.game_rooms(id) on delete cascade not null,
    guesser_id uuid references auth.users(id) not null,
    target_id uuid references auth.users(id) not null,
    created_at timestamptz default now()
);

create table public.game_clues (
    id uuid primary key default uuid_generate_v4(),
    game_id uuid references public.game_rooms(id) on delete cascade not null,
    author_id uuid references auth.users(id) not null,
    content text not null,
    created_at timestamptz default now()
);

--------------------------------------------------------------------------------
-- 4. RLS POLICIES
--------------------------------------------------------------------------------

-- Enable RLS
alter table public.roles enable row level security;
alter table public.user_roles enable row level security;
alter table public.profiles enable row level security;
alter table public.classes enable row level security;
alter table public.class_members enable row level security;
alter table public.attendance_status enable row level security;
alter table public.attendance enable row level security;
alter table public.game_rooms enable row level security;
alter table public.game_secrets enable row level security;
alter table public.game_players enable row level security;
alter table public.game_guesses enable row level security;
alter table public.game_clues enable row level security;

-- ROLES: Read-only for authenticated, Admin write
create policy "Roles are viewable by everyone" on public.roles for select using (true);
create policy "Admin can manage roles" on public.roles for all using (public.has_role('admin'));

-- USER_ROLES
create policy "Users can view their own roles" on public.user_roles for select using (auth.uid() = user_id);
create policy "Admins/Teachers can view all user roles" on public.user_roles for select using (public.has_role('admin') or public.has_role('teacher'));
create policy "Admin can manage user roles" on public.user_roles for all using (public.has_role('admin'));

-- PROFILES
create policy "Profiles are viewable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- CLASSES
create policy "Classes viewable by members and teachers/admins" on public.classes for select
using (
  public.has_role('admin') or public.has_role('teacher') or
  exists (select 1 from class_members cm where cm.class_id = id and cm.user_id = auth.uid())
);
create policy "Teachers/Admins can create classes" on public.classes for all using (public.has_role('admin') or public.has_role('teacher'));

-- CLASS MEMBERS
create policy "View class members" on public.class_members for select
using (
  public.has_role('admin') or public.has_role('teacher') or
  exists (select 1 from class_members cm where cm.class_id = class_members.class_id and cm.user_id = auth.uid())
);
create policy "Manage class members" on public.class_members for all using (public.has_role('admin') or public.has_role('teacher'));

-- ATTENDANCE STATUS
create policy "View attendance status" on public.attendance_status for select using (true);
create policy "Manage attendance status" on public.attendance_status for all using (public.has_role('admin') or public.has_role('teacher'));

-- ATTENDANCE
-- Student: View own, Create (Check-in)
-- Teacher/Admin: View all, Update, Delete
create policy "Student view own attendance" on public.attendance for select using (auth.uid() = user_id);
create policy "Teacher/Admin view all attendance" on public.attendance for select using (public.has_role('admin') or public.has_role('teacher'));

create policy "Student can submit attendance" on public.attendance for insert with check (auth.uid() = user_id);
-- prevent student from editing? Yes, only insert.
create policy "Teacher/Admin can manage attendance" on public.attendance for all using (public.has_role('admin') or public.has_role('teacher'));


-- GAME ROOMS
create policy "View game rooms" on public.game_rooms for select using (true); -- Maybe restrict to class members?
create policy "Teacher/Admin manage game rooms" on public.game_rooms for all using (public.has_role('admin') or public.has_role('teacher'));

-- GAME SECRETS (KEYWORD)
-- Visible to: Creator (Teacher) AND Crewmates (Non-Impostors) of that game
-- Impostor MUST NOT see this.
create policy "Teacher see secrets" on public.game_secrets for select using (
    exists (select 1 from game_rooms gr where gr.id = game_id and gr.created_by = auth.uid())
    or public.has_role('admin')
    or public.has_role('teacher')
);
create policy "Crewmates see secrets" on public.game_secrets for select using (
    exists (
        select 1 from game_players gp
        where gp.game_id = game_secrets.game_id
        and gp.user_id = auth.uid()
        and gp.role = 'crewmate'
    )
);

-- GAME PLAYERS
create policy "View game players" on public.game_players for select using (true);
create policy "Join game" on public.game_players for insert with check (auth.uid() = user_id); -- Students join
create policy "Teacher manage players" on public.game_players for all using (public.has_role('admin') or public.has_role('teacher'));

-- GAME GUESSES
create policy "View guesses" on public.game_guesses for select using (true);
create policy "Submit guess" on public.game_guesses for insert with check (auth.uid() = guesser_id);

-- GAME CLUES
create policy "View clues" on public.game_clues for select using (true);
create policy "Submit clue" on public.game_clues for insert with check (auth.uid() = author_id);

--------------------------------------------------------------------------------
-- 5. FAKEIT GAME
--------------------------------------------------------------------------------

-- Fakeit Categories
create table public.fakeit_categories (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  icon text default '🎯',
  is_active boolean default true,
  created_at timestamptz default now()
);

-- Fakeit Questions
create table public.fakeit_questions (
  id uuid primary key default uuid_generate_v4(),
  category_id uuid references public.fakeit_categories(id) on delete cascade,
  question text not null,
  created_at timestamptz default now()
);

-- Fakeit Game Rooms
create table public.fakeit_rooms (
  id uuid primary key default uuid_generate_v4(),
  code text unique not null,
  host_id uuid references auth.users(id),
  category_id uuid references public.fakeit_categories(id),
  question_id uuid references public.fakeit_questions(id),
  ai_question text,
  status text default 'waiting' check (status in ('waiting', 'question', 'answer', 'discussion', 'voting', 'reveal', 'finished')),
  faker_count int default 1,
  phase_ends_at timestamptz,
  created_at timestamptz default now()
);

-- Fakeit Players
create table public.fakeit_players (
  id uuid primary key default uuid_generate_v4(),
  room_id uuid references public.fakeit_rooms(id) on delete cascade,
  user_id uuid references auth.users(id),
  is_faker boolean default false,
  answer text,
  answered_at timestamptz,
  status text default 'online' check (status in ('online', 'afk', 'quit')),
  last_seen timestamptz default now(),
  joined_at timestamptz default now(),
  unique(room_id, user_id)
);

-- Fakeit Votes
create table public.fakeit_votes (
  id uuid primary key default uuid_generate_v4(),
  room_id uuid references public.fakeit_rooms(id) on delete cascade,
  voter_id uuid references auth.users(id),
  suspect_id uuid references auth.users(id),
  created_at timestamptz default now(),
  unique(room_id, voter_id)
);

-- RLS for Fakeit
alter table public.fakeit_categories enable row level security;
alter table public.fakeit_questions enable row level security;
alter table public.fakeit_rooms enable row level security;
alter table public.fakeit_players enable row level security;
alter table public.fakeit_votes enable row level security;

create policy "fakeit_categories_read" on public.fakeit_categories for select using (true);
create policy "fakeit_questions_read" on public.fakeit_questions for select using (true);
create policy "fakeit_rooms_read" on public.fakeit_rooms for select using (true);
create policy "fakeit_rooms_insert" on public.fakeit_rooms for insert with check (auth.uid() = host_id);
create policy "fakeit_rooms_update" on public.fakeit_rooms for update using (auth.uid() = host_id);
create policy "fakeit_players_read" on public.fakeit_players for select using (true);
create policy "fakeit_players_insert" on public.fakeit_players for insert with check (auth.uid() = user_id);
create policy "fakeit_players_update" on public.fakeit_players for update using (auth.uid() = user_id);
create policy "fakeit_votes_read" on public.fakeit_votes for select using (true);
create policy "fakeit_votes_insert" on public.fakeit_votes for insert with check (auth.uid() = voter_id);

-- Seed Fakeit Categories
insert into public.fakeit_categories (name, icon) values
  ('Makanan', '🍔'),
  ('Tempat', '🌍'),
  ('Hewan', '🐾'),
  ('Film & Musik', '🎬'),
  ('Sekolah', '📚'),
  ('Teknologi', '💻');

-- Seed Fakeit Questions
insert into public.fakeit_questions (category_id, question)
select c.id, q.question from (values
  ('Makanan', 'Makanan apa yang paling enak dimakan saat hujan?'),
  ('Makanan', 'Makanan apa yang bikin kamu nostalgia masa kecil?'),
  ('Makanan', 'Kalau punya uang 20rb, kamu beli makanan apa?'),
  ('Makanan', 'Makanan apa yang kamu makan hampir setiap hari?'),
  ('Makanan', 'Street food favorit kamu apa?'),
  ('Tempat', 'Tempat mana yang pengen banget kamu kunjungi?'),
  ('Tempat', 'Tempat favorit kamu untuk nongkrong sama temen?'),
  ('Tempat', 'Kalau bisa teleport, mau ke mana sekarang?'),
  ('Tempat', 'Tempat paling memorable yang pernah kamu kunjungi?'),
  ('Hewan', 'Kalau jadi hewan, kamu mau jadi apa?'),
  ('Hewan', 'Hewan apa yang paling lucu menurutmu?'),
  ('Hewan', 'Hewan peliharaan impianmu apa?'),
  ('Hewan', 'Hewan apa yang paling kamu takutin?'),
  ('Film & Musik', 'Film apa yang bisa kamu tonton berkali-kali?'),
  ('Film & Musik', 'Lagu apa yang selalu bikin kamu semangat?'),
  ('Film & Musik', 'Genre musik favoritmu apa?'),
  ('Film & Musik', 'Artis/band favorit kamu siapa?'),
  ('Sekolah', 'Mata pelajaran apa yang paling kamu suka?'),
  ('Sekolah', 'Guru seperti apa yang paling berkesan?'),
  ('Sekolah', 'Momen paling memorable di sekolah?'),
  ('Sekolah', 'Kegiatan ekstrakurikuler favorit kamu?'),
  ('Teknologi', 'Aplikasi HP apa yang paling sering kamu buka?'),
  ('Teknologi', 'Gadget impianmu apa?'),
  ('Teknologi', 'Social media mana yang paling aktif kamu pakai?'),
  ('Teknologi', 'Game HP/PC favorit kamu apa?')
) as q(category, question)
join public.fakeit_categories c on c.name = q.category;
