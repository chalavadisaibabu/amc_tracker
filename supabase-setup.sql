-- AMC Tracker: database setup for Supabase
-- Run this once in Supabase: SQL Editor > New query > paste > Run.
-- Before running, replace the email address in step 2 with your own.
-- All tables start with amc_ so they don't touch anything else in this project.

-- 1. Tables. Each record is stored as JSON in the "data" column.
create table if not exists public.amc_contracts  (id text primary key, data jsonb not null default '{}'::jsonb, updated_at timestamptz not null default now());
create table if not exists public.amc_quotations (id text primary key, data jsonb not null default '{}'::jsonb, updated_at timestamptz not null default now());
create table if not exists public.amc_invoices   (id text primary key, data jsonb not null default '{}'::jsonb, updated_at timestamptz not null default now());
create table if not exists public.amc_settings   (id text primary key, data jsonb not null default '{}'::jsonb, updated_at timestamptz not null default now());

-- 2. Team list: only these email addresses can open the AMC data, even if someone else has a login.
create table if not exists public.amc_team (email text primary key);
insert into public.amc_team (email) values
  ('your-email@iotiq.co.in')   -- add more people as: ('name@iotiq.co.in'), on new lines
on conflict do nothing;

create or replace function public.amc_is_team_member()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.amc_team where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- 3. Row level security: signed-in team members can read and write; nobody else can.
alter table public.amc_contracts  enable row level security;
alter table public.amc_quotations enable row level security;
alter table public.amc_invoices   enable row level security;
alter table public.amc_settings   enable row level security;
alter table public.amc_team       enable row level security;  -- no policies: the team list is not readable from the app

drop policy if exists "amc team access" on public.amc_contracts;
drop policy if exists "amc team access" on public.amc_quotations;
drop policy if exists "amc team access" on public.amc_invoices;
drop policy if exists "amc team access" on public.amc_settings;
create policy "amc team access" on public.amc_contracts  for all to authenticated using (public.amc_is_team_member()) with check (public.amc_is_team_member());
create policy "amc team access" on public.amc_quotations for all to authenticated using (public.amc_is_team_member()) with check (public.amc_is_team_member());
create policy "amc team access" on public.amc_invoices   for all to authenticated using (public.amc_is_team_member()) with check (public.amc_is_team_member());
create policy "amc team access" on public.amc_settings   for all to authenticated using (public.amc_is_team_member()) with check (public.amc_is_team_member());

-- 4. Live updates, so changes made by one person show up for everyone without reloading.
do $$
begin
  begin alter publication supabase_realtime add table public.amc_contracts;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.amc_quotations; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.amc_invoices;   exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.amc_settings;   exception when duplicate_object then null; end;
end $$;
