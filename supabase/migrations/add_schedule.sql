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

-- Seed some TKJ Subjects (Example)
INSERT INTO public.subjects (name, teacher_name, color, icon) VALUES
('Administrasi Sistem Jaringan (ASJ)', 'Pak Budi', 'blue', 'server'),
('Administrasi Infrastruktur Jaringan (AIJ)', 'Bu Ika', 'emerald', 'network'),
('Teknologi Layanan Jaringan (TLJ)', 'Pak Andi', 'purple', 'phone-call'),
('Produk Kreatif & Kewirausahaan (PKK)', 'Bu Siti', 'orange', 'lightbulb'),
('Pendidikan Jasmani (Penjas)', 'Pak Eko', 'red', 'trophy'),
('Bahasa Indonesia', 'Bu Nina', 'rose', 'book');

-- Seed a sample schedule for Monday (day_of_week = 0)
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) VALUES
(0, 1, '07:30:00', '09:00:00', 'Lab TKJ 1'),
(0, 2, '09:15:00', '11:00:00', 'Lab TKJ 1'),
(0, 3, '11:15:00', '12:45:00', 'R. Kelas');
