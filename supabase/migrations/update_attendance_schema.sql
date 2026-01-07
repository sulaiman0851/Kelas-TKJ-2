-- Add missing columns to attendance table if they don't exist
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS student_id INTEGER REFERENCES public.student_directory(id) ON DELETE CASCADE;
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS status_id INTEGER REFERENCES public.attendance_status(id);
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS class_id UUID;
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS date DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS check_in_time TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL;
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS note TEXT;

-- IMPORTANT: Make user_id and class_id nullable because they are optional in the new system
ALTER TABLE public.attendance ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.attendance ALTER COLUMN class_id DROP NOT NULL;

-- Ensure unique record per student per day
ALTER TABLE public.attendance ADD CONSTRAINT attendance_student_date_unique UNIQUE (student_id, date);

-- Enable RLS
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- Reset policies for clarity
DROP POLICY IF EXISTS "Attendance viewable by everyone" ON public.attendance;
DROP POLICY IF EXISTS "Authenticated users can insert their own attendance" ON public.attendance;
DROP POLICY IF EXISTS "Admins and teachers can update attendance" ON public.attendance;

-- New cleaner policies
CREATE POLICY "Attendance viewable by everyone" ON public.attendance FOR SELECT USING (true);

CREATE POLICY "Admins and teachers full access" ON public.attendance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'teacher')
        )
    );

CREATE POLICY "Students can insert their own" ON public.attendance
    FOR INSERT WITH CHECK (
        auth.uid() = user_id
    );
