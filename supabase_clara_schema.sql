-- Clara Financas: tabela sincronizada, isolada por usuario autenticado.
-- Execute no SQL Editor do seu projeto Supabase.

create table if not exists public.clara_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{"accounts":[],"transactions":[],"budgets":[],"goals":[]}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.clara_data enable row level security;

-- Remove/recria politicas para que este script possa ser executado novamente.
drop policy if exists "Users can read own Clara data" on public.clara_data;
drop policy if exists "Users can insert own Clara data" on public.clara_data;
drop policy if exists "Users can update own Clara data" on public.clara_data;

create policy "Users can read own Clara data"
  on public.clara_data for select to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own Clara data"
  on public.clara_data for insert to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own Clara data"
  on public.clara_data for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

revoke all on public.clara_data from anon;
grant select, insert, update on public.clara_data to authenticated;
