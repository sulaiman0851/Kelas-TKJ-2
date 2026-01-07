-- Create subjects table
CREATE TABLE IF NOT EXISTS public.subjects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    teacher_name TEXT,
    color TEXT DEFAULT 'blue',
    icon TEXT, -- Lucide icon name or emoji
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create schedule table
CREATE TABLE IF NOT EXISTS public.schedule (
    id SERIAL PRIMARY KEY,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0 = Monday, 6 = Sunday
    subject_id INTEGER REFERENCES public.subjects(id) ON DELETE CASCADE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Subjects are viewable by everyone" ON public.subjects FOR SELECT USING (true);
CREATE POLICY "Schedule is viewable by everyone" ON public.schedule FOR SELECT USING (true);

-- Admin only modification
CREATE POLICY "Only admins can modify subjects" ON public.subjects
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.name = 'admin'
        )
    );

CREATE POLICY "Only admins can modify schedule" ON public.schedule
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.name = 'admin'
        )
    );

-- Add code column to subjects if it doesn't exist
ALTER TABLE public.subjects ADD COLUMN IF NOT EXISTS code TEXT;

-- Clear for fresh seed
TRUNCATE TABLE public.schedule CASCADE;
TRUNCATE TABLE public.subjects CASCADE;

-- Seed Subjects from Image (Code, Full Name, Teacher)
INSERT INTO public.subjects (code, name, teacher_name, color, icon) VALUES
('BIN', 'Bahasa Indonesia', 'HUBBI ELI NADROH, S.Pd', 'blue', 'book'),
('MAT', 'Matematika', 'ANGGRAENY ENDAH CAHYANTI, S.Pd', 'emerald', 'calculator'),
('PPKN', 'PPKN', 'YULIN KARLINA ANGGARINI, S.Pd', 'purple', 'shield'),
('PAI', 'Pend. Agama Islam', 'MAHRUS ALI, S.Pd.I', 'orange', 'moon'),
('BIG', 'Bahasa Inggris', 'JEFRI NUR ARDIYANSYAH, S.Pd', 'rose', 'languages'),
('PENJAS', 'Penjaskes', 'MUKHAMAD KHOLIL, S.Pd', 'red', 'trophy'),
('PKWU', 'Kewirausahaan', 'TATIK KURNIAWATI SALEH, SE', 'yellow', 'briefcase'),
('IPAS', 'IPAS', 'Drs. MESERAN', 'indigo', 'test-tube'),
('KKR', 'KKR', 'WALI KELAS', 'slate', 'users');

-- Seed Schedule (Day 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri)
-- Note: Simplified into 4 blocks of 2 periods to match visual layout
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) 
SELECT 0, id, '07:00:00', '08:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'BIN' UNION ALL
SELECT 0, id, '08:45:00', '10:15:00', 'Lab TKJ' FROM public.subjects WHERE code = 'MAT' UNION ALL
SELECT 0, id, '10:30:00', '12:00:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PPKN' UNION ALL
SELECT 0, id, '13:00:00', '14:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PAI' UNION ALL

SELECT 1, id, '07:00:00', '08:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'BIG' UNION ALL
SELECT 1, id, '08:45:00', '10:15:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PAI' UNION ALL
SELECT 1, id, '10:30:00', '12:00:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PENJAS' UNION ALL
SELECT 1, id, '13:00:00', '14:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PKWU' UNION ALL

SELECT 2, id, '07:00:00', '08:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PPKN' UNION ALL
SELECT 2, id, '08:45:00', '10:15:00', 'Lab TKJ' FROM public.subjects WHERE code = 'IPAS' UNION ALL
SELECT 2, id, '10:30:00', '12:00:00', 'Lab TKJ' FROM public.subjects WHERE code = 'MAT' UNION ALL
SELECT 2, id, '13:00:00', '14:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PAI' UNION ALL

SELECT 3, id, '07:00:00', '08:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'BIG' UNION ALL
SELECT 3, id, '08:45:00', '10:15:00', 'Lab TKJ' FROM public.subjects WHERE code = 'MAT' UNION ALL
SELECT 3, id, '10:30:00', '12:00:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PPKN' UNION ALL
SELECT 3, id, '13:00:00', '14:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'BIN' UNION ALL

SELECT 4, id, '07:00:00', '08:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'PKWU' UNION ALL
SELECT 4, id, '08:45:00', '10:15:00', 'Lab TKJ' FROM public.subjects WHERE code = 'BIG' UNION ALL
SELECT 4, id, '10:30:00', '12:00:00', 'Lab TKJ' FROM public.subjects WHERE code = 'BIN' UNION ALL
SELECT 4, id, '13:00:00', '14:30:00', 'Lab TKJ' FROM public.subjects WHERE code = 'KKR';
