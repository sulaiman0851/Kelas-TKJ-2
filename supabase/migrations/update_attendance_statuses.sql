-- Add color column if it doesn't exist
ALTER TABLE public.attendance_status ADD COLUMN IF NOT EXISTS color TEXT DEFAULT 'blue';
-- Ensure code column is present (it seems it is from your error)

-- Clear existing statuses to avoid confusion and re-seed
TRUNCATE TABLE public.attendance_status CASCADE;

INSERT INTO public.attendance_status (code, label, color, is_active) VALUES
('H', 'Hadir', 'emerald', true),
('S', 'Sakit (S)', 'yellow', true),
('I', 'Ijin (I)', 'blue', true),
('R', 'Rekom (R)', 'purple', true),
('T', 'Terlambat (T)', 'orange', true),
('A', 'Alpha (A)', 'red', true);
