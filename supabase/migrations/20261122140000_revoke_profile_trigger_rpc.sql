-- The trigger is invoked by Postgres after an auth.users insert.
-- It must not be callable as an RPC by anonymous or authenticated clients.
revoke all on function public.create_profile_for_new_user()
  from public, anon, authenticated;
