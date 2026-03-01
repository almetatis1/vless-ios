-- =============================================================================
-- Seed script: populate country_names and city_name for all vpn_servers
-- Run AFTER: 20250228000000_add_vpn_servers_translations.sql
-- Locales: en, ar, de, es, fr, he, hi, id, pt-BR, ru, tr, zh-Hans (Simplified Chinese)
--
-- If country names still don't translate in the app:
-- 1. Run this entire script in Supabase SQL Editor.
-- 2. Check which country codes exist: SELECT DISTINCT UPPER(TRIM(country_code)) FROM vpn_servers;
-- 3. If any code is missing from the list below, add it to the country_i18n CTE (same format).
-- =============================================================================

-- Step 1: English fallback from existing columns
UPDATE vpn_servers
SET country_names = COALESCE(country_names, '{}'::jsonb) || jsonb_build_object('en', country_name)
WHERE country_name IS NOT NULL AND country_name != '';

UPDATE vpn_servers
SET city_name = COALESCE(city_name, '{}'::jsonb) || jsonb_build_object('en', city)
WHERE city IS NOT NULL AND city != '';

-- Step 2: Overwrite country_names with full translations when country_code matches (alpha-2, alpha-3, or UK).
WITH country_i18n (code, names) AS (
  VALUES
  ('AU', '{"en":"Australia","ar":"أستراليا","de":"Australien","es":"Australia","fr":"Australie","he":"אוסטרליה","hi":"ऑस्ट्रेलिया","id":"Australia","pt-BR":"Austrália","ru":"Австралия","tr":"Avustralya"}'::jsonb),
  ('AUS', '{"en":"Australia","ar":"أستراليا","de":"Australien","es":"Australia","fr":"Australie","he":"אוסטרליה","hi":"ऑस्ट्रेलिया","id":"Australia","pt-BR":"Austrália","ru":"Австралия","tr":"Avustralya"}'::jsonb),
  ('AT', '{"en":"Austria","ar":"النمسا","de":"Österreich","es":"Austria","fr":"Autriche","he":"אוסטריה","hi":"ऑस्ट्रिया","id":"Austria","pt-BR":"Áustria","ru":"Австрия","tr":"Avusturya"}'::jsonb),
  ('AUT', '{"en":"Austria","ar":"النمسا","de":"Österreich","es":"Austria","fr":"Autriche","he":"אוסטריה","hi":"ऑस्ट्रिया","id":"Austria","pt-BR":"Áustria","ru":"Австрия","tr":"Avusturya"}'::jsonb),
  ('BE', '{"en":"Belgium","ar":"بلجيكا","de":"Belgien","es":"Bélgica","fr":"Belgique","he":"בלגיה","hi":"बेल्जियम","id":"Belgia","pt-BR":"Bélgica","ru":"Бельгия","tr":"Belçika"}'::jsonb),
  ('BEL', '{"en":"Belgium","ar":"بلجيكا","de":"Belgien","es":"Bélgica","fr":"Belgique","he":"בלגיה","hi":"बेल्जियम","id":"Belgia","pt-BR":"Bélgica","ru":"Бельгия","tr":"Belçika"}'::jsonb),
  ('BR', '{"en":"Brazil","ar":"البرازيل","de":"Brasilien","es":"Brasil","fr":"Brésil","he":"ברזיל","hi":"ब्राज़ील","id":"Brasil","pt-BR":"Brasil","ru":"Бразилия","tr":"Brezilya"}'::jsonb),
  ('BRA', '{"en":"Brazil","ar":"البرازيل","de":"Brasilien","es":"Brasil","fr":"Brésil","he":"ברזיל","hi":"ब्राज़ील","id":"Brasil","pt-BR":"Brasil","ru":"Бразилия","tr":"Brezilya"}'::jsonb),
  ('CA', '{"en":"Canada","ar":"كندا","de":"Kanada","es":"Canadá","fr":"Canada","he":"קנדה","hi":"कनाडा","id":"Kanada","pt-BR":"Canadá","ru":"Канада","tr":"Kanada"}'::jsonb),
  ('CAN', '{"en":"Canada","ar":"كندا","de":"Kanada","es":"Canadá","fr":"Canada","he":"קנדה","hi":"कनाडा","id":"Kanada","pt-BR":"Canadá","ru":"Канада","tr":"Kanada"}'::jsonb),
  ('CL', '{"en":"Chile","ar":"تشيلي","de":"Chile","es":"Chile","fr":"Chili","he":"צילה","hi":"चिली","id":"Chili","pt-BR":"Chile","ru":"Чили","tr":"Şili"}'::jsonb),
  ('CN', '{"en":"China","ar":"الصين","de":"China","es":"China","fr":"Chine","he":"סין","hi":"चीन","id":"Tiongkok","pt-BR":"China","ru":"Китай","tr":"Çin"}'::jsonb),
  ('CHN', '{"en":"China","ar":"الصين","de":"China","es":"China","fr":"Chine","he":"סין","hi":"चीन","id":"Tiongkok","pt-BR":"China","ru":"Китай","tr":"Çin"}'::jsonb),
  ('CO', '{"en":"Colombia","ar":"كولومبيا","de":"Kolumbien","es":"Colombia","fr":"Colombie","he":"קולומביה","hi":"कोलंबिया","id":"Kolombia","pt-BR":"Colômbia","ru":"Колумбия","tr":"Kolombiya"}'::jsonb),
  ('CZ', '{"en":"Czech Republic","ar":"التشيك","de":"Tschechien","es":"República Checa","fr":"République tchèque","he":"צכיה","hi":"चेक गणराज्य","id":"Ceko","pt-BR":"República Tcheca","ru":"Чехия","tr":"Çekya"}'::jsonb),
  ('DK', '{"en":"Denmark","ar":"الدنمارك","de":"Dänemark","es":"Dinamarca","fr":"Danemark","he":"דנמרק","hi":"डेनमार्क","id":"Denmark","pt-BR":"Dinamarca","ru":"Дания","tr":"Danimarka"}'::jsonb),
  ('FI', '{"en":"Finland","ar":"فنلندا","de":"Finnland","es":"Finlandia","fr":"Finlande","he":"פינלנד","hi":"फिनलैंड","id":"Finlandia","pt-BR":"Finlândia","ru":"Финляндия","tr":"Finlandiya"}'::jsonb),
  ('FR', '{"en":"France","ar":"فرنسا","de":"Frankreich","es":"Francia","fr":"France","he":"צרפת","hi":"फ्रांस","id":"Prancis","pt-BR":"França","ru":"Франция","tr":"Fransa"}'::jsonb),
  ('FRA', '{"en":"France","ar":"فرنسا","de":"Frankreich","es":"Francia","fr":"France","he":"צרפת","hi":"फ्रांस","id":"Prancis","pt-BR":"França","ru":"Франция","tr":"Fransa"}'::jsonb),
  ('DE', '{"en":"Germany","ar":"ألمانيا","de":"Deutschland","es":"Alemania","fr":"Allemagne","he":"גרמניה","hi":"जर्मनी","id":"Jerman","pt-BR":"Alemanha","ru":"Германия","tr":"Almanya"}'::jsonb),
  ('DEU', '{"en":"Germany","ar":"ألمانيا","de":"Deutschland","es":"Alemania","fr":"Allemagne","he":"גרמניה","hi":"जर्मनी","id":"Jerman","pt-BR":"Alemanha","ru":"Германия","tr":"Almanya"}'::jsonb),
  ('GR', '{"en":"Greece","ar":"اليونان","de":"Griechenland","es":"Grecia","fr":"Grèce","he":"יוון","hi":"ग्रीस","id":"Yunani","pt-BR":"Grécia","ru":"Греция","tr":"Yunanistan"}'::jsonb),
  ('HK', '{"en":"Hong Kong","ar":"هونغ كونغ","de":"Hongkong","es":"Hong Kong","fr":"Hong Kong","he":"הונג קונג","hi":"हांग कांग","id":"Hong Kong","pt-BR":"Hong Kong","ru":"Гонконг","tr":"Hong Kong"}'::jsonb),
  ('HU', '{"en":"Hungary","ar":"المجر","de":"Ungarn","es":"Hungría","fr":"Hongrie","he":"הונגריה","hi":"हंगरी","id":"Hungaria","pt-BR":"Hungria","ru":"Венгрия","tr":"Macaristan"}'::jsonb),
  ('IN', '{"en":"India","ar":"الهند","de":"Indien","es":"India","fr":"Inde","he":"הודו","hi":"भारत","id":"India","pt-BR":"Índia","ru":"Индия","tr":"Hindistan"}'::jsonb),
  ('IND', '{"en":"India","ar":"الهند","de":"Indien","es":"India","fr":"Inde","he":"הודו","hi":"भारत","id":"India","pt-BR":"Índia","ru":"Индия","tr":"Hindistan"}'::jsonb),
  ('ID', '{"en":"Indonesia","ar":"إندونيسيا","de":"Indonesien","es":"Indonesia","fr":"Indonésie","he":"אינדונזיה","hi":"इंडोनेशिया","id":"Indonesia","pt-BR":"Indonésia","ru":"Индонезия","tr":"Endonezya"}'::jsonb),
  ('IDN', '{"en":"Indonesia","ar":"إندونيسيا","de":"Indonesien","es":"Indonesia","fr":"Indonésie","he":"אינדונזיה","hi":"इंडोनेशिया","id":"Indonesia","pt-BR":"Indonésia","ru":"Индонезия","tr":"Endonezya"}'::jsonb),
  ('IE', '{"en":"Ireland","ar":"أيرلندا","de":"Irland","es":"Irlanda","fr":"Irlande","he":"אירלנד","hi":"आयरलैंड","id":"Irlandia","pt-BR":"Irlanda","ru":"Ирландия","tr":"İrlanda"}'::jsonb),
  ('IL', '{"en":"Israel","ar":"إسرائيل","de":"Israel","es":"Israel","fr":"Israël","he":"ישראל","hi":"इज़राइल","id":"Israel","pt-BR":"Israel","ru":"Израиль","tr":"İsrail"}'::jsonb),
  ('IT', '{"en":"Italy","ar":"إيطاليا","de":"Italien","es":"Italia","fr":"Italie","he":"איטליה","hi":"इटली","id":"Italia","pt-BR":"Itália","ru":"Италия","tr":"İtalya"}'::jsonb),
  ('ITA', '{"en":"Italy","ar":"إيطاليا","de":"Italien","es":"Italia","fr":"Italie","he":"איטליה","hi":"इटली","id":"Italia","pt-BR":"Itália","ru":"Италия","tr":"İtalya"}'::jsonb),
  ('JP', '{"en":"Japan","ar":"اليابان","de":"Japan","es":"Japón","fr":"Japon","he":"יפן","hi":"जापान","id":"Jepang","pt-BR":"Japão","ru":"Япония","tr":"Japonya"}'::jsonb),
  ('JPN', '{"en":"Japan","ar":"اليابان","de":"Japan","es":"Japón","fr":"Japon","he":"יפן","hi":"जापान","id":"Jepang","pt-BR":"Japão","ru":"Япония","tr":"Japonya"}'::jsonb),
  ('KR', '{"en":"South Korea","ar":"كوريا الجنوبية","de":"Südkorea","es":"Corea del Sur","fr":"Corée du Sud","he":"קוריאה הדרומית","hi":"दक्षिण कोरिया","id":"Korea Selatan","pt-BR":"Coreia do Sul","ru":"Южная Корея","tr":"Güney Kore"}'::jsonb),
  ('MX', '{"en":"Mexico","ar":"المكسيك","de":"Mexiko","es":"México","fr":"Mexique","he":"מקסיקו","hi":"मैक्सिको","id":"Meksiko","pt-BR":"México","ru":"Мексика","tr":"Meksika"}'::jsonb),
  ('NL', '{"en":"Netherlands","ar":"هولندا","de":"Niederlande","es":"Países Bajos","fr":"Pays-Bas","he":"הולנד","hi":"नीदरलैंड","id":"Belanda","pt-BR":"Países Baixos","ru":"Нидерланды","tr":"Hollanda"}'::jsonb),
  ('NLD', '{"en":"Netherlands","ar":"هولندا","de":"Niederlande","es":"Países Bajos","fr":"Pays-Bas","he":"הולנד","hi":"नीदरलैंड","id":"Belanda","pt-BR":"Países Baixos","ru":"Нидерланды","tr":"Hollanda"}'::jsonb),
  ('NZ', '{"en":"New Zealand","ar":"نيوزيلندا","de":"Neuseeland","es":"Nueva Zelanda","fr":"Nouvelle-Zélande","he":"ניו זילנד","hi":"न्यूज़ीलैंड","id":"Selandia Baru","pt-BR":"Nova Zelândia","ru":"Новая Зеландия","tr":"Yeni Zelanda"}'::jsonb),
  ('NO', '{"en":"Norway","ar":"النرويج","de":"Norwegen","es":"Noruega","fr":"Norvège","he":"נורווגיה","hi":"नॉर्वे","id":"Norwegia","pt-BR":"Noruega","ru":"Норвегия","tr":"Norveç"}'::jsonb),
  ('PL', '{"en":"Poland","ar":"بولندا","de":"Polen","es":"Polonia","fr":"Pologne","he":"פולין","hi":"पोलैंड","id":"Polandia","pt-BR":"Polônia","ru":"Польша","tr":"Polonya"}'::jsonb),
  ('PT', '{"en":"Portugal","ar":"البرتغال","de":"Portugal","es":"Portugal","fr":"Portugal","he":"פורטוגל","hi":"पुर्तगाल","id":"Portugal","pt-BR":"Portugal","ru":"Португалия","tr":"Portekiz"}'::jsonb),
  ('RO', '{"en":"Romania","ar":"رومانيا","de":"Rumänien","es":"Rumania","fr":"Roumanie","he":"רומניה","hi":"रोमानिया","id":"Rumania","pt-BR":"Romênia","ru":"Румыния","tr":"Romanya"}'::jsonb),
  ('RU', '{"en":"Russia","ar":"روسيا","de":"Russland","es":"Rusia","fr":"Russie","he":"רוסיה","hi":"रूस","id":"Rusia","pt-BR":"Rússia","ru":"Россия","tr":"Rusya"}'::jsonb),
  ('RUS', '{"en":"Russia","ar":"روسيا","de":"Russland","es":"Rusia","fr":"Russie","he":"רוסיה","hi":"रूस","id":"Rusia","pt-BR":"Rússia","ru":"Россия","tr":"Rusya"}'::jsonb),
  ('SG', '{"en":"Singapore","ar":"سنغافورة","de":"Singapur","es":"Singapur","fr":"Singapour","he":"סינגפור","hi":"सिंगापुर","id":"Singapura","pt-BR":"Singapura","ru":"Сингапур","tr":"Singapur"}'::jsonb),
  ('SGP', '{"en":"Singapore","ar":"سنغافورة","de":"Singapur","es":"Singapur","fr":"Singapour","he":"סינגפור","hi":"सिंगापुर","id":"Singapura","pt-BR":"Singapura","ru":"Сингапур","tr":"Singapur"}'::jsonb),
  ('ZA', '{"en":"South Africa","ar":"جنوب أفريقيا","de":"Südafrika","es":"Sudáfrica","fr":"Afrique du Sud","he":"דרום אפריקה","hi":"दक्षिण अफ्रीका","id":"Afrika Selatan","pt-BR":"África do Sul","ru":"Южная Африка","tr":"Güney Afrika"}'::jsonb),
  ('ES', '{"en":"Spain","ar":"إسبانيا","de":"Spanien","es":"España","fr":"Espagne","he":"ספרד","hi":"स्पेन","id":"Spanyol","pt-BR":"Espanha","ru":"Испания","tr":"İspanya"}'::jsonb),
  ('ESP', '{"en":"Spain","ar":"إسبانيا","de":"Spanien","es":"España","fr":"Espagne","he":"ספרד","hi":"स्पेन","id":"Spanyol","pt-BR":"Espanha","ru":"Испания","tr":"İspanya"}'::jsonb),
  ('SE', '{"en":"Sweden","ar":"السويد","de":"Schweden","es":"Suecia","fr":"Suède","he":"שוודיה","hi":"स्वीडन","id":"Swedia","pt-BR":"Suécia","ru":"Швеция","tr":"İsveç"}'::jsonb),
  ('SWE', '{"en":"Sweden","ar":"السويد","de":"Schweden","es":"Suecia","fr":"Suède","he":"שוודיה","hi":"स्वीडन","id":"Swedia","pt-BR":"Suécia","ru":"Швеция","tr":"İsveç"}'::jsonb),
  ('CH', '{"en":"Switzerland","ar":"سويسرا","de":"Schweiz","es":"Suiza","fr":"Suisse","he":"שווייץ","hi":"स्विट्ज़रलैंड","id":"Swiss","pt-BR":"Suíça","ru":"Швейцария","tr":"İsviçre"}'::jsonb),
  ('CHE', '{"en":"Switzerland","ar":"سويسرا","de":"Schweiz","es":"Suiza","fr":"Suisse","he":"שווייץ","hi":"स्विट्ज़रलैंड","id":"Swiss","pt-BR":"Suíça","ru":"Швейцария","tr":"İsviçre"}'::jsonb),
  ('TR', '{"en":"Turkey","ar":"تركيا","de":"Türkei","es":"Turquía","fr":"Turquie","he":"טורקיה","hi":"तुर्की","id":"Turki","pt-BR":"Turquia","ru":"Турция","tr":"Türkiye"}'::jsonb),
  ('TUR', '{"en":"Turkey","ar":"تركيا","de":"Türkei","es":"Turquía","fr":"Turquie","he":"טורקיה","hi":"तुर्की","id":"Turki","pt-BR":"Turquia","ru":"Турция","tr":"Türkiye"}'::jsonb),
  ('UA', '{"en":"Ukraine","ar":"أوكرانيا","de":"Ukraine","es":"Ucrania","fr":"Ukraine","he":"אוקראינה","hi":"यूक्रेन","id":"Ukraina","pt-BR":"Ucrânia","ru":"Украина","tr":"Ukrayna"}'::jsonb),
  ('AE', '{"en":"United Arab Emirates","ar":"الإمارات العربية المتحدة","de":"Vereinigte Arabische Emirate","es":"Emiratos Árabes Unidos","fr":"Émirats arabes unis","he":"איחוד האמירויות","hi":"संयुक्त अरब अमीरात","id":"Uni Emirat Arab","pt-BR":"Emirados Árabes Unidos","ru":"ОАЭ","tr":"Birleşik Arap Emirlikleri"}'::jsonb),
  ('GB', '{"en":"United Kingdom","ar":"المملكة المتحدة","de":"Vereinigtes Königreich","es":"Reino Unido","fr":"Royaume-Uni","he":"בריטניה","hi":"यूनाइटेड किंगडम","id":"Britania Raya","pt-BR":"Reino Unido","ru":"Великобритания","tr":"Birleşik Krallık"}'::jsonb),
  ('UK', '{"en":"United Kingdom","ar":"المملكة المتحدة","de":"Vereinigtes Königreich","es":"Reino Unido","fr":"Royaume-Uni","he":"בריטניה","hi":"यूनाइटेड किंगडम","id":"Britania Raya","pt-BR":"Reino Unido","ru":"Великобритания","tr":"Birleşik Krallık"}'::jsonb),
  ('GBR', '{"en":"United Kingdom","ar":"المملكة المتحدة","de":"Vereinigtes Königreich","es":"Reino Unido","fr":"Royaume-Uni","he":"בריטניה","hi":"यूनाइटेड किंगडम","id":"Britania Raya","pt-BR":"Reino Unido","ru":"Великобритания","tr":"Birleşik Krallık"}'::jsonb),
  ('US', '{"en":"United States","ar":"الولايات المتحدة","de":"Vereinigte Staaten","es":"Estados Unidos","fr":"États-Unis","he":"ארצות הברית","hi":"संयुक्त राज्य","id":"Amerika Serikat","pt-BR":"Estados Unidos","ru":"США","tr":"Amerika Birleşik Devletleri"}'::jsonb),
  ('USA', '{"en":"United States","ar":"الولايات المتحدة","de":"Vereinigte Staaten","es":"Estados Unidos","fr":"États-Unis","he":"ארצות הברית","hi":"संयुक्त राज्य","id":"Amerika Serikat","pt-BR":"Estados Unidos","ru":"США","tr":"Amerika Birleşik Devletleri"}'::jsonb)
)
UPDATE vpn_servers s
SET country_names = c.names
FROM country_i18n c
WHERE UPPER(TRIM(s.country_code)) = c.code;

