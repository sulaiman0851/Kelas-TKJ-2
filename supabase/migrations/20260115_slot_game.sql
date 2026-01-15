-- 1. Balance & Points
create table if not exists public.user_wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance decimal(12,2) default 0.00,
  points int default 0,
  updated_at timestamptz default now()
);

-- 2. Slot Settings
create table if not exists public.slot_settings (
  id int primary key default 1,
  hoki_percentage int default 30, -- 1-100%
  point_per_game int default 10,
  point_exchange_rate int default 100, -- 100 points = 1 balance
  is_active boolean default true,
  updated_at timestamptz default now(),
  constraint single_row check (id = 1)
);

-- Seed defaults
insert into public.slot_settings (id, hoki_percentage, point_per_game, point_exchange_rate)
values (1, 30, 10, 100)
on conflict (id) do nothing;

-- 3. Top-Up Requests
create table if not exists public.topup_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade,
  amount decimal(12,2) not null,
  status text check (status in ('pending', 'approved', 'rejected')) default 'pending',
  created_at timestamptz default now()
);

-- 4. Point History
create table if not exists public.point_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  amount int not null,
  type text check (type in ('earn', 'exchange')),
  description text,
  created_at timestamptz default now()
);

-- RLS
alter table public.user_wallets enable row level security;
alter table public.slot_settings enable row level security;
alter table public.topup_history enable row level security;
alter table public.point_history enable row level security;

-- Policies
DO $$ BEGIN
    create policy "Users can view own wallet" on public.user_wallets for select using (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Users can update own wallet" on public.user_wallets for update using (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Admin can manage all wallets" on public.user_wallets for all using (public.has_role('admin'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Everyone can view slot settings" on public.slot_settings for select using (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Admin can manage slot settings" on public.slot_settings for all using (public.has_role('admin'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Users can view own topup history" on public.topup_history for select using (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Users can insert topup history" on public.topup_history for insert with check (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Admin can manage topup history" on public.topup_history for all using (public.has_role('admin'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Users can view own point history" on public.point_history for select using (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Users can insert own point history" on public.point_history for insert with check (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    create policy "Admin can manage point history" on public.point_history for all using (public.has_role('admin'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Trigger to create wallet on signup
create or replace function public.handle_new_user_wallet()
returns trigger as $$
begin
  insert into public.user_wallets (user_id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

DO $$ BEGIN
    create trigger on_auth_user_created_wallet
      after insert on auth.users
      for each row execute procedure public.handle_new_user_wallet();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Backfill for existing users
insert into public.user_wallets (user_id)
select id from auth.users
on conflict (user_id) do nothing;
