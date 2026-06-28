-- Self-service account deletion.
--
-- The client cannot call auth.admin.deleteUser (that needs the service_role
-- key), so we expose a SECURITY DEFINER RPC that deletes ONLY the caller's own
-- auth.users row. Deleting the auth user cascades to public.profiles and
-- public.journal_entries (both FK with `on delete cascade`), so this single
-- delete wipes all of the user's data.
create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;
  -- Scoped to auth.uid(): a caller can never delete another user.
  delete from auth.users where id = uid;
end;
$$;

-- Only signed-in users may call it; never anon/public.
revoke all on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;
