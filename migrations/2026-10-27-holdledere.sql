-- Holdledere pr. værested. Bruges i sportsappen på /sport.html.
-- Et værested kan have flere holdledere.
-- Køres i Supabase SQL Editor før den nye version af index.html lægges op.
-- Sikker at køre flere gange. Ændrer ikke eksisterende data.

create table if not exists holdledere (
  id uuid primary key default gen_random_uuid(),
  vaerested_id uuid not null references vaeresteder(id) on delete cascade,
  navn text,
  email text,
  telefon text,
  oprettet timestamptz not null default now()
);

create index if not exists holdledere_vaerested_idx on holdledere (vaerested_id);

alter table holdledere enable row level security;

-- Oprettes kun, hvis den ikke findes i forvejen. Ingen sletning, så Supabase
-- ikke advarer om destruktive handlinger.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'holdledere' and policyname = 'holdledere alle'
  ) then
    create policy "holdledere alle" on holdledere
      for all
      using (true)
      with check (true);
  end if;
end $$;
