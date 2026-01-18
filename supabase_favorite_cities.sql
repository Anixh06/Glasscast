-- SQL Script to create favorite_cities table in Supabase
-- Run this in the Supabase SQL Editor

-- Create the favorite_cities table
CREATE TABLE IF NOT EXISTS public.favorite_cities (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    country TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    CONSTRAINT unique_user_city UNIQUE (user_id, name, country)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.favorite_cities ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own favorite cities
CREATE POLICY "Users can view their own favorite cities"
ON public.favorite_cities
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own favorite cities
CREATE POLICY "Users can insert their own favorite cities"
ON public.favorite_cities
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own favorite cities
CREATE POLICY "Users can delete their own favorite cities"
ON public.favorite_cities
FOR DELETE
USING (auth.uid() = user_id);

-- Users can update their own favorite cities
CREATE POLICY "Users can update their own favorite cities"
ON public.favorite_cities
FOR UPDATE
USING (auth.uid() = user_id);

-- Create an index for faster queries
CREATE INDEX IF NOT EXISTS idx_favorite_cities_user_id
ON public.favorite_cities(user_id);

-- Create an index for ordering by added_at
CREATE INDEX IF NOT EXISTS idx_favorite_cities_added_at
ON public.favorite_cities(added_at DESC);

-- Optional: Enable realtime for real-time updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.favorite_cities;

-- Add comments for documentation
COMMENT ON TABLE public.favorite_cities IS 'Stores user favorite cities for weather tracking';
COMMENT ON COLUMN public.favorite_cities.user_id IS 'Reference to the authenticated user';
COMMENT ON COLUMN public.favorite_cities.added_at IS 'Timestamp when the city was added to favorites';

