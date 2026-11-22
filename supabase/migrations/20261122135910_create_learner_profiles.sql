-- Phase 4: the first learner-owned application table.
-- The profile row is created by the auth.users trigger; clients cannot insert or delete it.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null
    check (pg_catalog.char_length(pg_catalog.btrim(display_name)) between 1 and 80),
  current_level text
    check (current_level is null or current_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  created_at timestamptz not null default pg_catalog.now(),
  updated_at timestamptz not null default pg_catalog.now()
);

alter table public.profiles enable row level security;

create policy "Learners can read their own profile"
  on public.profiles
  for select
  to authenticated
  using (id = (select auth.uid()));

create policy "Learners can update their own profile"
  on public.profiles
  for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

revoke all on table public.profiles from anon, authenticated;
grant usage on schema public to authenticated;
grant select on table public.profiles to authenticated;
grant update (display_name, current_level) on table public.profiles to authenticated;

create or replace function public.touch_profile_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := pg_catalog.now();
  return new;
end;
$$;

revoke all on function public.touch_profile_updated_at() from public;

create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row
  execute function public.touch_profile_updated_at();

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  safe_display_name text;
begin
  safe_display_name := coalesce(
    nullif(
      pg_catalog.left(
        pg_catalog.btrim(new.raw_user_meta_data ->> 'display_name'),
        80
      ),
      ''
    ),
    nullif(
      pg_catalog.left(
        pg_catalog.split_part(coalesce(new.email, ''), '@', 1),
        80
      ),
      ''
    ),
    'Learner'
  );

  insert into public.profiles (id, display_name)
  values (new.id, safe_display_name)
  on conflict (id) do nothing;

  return new;
end;
$$;

revoke all on function public.create_profile_for_new_user() from public;

create trigger on_auth_user_created_create_profile
  after insert on auth.users
  for each row
  execute function public.create_profile_for_new_user();

-- Backfill accounts created before this migration was installed.
insert into public.profiles (id, display_name)
select
  users.id,
  coalesce(
    nullif(
      pg_catalog.left(
        pg_catalog.btrim(users.raw_user_meta_data ->> 'display_name'),
        80
      ),
      ''
    ),
    nullif(
      pg_catalog.left(
        pg_catalog.split_part(coalesce(users.email, ''), '@', 1),
        80
      ),
      ''
    ),
    'Learner'
  )
from auth.users as users
on conflict (id) do nothing;
