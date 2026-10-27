-- VALGFRI oprydning: deler de eksisterende adresser op i vej, postnr og by.
-- Kør den kun ÉN gang, og kun efter at have taget en Excel-eksport som sikkerhedskopi.
-- Denne ÆNDRER data i kolonnen adresse. Kør 2026-10-27-adresse-cvr-ean.sql først.
--
-- Den rører kun rækker, hvor adressen slutter på "4 cifre + bynavn",
-- fx "Algade 117, 4760 Vordingborg" -> adresse="Algade 117", postnr="4760", by="Vordingborg".
-- Adresser uden postnummer bliver stående, som de er.

-- 1) Se først, hvad der VILLE ske. Kør denne alene, og kig resultatet igennem.
select
  navn,
  adresse                                              as nuvaerende_adresse,
  regexp_replace(adresse, '^(.*),\s*(\d{4})\s+(.+)$', '\1') as ny_adresse,
  regexp_replace(adresse, '^(.*),\s*(\d{4})\s+(.+)$', '\2') as nyt_postnr,
  regexp_replace(adresse, '^(.*),\s*(\d{4})\s+(.+)$', '\3') as ny_by
from vaeresteder
where adresse ~ '^(.*),\s*(\d{4})\s+(.+)$'
  and (postnr is null or postnr = '')
order by navn;

-- 2) Ser det rigtigt ud? Kør så denne.
update vaeresteder
set
  postnr  = regexp_replace(adresse, '^(.*),\s*(\d{4})\s+(.+)$', '\2'),
  by      = regexp_replace(adresse, '^(.*),\s*(\d{4})\s+(.+)$', '\3'),
  adresse = btrim(regexp_replace(adresse, '^(.*),\s*(\d{4})\s+(.+)$', '\1'))
where adresse ~ '^(.*),\s*(\d{4})\s+(.+)$'
  and (postnr is null or postnr = '');