-- Step 2b: Also fill country_names by matching English country_name (handles DBs where country_code is missing or different)
WITH by_english_name (name_key, names) AS (
  VALUES
  ('australia', '{"en":"Australia","ar":"أستراليا","de":"Australien","es":"Australia","fr":"Australie","he":"אוסטרליה","hi":"ऑस्ट्रेलिया","id":"Australia","pt-BR":"Austrália","ru":"Австралия","tr":"Avustralya"}'::jsonb),
  ('austria', '{"en":"Austria","ar":"النمسا","de":"Österreich","es":"Austria","fr":"Autriche","he":"אוסטריה","hi":"ऑस्ट्रिया","id":"Austria","pt-BR":"Áustria","ru":"Австрия","tr":"Avusturya"}'::jsonb),
  ('belgium', '{"en":"Belgium","ar":"بلجيكا","de":"Belgien","es":"Bélgica","fr":"Belgique","he":"בלגיה","hi":"बेल्जियम","id":"Belgia","pt-BR":"Bélgica","ru":"Бельгия","tr":"Belçika"}'::jsonb),
  ('brazil', '{"en":"Brazil","ar":"البرازيل","de":"Brasilien","es":"Brasil","fr":"Brésil","he":"ברזיל","hi":"ब्राज़ील","id":"Brasil","pt-BR":"Brasil","ru":"Бразилия","tr":"Brezilya"}'::jsonb),
  ('canada', '{"en":"Canada","ar":"كندا","de":"Kanada","es":"Canadá","fr":"Canada","he":"קנדה","hi":"कनाडा","id":"Kanada","pt-BR":"Canadá","ru":"Канада","tr":"Kanada"}'::jsonb),
  ('chile', '{"en":"Chile","ar":"تشيلي","de":"Chile","es":"Chile","fr":"Chili","he":"צילה","hi":"चिली","id":"Chili","pt-BR":"Chile","ru":"Чили","tr":"Şili"}'::jsonb),
  ('china', '{"en":"China","ar":"الصين","de":"China","es":"China","fr":"Chine","he":"סין","hi":"चीन","id":"Tiongkok","pt-BR":"China","ru":"Китай","tr":"Çin"}'::jsonb),
  ('colombia', '{"en":"Colombia","ar":"كولومبيا","de":"Kolumbien","es":"Colombia","fr":"Colombie","he":"קולומביה","hi":"कोलंबिया","id":"Kolombia","pt-BR":"Colômbia","ru":"Колумбия","tr":"Kolombiya"}'::jsonb),
  ('czech republic', '{"en":"Czech Republic","ar":"التشيك","de":"Tschechien","es":"República Checa","fr":"République tchèque","he":"צכיה","hi":"चेक गणराज्य","id":"Ceko","pt-BR":"República Tcheca","ru":"Чехия","tr":"Çekya"}'::jsonb),
  ('denmark', '{"en":"Denmark","ar":"الدنمارك","de":"Dänemark","es":"Dinamarca","fr":"Danemark","he":"דנמרק","hi":"डेनमार्क","id":"Denmark","pt-BR":"Dinamarca","ru":"Дания","tr":"Danimarka"}'::jsonb),
  ('finland', '{"en":"Finland","ar":"فنلندا","de":"Finnland","es":"Finlandia","fr":"Finlande","he":"פינלנד","hi":"फिनलैंड","id":"Finlandia","pt-BR":"Finlândia","ru":"Финляндия","tr":"Finlandiya"}'::jsonb),
  ('france', '{"en":"France","ar":"فرنسا","de":"Frankreich","es":"Francia","fr":"France","he":"צרפת","hi":"फ्रांस","id":"Prancis","pt-BR":"França","ru":"Франция","tr":"Fransa"}'::jsonb),
  ('germany', '{"en":"Germany","ar":"ألمانيا","de":"Deutschland","es":"Alemania","fr":"Allemagne","he":"גרמניה","hi":"जर्मनी","id":"Jerman","pt-BR":"Alemanha","ru":"Германия","tr":"Almanya"}'::jsonb),
  ('greece', '{"en":"Greece","ar":"اليونان","de":"Griechenland","es":"Grecia","fr":"Grèce","he":"יוון","hi":"ग्रीस","id":"Yunani","pt-BR":"Grécia","ru":"Греция","tr":"Yunanistan"}'::jsonb),
  ('hong kong', '{"en":"Hong Kong","ar":"هونغ كونغ","de":"Hongkong","es":"Hong Kong","fr":"Hong Kong","he":"הונג קונג","hi":"हांग कांग","id":"Hong Kong","pt-BR":"Hong Kong","ru":"Гонконг","tr":"Hong Kong"}'::jsonb),
  ('hungary', '{"en":"Hungary","ar":"المجر","de":"Ungarn","es":"Hungría","fr":"Hongrie","he":"הונגריה","hi":"हंगरी","id":"Hungaria","pt-BR":"Hungria","ru":"Венгрия","tr":"Macaristan"}'::jsonb),
  ('india', '{"en":"India","ar":"الهند","de":"Indien","es":"India","fr":"Inde","he":"הודו","hi":"भारत","id":"India","pt-BR":"Índia","ru":"Индия","tr":"Hindistan"}'::jsonb),
  ('indonesia', '{"en":"Indonesia","ar":"إندونيسيا","de":"Indonesien","es":"Indonesia","fr":"Indonésie","he":"אינדונזיה","hi":"इंडोनेशिया","id":"Indonesia","pt-BR":"Indonésia","ru":"Индонезия","tr":"Endonezya"}'::jsonb),
  ('ireland', '{"en":"Ireland","ar":"أيرلندا","de":"Irland","es":"Irlanda","fr":"Irlande","he":"אירלנד","hi":"आयरलैंड","id":"Irlandia","pt-BR":"Irlanda","ru":"Ирландия","tr":"İrlanda"}'::jsonb),
  ('israel', '{"en":"Israel","ar":"إسرائيل","de":"Israel","es":"Israel","fr":"Israël","he":"ישראל","hi":"इज़राइल","id":"Israel","pt-BR":"Israel","ru":"Израиль","tr":"İsrail"}'::jsonb),
  ('italy', '{"en":"Italy","ar":"إيطاليا","de":"Italien","es":"Italia","fr":"Italie","he":"איטליה","hi":"इटली","id":"Italia","pt-BR":"Itália","ru":"Италия","tr":"İtalya"}'::jsonb),
  ('japan', '{"en":"Japan","ar":"اليابان","de":"Japan","es":"Japón","fr":"Japon","he":"יפן","hi":"जापान","id":"Jepang","pt-BR":"Japão","ru":"Япония","tr":"Japonya"}'::jsonb),
  ('south korea', '{"en":"South Korea","ar":"كوريا الجنوبية","de":"Südkorea","es":"Corea del Sur","fr":"Corée du Sud","he":"קוריאה הדרומית","hi":"दक्षिण कोरिया","id":"Korea Selatan","pt-BR":"Coreia do Sul","ru":"Южная Корея","tr":"Güney Kore"}'::jsonb),
  ('mexico', '{"en":"Mexico","ar":"المكسيك","de":"Mexiko","es":"México","fr":"Mexique","he":"מקסיקו","hi":"मैक्सिको","id":"Meksiko","pt-BR":"México","ru":"Мексика","tr":"Meksika"}'::jsonb),
  ('netherlands', '{"en":"Netherlands","ar":"هولندا","de":"Niederlande","es":"Países Bajos","fr":"Pays-Bas","he":"הולנד","hi":"नीदरलैंड","id":"Belanda","pt-BR":"Países Baixos","ru":"Нидерланды","tr":"Hollanda"}'::jsonb),
  ('new zealand', '{"en":"New Zealand","ar":"نيوزيلندا","de":"Neuseeland","es":"Nueva Zelanda","fr":"Nouvelle-Zélande","he":"ניו זילנד","hi":"न्यूज़ीलैंड","id":"Selandia Baru","pt-BR":"Nova Zelândia","ru":"Новая Зеландия","tr":"Yeni Zelanda"}'::jsonb),
  ('norway', '{"en":"Norway","ar":"النرويج","de":"Norwegen","es":"Noruega","fr":"Norvège","he":"נורווגיה","hi":"नॉर्वे","id":"Norwegia","pt-BR":"Noruega","ru":"Норвегия","tr":"Norveç"}'::jsonb),
  ('poland', '{"en":"Poland","ar":"بولندا","de":"Polen","es":"Polonia","fr":"Pologne","he":"פולין","hi":"पोलैंड","id":"Polandia","pt-BR":"Polônia","ru":"Польша","tr":"Polonya"}'::jsonb),
  ('portugal', '{"en":"Portugal","ar":"البرتغال","de":"Portugal","es":"Portugal","fr":"Portugal","he":"פורטוגל","hi":"पुर्तगाल","id":"Portugal","pt-BR":"Portugal","ru":"Португалия","tr":"Portekiz"}'::jsonb),
  ('romania', '{"en":"Romania","ar":"رومانيا","de":"Rumänien","es":"Rumania","fr":"Roumanie","he":"רומניה","hi":"रोमानिया","id":"Rumania","pt-BR":"Romênia","ru":"Румыния","tr":"Romanya"}'::jsonb),
  ('russia', '{"en":"Russia","ar":"روسيا","de":"Russland","es":"Rusia","fr":"Russie","he":"רוסיה","hi":"रूस","id":"Rusia","pt-BR":"Rússia","ru":"Россия","tr":"Rusya"}'::jsonb),
  ('singapore', '{"en":"Singapore","ar":"سنغافورة","de":"Singapur","es":"Singapur","fr":"Singapour","he":"סינגפור","hi":"सिंगापुर","id":"Singapura","pt-BR":"Singapura","ru":"Сингапур","tr":"Singapur"}'::jsonb),
  ('south africa', '{"en":"South Africa","ar":"جنوب أفريقيا","de":"Südafrika","es":"Sudáfrica","fr":"Afrique du Sud","he":"דרום אפריקה","hi":"दक्षिण अफ्रीका","id":"Afrika Selatan","pt-BR":"África do Sul","ru":"Южная Африка","tr":"Güney Afrika"}'::jsonb),
  ('spain', '{"en":"Spain","ar":"إسبانيا","de":"Spanien","es":"España","fr":"Espagne","he":"ספרד","hi":"स्पेन","id":"Spanyol","pt-BR":"Espanha","ru":"Испания","tr":"İspanya"}'::jsonb),
  ('sweden', '{"en":"Sweden","ar":"السويد","de":"Schweden","es":"Suecia","fr":"Suède","he":"שוודיה","hi":"स्वीडन","id":"Swedia","pt-BR":"Suécia","ru":"Швеция","tr":"İsveç"}'::jsonb),
  ('switzerland', '{"en":"Switzerland","ar":"سويسرا","de":"Schweiz","es":"Suiza","fr":"Suisse","he":"שווייץ","hi":"स्विट्ज़रलैंड","id":"Swiss","pt-BR":"Suíça","ru":"Швейцария","tr":"İsviçre"}'::jsonb),
  ('turkey', '{"en":"Turkey","ar":"تركيا","de":"Türkei","es":"Turquía","fr":"Turquie","he":"טורקיה","hi":"तुर्की","id":"Turki","pt-BR":"Turquia","ru":"Турция","tr":"Türkiye"}'::jsonb),
  ('ukraine', '{"en":"Ukraine","ar":"أوكرانيا","de":"Ukraine","es":"Ucrania","fr":"Ukraine","he":"אוקראינה","hi":"यूक्रेन","id":"Ukraina","pt-BR":"Ucrânia","ru":"Украина","tr":"Ukrayna"}'::jsonb),
  ('united arab emirates', '{"en":"United Arab Emirates","ar":"الإمارات العربية المتحدة","de":"Vereinigte Arabische Emirate","es":"Emiratos Árabes Unidos","fr":"Émirats arabes unis","he":"איחוד האמירויות","hi":"संयुक्त अरब अमीरात","id":"Uni Emirat Arab","pt-BR":"Emirados Árabes Unidos","ru":"ОАЭ","tr":"Birleşik Arap Emirlikleri"}'::jsonb),
  ('united kingdom', '{"en":"United Kingdom","ar":"المملكة المتحدة","de":"Vereinigtes Königreich","es":"Reino Unido","fr":"Royaume-Uni","he":"בריטניה","hi":"यूनाइटेड किंगडम","id":"Britania Raya","pt-BR":"Reino Unido","ru":"Великобритания","tr":"Birleşik Krallık"}'::jsonb),
  ('united states', '{"en":"United States","ar":"الولايات المتحدة","de":"Vereinigte Staaten","es":"Estados Unidos","fr":"États-Unis","he":"ארצות הברית","hi":"संयुक्त राज्य","id":"Amerika Serikat","pt-BR":"Estados Unidos","ru":"США","tr":"Amerika Birleşik Devletleri"}'::jsonb),
  ('usa', '{"en":"United States","ar":"الولايات المتحدة","de":"Vereinigte Staaten","es":"Estados Unidos","fr":"États-Unis","he":"ארצות הברית","hi":"संयुक्त राज्य","id":"Amerika Serikat","pt-BR":"Estados Unidos","ru":"США","tr":"Amerika Birleşik Devletleri"}'::jsonb)
)
UPDATE vpn_servers s
SET country_names = n.names
FROM by_english_name n
WHERE LOWER(TRIM(s.country_name)) = n.name_key;

