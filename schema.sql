-- ========================================================
-- Astys Audio Video Pvt. Ltd. — Unified Database Schema
-- Run this script in the Supabase SQL Editor:
-- https://cnhpywstdyfphcseukls.supabase.co
-- ========================================================

-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- --------------------------------------------------------
-- 1. EXAM RESULTS TABLE (Stores Candidate Assessment Results)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exam_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name TEXT NOT NULL,
    ph_no TEXT NOT NULL,
    email TEXT NOT NULL,
    position_applied TEXT NOT NULL,
    exam_title TEXT NOT NULL,
    marks_scored INTEGER NOT NULL,
    percentage NUMERIC(5,2) NOT NULL,
    status TEXT CHECK (status IN ('QUALIFIED', 'NOT QUALIFIED')) NOT NULL
);

-- Applied Indexes for Fast Filtering & Candidate Lookups
CREATE INDEX IF NOT EXISTS idx_exam_results_email ON public.exam_results(email);
CREATE INDEX IF NOT EXISTS idx_exam_results_ph_no ON public.exam_results(ph_no);
CREATE INDEX IF NOT EXISTS idx_exam_results_created_at ON public.exam_results(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_exam_results_exam_title ON public.exam_results(exam_title);

-- Row Level Security (RLS) Configuration
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;

-- Allow anonymous & authenticated candidates to insert exam results
CREATE POLICY "Allow anonymous submission of exam results" 
    ON public.exam_results 
    FOR INSERT 
    TO anon, authenticated 
    WITH CHECK (true);

-- Allow authenticated users (HR/Admin) to select exam results
CREATE POLICY "Allow authenticated read of exam results" 
    ON public.exam_results 
    FOR SELECT 
    TO anon, authenticated 
    USING (true);


-- --------------------------------------------------------
-- 2. POLICY ACKNOWLEDGEMENTS TABLE (Existing Compliance Logs)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.policy_acknowledgements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    record_id TEXT UNIQUE NOT NULL,
    employee_name TEXT NOT NULL,
    employee_id TEXT NOT NULL,
    designation TEXT NOT NULL,
    department TEXT NOT NULL,
    place TEXT NOT NULL,
    policy_version TEXT DEFAULT '1.0',
    signature_type TEXT CHECK (signature_type IN ('draw', 'type')),
    signature_data TEXT NOT NULL,
    read_sections_count INTEGER DEFAULT 21,
    user_agent TEXT
);

CREATE INDEX IF NOT EXISTS idx_ack_employee_id ON public.policy_acknowledgements(employee_id);
CREATE INDEX IF NOT EXISTS idx_ack_created_at ON public.policy_acknowledgements(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ack_department ON public.policy_acknowledgements(department);

ALTER TABLE public.policy_acknowledgements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow policy acknowledgement submission" 
    ON public.policy_acknowledgements 
    FOR INSERT 
    TO anon, authenticated 
    WITH CHECK (true);

CREATE POLICY "Allow read policy acknowledgements" 
    ON public.policy_acknowledgements 
    FOR SELECT 
    TO anon, authenticated 
    USING (true);


-- --------------------------------------------------------
-- 3. CENTRAL EMPLOYEES MASTER TABLE (Unified Employee Record)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    employee_id TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    department TEXT NOT NULL,
    designation TEXT NOT NULL,
    role TEXT DEFAULT 'employee' CHECK (role IN ('employee', 'hr', 'manager', 'admin')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'on_probation', 'resigned', 'terminated')),
    joining_date DATE,
    avatar_url TEXT
);

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated read employees" 
    ON public.employees 
    FOR SELECT 
    TO authenticated 
    USING (true);
