-- ============================================================================
-- ACTIVITY LOGS SYSTEM
-- ============================================================================

-- 1. Create Table
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    category text NOT NULL, -- 'attendance', 'content', 'game', 'admin'
    action text NOT NULL,
    description text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- RLS Policies
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Activity logs are viewable by everyone" ON public.activity_logs
FOR SELECT USING (true);

CREATE POLICY "Anyone authenticated can insert logs" ON public.activity_logs
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 3. Trigger Function for Automatic Logging
CREATE OR REPLACE FUNCTION public.log_system_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_TABLE_NAME = 'attendance') THEN
        INSERT INTO public.activity_logs (user_id, category, action, description)
        VALUES (NEW.user_id, 'attendance', 'check-in', 'Melakukan absensi hari ini');
    
    ELSIF (TG_TABLE_NAME = 'announcements') THEN
        INSERT INTO public.activity_logs (user_id, category, action, description)
        VALUES (NEW.author_id, 'content', 'announcement', 'Memposting pengumuman baru: ' || NEW.title);

    ELSIF (TG_TABLE_NAME = 'assignments') THEN
        INSERT INTO public.activity_logs (user_id, category, action, description)
        VALUES (NEW.author_id, 'content', 'assignment', 'Memposting tugas baru: ' || NEW.title);

    ELSIF (TG_TABLE_NAME = 'game_rooms') THEN
        INSERT INTO public.activity_logs (user_id, category, action, description)
        VALUES (NEW.created_by, 'game', 'create-room', 'Membuat room game baru: ' || NEW.room_name);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Apply Triggers
DROP TRIGGER IF EXISTS on_attendance_created ON public.attendance;
CREATE TRIGGER on_attendance_created
    AFTER INSERT ON public.attendance
    FOR EACH ROW EXECUTE FUNCTION public.log_system_activity();

DROP TRIGGER IF EXISTS on_announcement_created ON public.announcements;
CREATE TRIGGER on_announcement_created
    AFTER INSERT ON public.announcements
    FOR EACH ROW EXECUTE FUNCTION public.log_system_activity();

DROP TRIGGER IF EXISTS on_assignment_created ON public.assignments;
CREATE TRIGGER on_assignment_created
    AFTER INSERT ON public.assignments
    FOR EACH ROW EXECUTE FUNCTION public.log_system_activity();

DROP TRIGGER IF EXISTS on_game_room_created ON public.game_rooms;
CREATE TRIGGER on_game_room_created
    AFTER INSERT ON public.game_rooms
    FOR EACH ROW EXECUTE FUNCTION public.log_system_activity();