-- Step 3: City names in all 11 locales for common VPN cities (merge into existing)
-- Normalize city column so "Tel-Aviv" / "Telaviv" etc. become "Tel Aviv" for consistent matching/display.
UPDATE vpn_servers
SET city = 'Tel Aviv'
WHERE UPPER(TRIM(country_code)) IN ('IL', 'ISR')
  AND LOWER(REPLACE(TRIM(city), ' ', '')) IN ('telaviv', 'tel-aviv');

WITH city_i18n (country_code, city_key, names) AS (
  VALUES
  ('DE', 'frankfurt', '{"en":"Frankfurt","ar":"فرانكفورت","de":"Frankfurt","es":"Fráncfort","fr":"Francfort","he":"פרנקפורט","hi":"फ्रैंकफर्ट","id":"Frankfurt","pt-BR":"Frankfurt","ru":"Франкфурт","tr":"Frankfurt"}'::jsonb),
  ('DE', 'berlin', '{"en":"Berlin","ar":"برلين","de":"Berlin","es":"Berlín","fr":"Berlin","he":"ברלין","hi":"बर्लिन","id":"Berlin","pt-BR":"Berlim","ru":"Берлин","tr":"Berlin"}'::jsonb),
  ('GB', 'london', '{"en":"London","ar":"لندن","de":"London","es":"Londres","fr":"Londres","he":"לונדון","hi":"लंदन","id":"London","pt-BR":"Londres","ru":"Лондон","tr":"Londra"}'::jsonb),
  ('UK', 'london', '{"en":"London","ar":"لندن","de":"London","es":"Londres","fr":"Londres","he":"לונדון","hi":"लंदन","id":"London","pt-BR":"Londres","ru":"Лондон","tr":"Londra"}'::jsonb),
  ('NL', 'amsterdam', '{"en":"Amsterdam","ar":"أمستردام","de":"Amsterdam","es":"Ámsterdam","fr":"Amsterdam","he":"אמסטרדם","hi":"एम्स्टर्डैम","id":"Amsterdam","pt-BR":"Amsterdã","ru":"Амстердам","tr":"Amsterdam"}'::jsonb),
  ('SE', 'stockholm', '{"en":"Stockholm","ar":"ستوكهولم","de":"Stockholm","es":"Estocolmo","fr":"Stockholm","he":"סטוקהולם","hi":"स्टॉकहोम","id":"Stockholm","pt-BR":"Estocolmo","ru":"Стокгольм","tr":"Stokholm"}'::jsonb),
  ('US', 'new york', '{"en":"New York","ar":"نيويورك","de":"New York","es":"Nueva York","fr":"New York","he":"ניו יורק","hi":"न्यूयॉर्क","id":"New York","pt-BR":"Nova York","ru":"Нью-Йорк","tr":"New York"}'::jsonb),
  ('US', 'los angeles', '{"en":"Los Angeles","ar":"لوس أنجلوس","de":"Los Angeles","es":"Los Ángeles","fr":"Los Angeles","he":"לוס אנגלס","hi":"लॉस एंजिल्स","id":"Los Angeles","pt-BR":"Los Angeles","ru":"Лос-Анджелес","tr":"Los Angeles"}'::jsonb),
  ('FR', 'paris', '{"en":"Paris","ar":"باريس","de":"Paris","es":"París","fr":"Paris","he":"פריז","hi":"पेरिस","id":"Paris","pt-BR":"Paris","ru":"Париж","tr":"Paris"}'::jsonb),
  ('SG', 'singapore', '{"en":"Singapore","ar":"سنغافورة","de":"Singapur","es":"Singapur","fr":"Singapour","he":"סינגפור","hi":"सिंगापुर","id":"Singapura","pt-BR":"Singapura","ru":"Сингапур","tr":"Singapur"}'::jsonb),
  ('JP', 'tokyo', '{"en":"Tokyo","ar":"طوكيو","de":"Tokio","es":"Tokio","fr":"Tokyo","he":"טוקיו","hi":"टोक्यो","id":"Tokyo","pt-BR":"Tóquio","ru":"Токио","tr":"Tokyo"}'::jsonb),
  ('CH', 'zurich', '{"en":"Zurich","ar":"زيورخ","de":"Zürich","es":"Zúrich","fr":"Zurich","he":"ציריך","hi":"ज़्यूरिख","id":"Zurich","pt-BR":"Zurique","ru":"Цюрих","tr":"Zürih"}'::jsonb),
  ('AU', 'sydney', '{"en":"Sydney","ar":"سيدني","de":"Sydney","es":"Sídney","fr":"Sydney","he":"סידני","hi":"सिडनी","id":"Sydney","pt-BR":"Sydney","ru":"Сидней","tr":"Sidney"}'::jsonb),
  ('CA', 'toronto', '{"en":"Toronto","ar":"تورونتو","de":"Toronto","es":"Toronto","fr":"Toronto","he":"טורונטו","hi":"टोरंटो","id":"Toronto","pt-BR":"Toronto","ru":"Торонто","tr":"Toronto"}'::jsonb),
  ('ES', 'madrid', '{"en":"Madrid","ar":"مدريد","de":"Madrid","es":"Madrid","fr":"Madrid","he":"מדריד","hi":"मैड्रिड","id":"Madrid","pt-BR":"Madri","ru":"Мадрид","tr":"Madrid"}'::jsonb),
  ('IN', 'mumbai', '{"en":"Mumbai","ar":"مومباي","de":"Mumbai","es":"Mumbai","fr":"Mumbai","he":"מומבאי","hi":"मुंबई","id":"Mumbai","pt-BR":"Mumbai","ru":"Мумбаи","tr":"Mumbai"}'::jsonb),
  ('HK', 'hong kong', '{"en":"Hong Kong","ar":"هونغ كونغ","de":"Hongkong","es":"Hong Kong","fr":"Hong Kong","he":"הונג קונג","hi":"हांग कांग","id":"Hong Kong","pt-BR":"Hong Kong","ru":"Гонконг","tr":"Hong Kong"}'::jsonb),
  ('KR', 'seoul', '{"en":"Seoul","ar":"سيول","de":"Seoul","es":"Seúl","fr":"Séoul","he":"סיאול","hi":"सियोल","id":"Seoul","pt-BR":"Seul","ru":"Сеул","tr":"Seul"}'::jsonb),
  ('IL', 'tel aviv', '{"en":"Tel Aviv","ar":"تل أبيب","de":"Tel Aviv","es":"Tel Aviv","fr":"Tel Aviv","he":"תל אביב","hi":"तेल अवीव","id":"Tel Aviv","pt-BR":"Tel Aviv","ru":"Тель-Авив","tr":"Tel Aviv"}'::jsonb),
  ('IL', 'tel-aviv', '{"en":"Tel Aviv","ar":"تل أبيب","de":"Tel Aviv","es":"Tel Aviv","fr":"Tel Aviv","he":"תל אביב","hi":"तेल अवीव","id":"Tel Aviv","pt-BR":"Tel Aviv","ru":"Тель-Авив","tr":"Tel Aviv"}'::jsonb),
  ('IL', 'telaviv', '{"en":"Tel Aviv","ar":"تل أبيب","de":"Tel Aviv","es":"Tel Aviv","fr":"Tel Aviv","he":"תל אביב","hi":"तेल अवीव","id":"Tel Aviv","pt-BR":"Tel Aviv","ru":"Тель-Авив","tr":"Tel Aviv"}'::jsonb),
  ('ISR', 'tel aviv', '{"en":"Tel Aviv","ar":"تل أبيب","de":"Tel Aviv","es":"Tel Aviv","fr":"Tel Aviv","he":"תל אביב","hi":"तेल अवीव","id":"Tel Aviv","pt-BR":"Tel Aviv","ru":"Тель-Авив","tr":"Tel Aviv"}'::jsonb),
  ('ISR', 'tel-aviv', '{"en":"Tel Aviv","ar":"تل أبيب","de":"Tel Aviv","es":"Tel Aviv","fr":"Tel Aviv","he":"תל אביב","hi":"तेल अवीव","id":"Tel Aviv","pt-BR":"Tel Aviv","ru":"Тель-Авив","tr":"Tel Aviv"}'::jsonb),
  ('ISR', 'telaviv', '{"en":"Tel Aviv","ar":"تل أبيب","de":"Tel Aviv","es":"Tel Aviv","fr":"Tel Aviv","he":"תל אביב","hi":"तेल अवीव","id":"Tel Aviv","pt-BR":"Tel Aviv","ru":"Тель-Авив","tr":"Tel Aviv"}'::jsonb)
)
UPDATE vpn_servers s
SET city_name = COALESCE(s.city_name, '{}'::jsonb) || c.names
FROM city_i18n c
WHERE UPPER(TRIM(s.country_code)) = c.country_code
  AND LOWER(TRIM(s.city)) = c.city_key;

