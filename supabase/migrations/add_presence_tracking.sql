-- ============================================================================
-- FAKEIT PRESENCE SYSTEM - DATABASE MIGRATION
-- ============================================================================
-- Run this in Supabase SQL Editor to add presence tracking
-- Date: 2026-01-06
-- ============================================================================

-- Add presence tracking columns to fakeit_players table
ALTER TABLE public.fakeit_players 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'online' 
  CHECK (status IN ('online', 'afk', 'quit')),
ADD COLUMN IF NOT EXISTS last_seen timestamptz DEFAULT now();

-- Create index for faster queries on status
CREATE INDEX IF NOT EXISTS idx_fakeit_players_status 
ON public.fakeit_players(status);

-- Create index for last_seen (for future timeout detection)
CREATE INDEX IF NOT EXISTS idx_fakeit_players_last_seen 
ON public.fakeit_players(last_seen);

-- Update existing players to have default status
UPDATE public.fakeit_players 
SET status = 'online', 
    last_seen = now() 
WHERE status IS NULL;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if columns exist
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'fakeit_players' 
  AND column_name IN ('status', 'last_seen');

-- Check current player statuses
SELECT 
  p.id,
  prof.username,
  p.status,
  p.last_seen,
  p.joined_at
FROM fakeit_players p
LEFT JOIN profiles prof ON p.user_id = prof.id
ORDER BY p.joined_at DESC;

-- ============================================================================
-- DONE! ✅
-- ============================================================================
-- Players will now have:
-- - status: 'online' | 'afk' | 'quit'
-- - last_seen: timestamp of last activity
-- ============================================================================
