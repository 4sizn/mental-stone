-- Trigger functions must not be callable through the REST RPC endpoint.
-- Triggers still fire (they run under the table-owner context), so revoking
-- EXECUTE from the API roles only closes the public attack surface.
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.dev_auto_confirm_email() from public, anon, authenticated;
revoke all on function public.set_updated_at() from public, anon, authenticated;
