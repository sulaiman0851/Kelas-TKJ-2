-- Event Attendance System
-- For special events/occasions attendance tracking

-- Events Table
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    location TEXT,
    organizer TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Event Attendance Records
CREATE TABLE IF NOT EXISTS public.event_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    student_id INTEGER REFERENCES public.student_directory(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'Hadir' CHECK (status IN ('Hadir', 'Tidak Hadir', 'Izin', 'Sakit')),
    check_in_time TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    note TEXT,
    recorded_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(event_id, student_id)
);

-- Enable RLS
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_attendance ENABLE ROW LEVEL SECURITY;

-- Policies for events
CREATE POLICY "Events viewable by everyone" ON public.events FOR SELECT USING (true);

CREATE POLICY "Admins and teachers can manage events" ON public.events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'teacher')
        )
    );

-- Policies for event_attendance
CREATE POLICY "Event attendance viewable by everyone" ON public.event_attendance FOR SELECT USING (true);

CREATE POLICY "Admins and teachers can manage event attendance" ON public.event_attendance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'teacher')
        )
    );

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(event_date);
CREATE INDEX IF NOT EXISTS idx_event_attendance_event ON public.event_attendance(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendance_student ON public.event_attendance(student_id);

-- Event Participants (Custom student selection per event)
CREATE TABLE IF NOT EXISTS public.event_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    student_id INTEGER REFERENCES public.student_directory(id) ON DELETE CASCADE NOT NULL,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(event_id, student_id)
);

-- Enable RLS for event_participants
ALTER TABLE public.event_participants ENABLE ROW LEVEL SECURITY;

-- Policies for event_participants
CREATE POLICY "Event participants viewable by everyone" ON public.event_participants FOR SELECT USING (true);

CREATE POLICY "Admins and teachers can manage event participants" ON public.event_participants
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'teacher')
        )
    );

-- Index for event_participants
CREATE INDEX IF NOT EXISTS idx_event_participants_event ON public.event_participants(event_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_student ON public.event_participants(student_id);
