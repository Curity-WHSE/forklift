-- =============================================
-- BBW FORKLIFT INSPECTION – SUPABASE SETUP
-- Run this in Supabase → SQL Editor → New Query
-- =============================================

-- 1. INSPECTIONS TABLE
-- Stores every inspection submission
CREATE TABLE IF NOT EXISTS inspections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  equipment_id TEXT NOT NULL,
  equipment_name TEXT NOT NULL,
  equipment_type TEXT NOT NULL DEFAULT 'forklift',
  operator_name TEXT NOT NULL,
  shift TEXT,
  inspection_date DATE NOT NULL,
  overall_status TEXT NOT NULL CHECK (overall_status IN ('passed', 'failed')),
  failed_items JSONB DEFAULT '[]',
  full_results JSONB DEFAULT '{}',
  notes TEXT,
  submitted_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;

-- Allow anyone to INSERT (operators submitting from QR link don't log in)
CREATE POLICY "Anyone can submit inspections"
  ON inspections FOR INSERT
  WITH CHECK (true);

-- Only authenticated users can read records
CREATE POLICY "Authenticated users can read inspections"
  ON inspections FOR SELECT
  TO authenticated
  USING (true);

-- =============================================
-- 2. PROFILES TABLE
-- Auto-created when users sign up
-- =============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'viewer',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- 3. USEFUL QUERIES (for reference)
-- =============================================

-- View all today's inspections:
-- SELECT * FROM inspections WHERE inspection_date = CURRENT_DATE ORDER BY submitted_at DESC;

-- View all failures this week:
-- SELECT equipment_id, operator_name, shift, failed_items, submitted_at
--   FROM inspections
--   WHERE overall_status = 'failed'
--   AND submitted_at >= now() - interval '7 days'
--   ORDER BY submitted_at DESC;

-- Count inspections per equipment this month:
-- SELECT equipment_id, equipment_name, COUNT(*) as total,
--   SUM(CASE WHEN overall_status = 'passed' THEN 1 ELSE 0 END) as passed,
--   SUM(CASE WHEN overall_status = 'failed' THEN 1 ELSE 0 END) as failed
-- FROM inspections
-- WHERE inspection_date >= date_trunc('month', CURRENT_DATE)
-- GROUP BY equipment_id, equipment_name
-- ORDER BY equipment_id;
