-- DEV ONLY — "Confirm email = OFF" equivalent at the DB level (the auth config
-- toggle is not reachable from the MCP tools). Marks every new auth user as
-- email-confirmed on insert so they can sign in immediately after sign up.
--
-- PRODUCTION: drop this trigger + function and manage confirmation from the
-- Supabase Dashboard (Authentication > Providers > Email > Confirm email).
--   drop trigger if exists dev_auto_confirm_email_trigger on auth.users;
--   drop function if exists public.dev_auto_confirm_email();
create or replace function public.dev_auto_confirm_email()
returns trigger
language plpgsql
security definer
set search_path = auth
as $$
begin
  if new.email_confirmed_at is null then
    new.email_confirmed_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists dev_auto_confirm_email_trigger on auth.users;
create trigger dev_auto_confirm_email_trigger
  before insert on auth.users
  for each row execute function public.dev_auto_confirm_email();
