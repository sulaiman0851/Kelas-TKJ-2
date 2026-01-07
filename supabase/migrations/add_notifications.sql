-- ============================================================================
-- NOTIFICATIONS & ASSIGNMENTS SYSTEM
-- ============================================================================

-- 1. Announcements Table
CREATE TABLE IF NOT EXISTS public.announcements (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    content text NOT NULL,
    type text DEFAULT 'info' CHECK (type IN ('info', 'warning', 'success')),
    author_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- 2. Assignments Table
CREATE TABLE IF NOT EXISTS public.assignments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject text NOT NULL,
    title text NOT NULL,
    description text,
    due_date timestamptz NOT NULL,
    author_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- 3. RLS Policies
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

-- Announcements Policies
CREATE POLICY "Public announcements are viewable by everyone" ON public.announcements
FOR SELECT USING (true);

CREATE POLICY "Admin/Teachers can manage announcements" ON public.announcements
FOR ALL USING (public.has_role('admin') OR public.has_role('teacher'));

-- Assignments Policies
CREATE POLICY "Public assignments are viewable by everyone" ON public.assignments
FOR SELECT USING (true);

CREATE POLICY "Admin/Teachers can manage assignments" ON public.assignments
FOR ALL USING (public.has_role('admin') OR public.has_role('teacher'));
