-- Harden dev_auto_confirm_email: empty search_path (best practice for
-- SECURITY DEFINER). The body only assigns NEW.email_confirmed_at and calls
-- now() (pg_catalog), so no qualified-schema references are needed.
create or replace function public.dev_auto_confirm_email()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email_confirmed_at is null then
    new.email_confirmed_at := now();
  end if;
  return new;
end;
$$;

revoke all on function public.dev_auto_confirm_email() from public, anon, authenticated;
