-- Kontaktlog: én linje pr. samtale med et værested (dato + noter).
-- Felterne "Sidste kontakt" og "Hvad talte I om?" på fanen Kontakt skriver hertil.
-- Køres i Supabase SQL Editor før den nye version af index.html lægges op.
-- Sikker at køre flere gange.

create table if not exists kontaktlog (
  id uuid primary key default gen_random_uuid(),
  vaerested_id uuid not null references vaeresteder(id) on delete cascade,
  dato date,
  noter text,
  oprettet timestamptz not null default now()
);

create index if not exists kontaktlog_vaerested_idx on kontaktlog (vaerested_id);

-- Samme adgang som de øvrige tabeller: appen bruger den offentlige anon-nøgle.
alter table kontaktlog enable row level security;

-- Oprettes kun, hvis den ikke findes i forvejen. Ingen sletning, så Supabase
-- ikke advarer om destruktive handlinger.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'kontaktlog' and policyname = 'kontaktlog alle'
  ) then
    create policy "kontaktlog alle" on kontaktlog
      for all
      using (true)
      with check (true);
  end if;
end $$;