-- Step 4: Combine city + country into city_name per locale (single source: "City, Country")
UPDATE vpn_servers s
SET city_name = (
  SELECT jsonb_object_agg(
    t.key,
    TRIM(COALESCE((s.city_name->>t.key), s.city) || ', ' || COALESCE((s.country_names->>t.key), s.country_name))
  )
  FROM jsonb_each_text(COALESCE(s.country_names, jsonb_build_object('en', s.country_name))) AS t(key, val)
)
WHERE s.country_names IS NOT NULL AND s.country_names != '{}'::jsonb;

-- Step 5: Add Simplified Chinese (zh-Hans) for countries and combined city names
-- Countries by code
WITH zh_country_by_code (code, zh_name) AS (
  VALUES
  ('AU', '澳大利亚'), ('AUS', '澳大利亚'), ('AT', '奥地利'), ('AUT', '奥地利'),
  ('BE', '比利时'), ('BEL', '比利时'), ('BR', '巴西'), ('BRA', '巴西'),
  ('CA', '加拿大'), ('CAN', '加拿大'), ('CL', '智利'), ('CN', '中国'), ('CHN', '中国'),
  ('CO', '哥伦比亚'), ('CZ', '捷克'), ('DK', '丹麦'), ('FI', '芬兰'),
  ('FR', '法国'), ('FRA', '法国'), ('DE', '德国'), ('DEU', '德国'), ('GR', '希腊'),
  ('HK', '香港'), ('HU', '匈牙利'), ('IN', '印度'), ('IND', '印度'),
  ('ID', '印度尼西亚'), ('IDN', '印度尼西亚'), ('IE', '爱尔兰'), ('IL', '以色列'),
  ('IT', '意大利'), ('ITA', '意大利'), ('JP', '日本'), ('JPN', '日本'),
  ('KR', '韩国'), ('MX', '墨西哥'), ('NL', '荷兰'), ('NLD', '荷兰'),
  ('NZ', '新西兰'), ('NO', '挪威'), ('PL', '波兰'), ('PT', '葡萄牙'),
  ('RO', '罗马尼亚'), ('RU', '俄罗斯'), ('RUS', '俄罗斯'), ('SG', '新加坡'), ('SGP', '新加坡'),
  ('ZA', '南非'), ('ES', '西班牙'), ('ESP', '西班牙'), ('SE', '瑞典'), ('SWE', '瑞典'),
  ('CH', '瑞士'), ('CHE', '瑞士'), ('TR', '土耳其'), ('TUR', '土耳其'), ('UA', '乌克兰'),
  ('AE', '阿联酋'), ('GB', '英国'), ('UK', '英国'), ('GBR', '英国'), ('US', '美国'), ('USA', '美国')
)
UPDATE vpn_servers s
SET country_names = COALESCE(s.country_names, '{}'::jsonb) || jsonb_build_object('zh-Hans', z.zh_name)
FROM zh_country_by_code z
WHERE UPPER(TRIM(s.country_code)) = z.code;

