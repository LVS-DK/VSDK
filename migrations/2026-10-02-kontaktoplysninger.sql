-- Kontaktoplysninger pr. værested: leder, kontaktperson og hvem vi helst kontakter.
-- Køres i Supabase SQL Editor før den nye version af index.html lægges op.
-- Sikker at køre flere gange.

alter table vaeresteder add column if not exists leder_navn text;
alter table vaeresteder add column if not exists leder_telefon text;
alter table vaeresteder add column if not exists leder_email text;
alter table vaeresteder add column if not exists leder_noter text;

alter table vaeresteder add column if not exists kontakt_navn text;
alter table vaeresteder add column if not exists kontakt_titel text;
alter table vaeresteder add column if not exists kontakt_telefon text;
alter table vaeresteder add column if not exists kontakt_email text;
alter table vaeresteder add column if not exists kontakt_noter text;

-- '', 'Leder' eller 'Kontaktperson'
alter table vaeresteder add column if not exists foretrukken_kontakt text;
