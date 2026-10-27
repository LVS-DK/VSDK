-- Postnummer og by som egne felter, samt CVR- og EAN-nummer pr. værested.
-- Køres i Supabase SQL Editor før den nye version af index.html lægges op.
-- Sikker at køre flere gange. Ændrer ikke eksisterende data.

alter table vaeresteder add column if not exists postnr text;
alter table vaeresteder add column if not exists by text;
alter table vaeresteder add column if not exists cvr text;
alter table vaeresteder add column if not exists ean text;
