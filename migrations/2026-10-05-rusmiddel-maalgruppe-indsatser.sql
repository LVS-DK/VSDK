-- Rusmiddelpolitik (afløser fritekstfeltet "Type værested" i brugerfladen),
-- primære målgrupper og indsatser/aktiviteter pr. værested.
-- Kolonnen "type" bliver i databasen med de gamle værdier.
-- Køres i Supabase SQL Editor før den nye version af index.html lægges op.
-- Sikker at køre flere gange.

alter table vaeresteder add column if not exists rusmiddelpolitik text;
alter table vaeresteder add column if not exists rusmiddel_andet text;

-- Flere valg pr. værested, gemt som JSON-liste
alter table vaeresteder add column if not exists maalgruppe jsonb default '[]'::jsonb;
alter table vaeresteder add column if not exists maalgruppe_andet text;
alter table vaeresteder add column if not exists indsatser jsonb default '[]'::jsonb;
alter table vaeresteder add column if not exists indsatser_andet text;