-- Countries by English name (for rows where code was not matched)
WITH zh_country_by_name (name_key, zh_name) AS (
  VALUES
  ('australia', '澳大利亚'), ('austria', '奥地利'), ('belgium', '比利时'), ('brazil', '巴西'),
  ('canada', '加拿大'), ('chile', '智利'), ('china', '中国'), ('colombia', '哥伦比亚'),
  ('czech republic', '捷克'), ('denmark', '丹麦'), ('finland', '芬兰'), ('france', '法国'),
  ('germany', '德国'), ('greece', '希腊'), ('hong kong', '香港'), ('hungary', '匈牙利'),
  ('india', '印度'), ('indonesia', '印度尼西亚'), ('ireland', '爱尔兰'), ('israel', '以色列'),
  ('italy', '意大利'), ('japan', '日本'), ('south korea', '韩国'), ('mexico', '墨西哥'),
  ('netherlands', '荷兰'), ('new zealand', '新西兰'), ('norway', '挪威'), ('poland', '波兰'),
  ('portugal', '葡萄牙'), ('romania', '罗马尼亚'), ('russia', '俄罗斯'), ('singapore', '新加坡'),
  ('south africa', '南非'), ('spain', '西班牙'), ('sweden', '瑞典'), ('switzerland', '瑞士'),
  ('turkey', '土耳其'), ('ukraine', '乌克兰'), ('united arab emirates', '阿联酋'),
  ('united kingdom', '英国'), ('united states', '美国'), ('usa', '美国')
)
UPDATE vpn_servers s
SET country_names = COALESCE(s.country_names, '{}'::jsonb) || jsonb_build_object('zh-Hans', z.zh_name)
FROM zh_country_by_name z
WHERE LOWER(TRIM(s.country_name)) = z.name_key
  AND (s.country_names IS NULL OR s.country_names->'zh-Hans' IS NULL);

