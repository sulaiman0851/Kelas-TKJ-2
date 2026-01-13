-- ============================================================================
-- UPDATE SCHEDULE: PEKAN GANJIL 2025 (XII TKJ 2)
-- ============================================================================
-- Based on: JADWAL KELAS XII TKJ 2 PEKAN GANJIL 2025-1.png
-- Date: 2026-01-12
-- ============================================================================

-- Clear existing schedule for fresh update
TRUNCATE TABLE public.schedule;

-- Insert New Schedule (Day 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri)
-- Slots: 1-2 (07:00), 3-4 (08:45), 5-6 (10:30), 7-8 (13:00)

-- SENIN (0)
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) 
SELECT 0, id, '07:00:00'::TIME, '08:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PPKN' UNION ALL
SELECT 0, id, '08:45:00'::TIME, '10:15:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PKWU' UNION ALL
SELECT 0, id, '10:30:00'::TIME, '12:00:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PAI' UNION ALL
SELECT 0, id, '13:00:00'::TIME, '14:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'BIG';

-- SELASA (1)
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) 
SELECT 1, id, '07:00:00'::TIME, '08:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PAI' UNION ALL
SELECT 1, id, '08:45:00'::TIME, '10:15:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PENJAS' UNION ALL
SELECT 1, id, '10:30:00'::TIME, '12:00:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'MAT' UNION ALL
SELECT 1, id, '13:00:00'::TIME, '14:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PPKN';

-- RABU (2)
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) 
SELECT 2, id, '07:00:00'::TIME, '08:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'BIG' UNION ALL
SELECT 2, id, '08:45:00'::TIME, '10:15:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'MAT' UNION ALL
SELECT 2, id, '10:30:00'::TIME, '12:00:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PPKN' UNION ALL
SELECT 2, id, '13:00:00'::TIME, '14:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'BIN';

-- KAMIS (3)
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) 
SELECT 3, id, '07:00:00'::TIME, '08:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'BIG' UNION ALL
SELECT 3, id, '08:45:00'::TIME, '10:15:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'IPAS' UNION ALL
SELECT 3, id, '10:30:00'::TIME, '12:00:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'BIN' UNION ALL
SELECT 3, id, '13:00:00'::TIME, '14:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PKWU';

-- JUMAT (4)
INSERT INTO public.schedule (day_of_week, subject_id, start_time, end_time, room) 
SELECT 4, id, '07:00:00'::TIME, '08:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'MAT' UNION ALL
SELECT 4, id, '08:45:00'::TIME, '10:15:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'PAI' UNION ALL
SELECT 4, id, '10:30:00'::TIME, '12:00:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'BIN' UNION ALL
SELECT 4, id, '13:00:00'::TIME, '14:30:00'::TIME, 'Lab TKJ' FROM public.subjects WHERE code = 'KKR';

-- ============================================================================
-- DONE! ✅
-- ============================================================================
