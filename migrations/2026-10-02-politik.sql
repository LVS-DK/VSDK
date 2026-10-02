-- Politik-fanen: sparekatalog, samlet budget og noter pr. værested,
-- samt datoen for kommunens eget sparekatalog, som gælder hele kommunen.
-- Køres i Supabase SQL Editor før den nye version af index.html lægges op.
-- Sikker at køre flere gange.

-- '', 'Ja' eller 'Nej'
alter table vaeresteder add column if not exists sparekatalog_for text;
-- Årstal som tekst, fx '2019, 2023'
alter table vaeresteder add column if not exists sparekatalog_aar text;
alter table vaeresteder add column if not exists samlet_budget numeric;
alter table vaeresteder add column if not exists politik_noter text;

alter table kommune_info add column if not exists sparekatalog_dato date;