-- Combined "City, Country" in Chinese for city_name
WITH zh_city_country (country_code, city_key, zh_combined) AS (
  VALUES
  ('DE', 'frankfurt', '法兰克福, 德国'), ('DE', 'berlin', '柏林, 德国'),
  ('GB', 'london', '伦敦, 英国'), ('UK', 'london', '伦敦, 英国'),
  ('NL', 'amsterdam', '阿姆斯特丹, 荷兰'), ('SE', 'stockholm', '斯德哥尔摩, 瑞典'),
  ('US', 'new york', '纽约, 美国'), ('US', 'los angeles', '洛杉矶, 美国'),
  ('FR', 'paris', '巴黎, 法国'), ('SG', 'singapore', '新加坡, 新加坡'),
  ('JP', 'tokyo', '东京, 日本'), ('CH', 'zurich', '苏黎世, 瑞士'),
  ('AU', 'sydney', '悉尼, 澳大利亚'), ('CA', 'toronto', '多伦多, 加拿大'),
  ('ES', 'madrid', '马德里, 西班牙'), ('IN', 'mumbai', '孟买, 印度'),
  ('HK', 'hong kong', '香港, 香港'), ('KR', 'seoul', '首尔, 韩国'),
  ('IL', 'tel aviv', '特拉维夫, 以色列'), ('IL', 'tel-aviv', '特拉维夫, 以色列'), ('IL', 'telaviv', '特拉维夫, 以色列'),
  ('ISR', 'tel aviv', '特拉维夫, 以色列'), ('ISR', 'tel-aviv', '特拉维夫, 以色列'), ('ISR', 'telaviv', '特拉维夫, 以色列')
)
UPDATE vpn_servers s
SET city_name = COALESCE(s.city_name, '{}'::jsonb) || jsonb_build_object('zh-Hans', z.zh_combined)
FROM zh_city_country z
WHERE UPPER(TRIM(s.country_code)) = z.country_code
  AND LOWER(TRIM(s.city)) = z.city_key;
