-- ============================================================================
-- FIX RLS POLICY: QR ATTENDANCE TOKENS
-- ============================================================================
-- Purpose: Allow admins/teachers to generate QR tokens and everyone to verify.
-- Date: 2026-01-12
-- ============================================================================

-- Enable RLS
ALTER TABLE public.qr_attendance_tokens ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Anyone can view QR tokens" ON public.qr_attendance_tokens;
DROP POLICY IF EXISTS "Admins and teachers can manage QR tokens" ON public.qr_attendance_tokens;

-- 1. Anyone can view tokens (required for verification during scanning)
CREATE POLICY "Anyone can view QR tokens"
ON public.qr_attendance_tokens
FOR SELECT
USING (true);

-- 2. Admins and Teachers can do everything (Insert, Delete, Update)
CREATE POLICY "Admins and teachers can manage QR tokens"
ON public.qr_attendance_tokens
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'teacher')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name IN ('admin', 'teacher')
    )
);

-- ============================================================================
-- DONE! ✅
-- ============================================================================
