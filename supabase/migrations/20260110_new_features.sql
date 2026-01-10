-- Resource Hub Table
create table if not exists resources (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  category text not null, -- e.g. 'ISO', 'PDF', 'Config', 'Software'
  file_url text not null,
  download_count int default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_by uuid references auth.users(id)
);

-- Resource Hub Policies
alter table resources enable row level security;
create policy "Anyone can view resources" on resources for select using (true);
create policy "Admins can manage resources" on resources for all using (
  exists (
    select 1 from user_roles
    join roles on user_roles.role_id = roles.id
    where user_roles.user_id = auth.uid()
    and roles.name = 'admin'
  )
);

-- Leaderboard / Gamification
-- We can use a view to calculate points dynamically
create or replace view leaderboard as
  select 
    p.id,
    p.full_name,
    p.avatar_url,
    (
      (select count(*) from blog_posts where author_id = p.id) * 50 + -- 50 pts per blog
      (select count(*) from attendance where student_id = p.id and status_id = (select id from attendance_status where label = 'Hadir')) * 10 -- 10 pts per attendance
    ) as total_points,
    (select count(*) from blog_posts where author_id = p.id) as total_posts,
    (select count(*) from attendance where student_id = p.id and status_id = (select id from attendance_status where label = 'Hadir')) as attendance_count
  from profiles p
  order by total_points desc;

-- QR Attendance Token (Temporary storage for valid QR codes)
create table if not exists qr_attendance_tokens (
  id uuid default uuid_generate_v4() primary key,
  token text unique not null,
  expires_at timestamp with time zone not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
