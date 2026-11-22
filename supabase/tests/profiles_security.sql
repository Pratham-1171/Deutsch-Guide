-- Structural security assertions for the learner profile schema.
-- Run with: supabase test db
do $$
begin
  if not exists (
    select 1
    from pg_class
    where oid = 'public.profiles'::regclass
      and relrowsecurity
  ) then
    raise exception 'RLS must be enabled on public.profiles';
  end if;

  if (
    select count(*)
    from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
      and roles @> array['authenticated']::name[]
  ) <> 2 then
    raise exception 'Expected exactly two authenticated profile policies';
  end if;

  if has_table_privilege('anon', 'public.profiles', 'SELECT') then
    raise exception 'anon must not be able to select profiles';
  end if;

  if has_function_privilege(
    'anon',
    'public.create_profile_for_new_user()',
    'EXECUTE'
  ) or has_function_privilege(
    'authenticated',
    'public.create_profile_for_new_user()',
    'EXECUTE'
  ) then
    raise exception 'Client roles must not execute the profile trigger function';
  end if;

  if has_column_privilege(
    'authenticated',
    'public.profiles',
    'created_at',
    'UPDATE'
  ) or has_column_privilege(
    'authenticated',
    'public.profiles',
    'updated_at',
    'UPDATE'
  ) then
    raise exception 'Clients must not modify profile timestamps';
  end if;
end;
$$;
