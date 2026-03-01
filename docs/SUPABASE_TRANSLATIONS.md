# Country & City Translations in Supabase

FoxyWall supports full translation of server **countries** and **cities** for all app languages. The app reads optional JSON columns from the `vpn_servers` table and displays the correct name for the user’s selected language.

## Supported locale codes (match app languages)

Use these keys inside the JSON objects:

- `en` – English  
- `ar` – Arabic  
- `de` – German  
- `es` – Spanish  
- `fr` – French  
- `he` – Hebrew  
- `hi` – Hindi  
- `id` – Indonesian  
- `pt-BR` – Portuguese (Brazil)  
- `ru` – Russian  
- `tr` – Turkish  

Always include `en` as fallback. The app uses the current language first, then `en`, then the existing `country_name` / `city` column.

---

## 1. Add columns to `vpn_servers`

Run in Supabase SQL Editor:

```sql
-- Add optional translation columns (JSONB: locale -> display name)
ALTER TABLE vpn_servers
  ADD COLUMN IF NOT EXISTS country_names jsonb DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS city_name jsonb DEFAULT NULL;

COMMENT ON COLUMN vpn_servers.country_names IS 'Translations: {"en":"Germany","de":"Deutschland",...}';
COMMENT ON COLUMN vpn_servers.city_name IS 'Translations: {"en":"Frankfurt","de":"Frankfurt",...}';
```

Existing rows keep working: if `country_names` or `city_name` is `NULL`, the app uses `country_name` and `city`.

---

## 2. Column format

- **country_names** – JSON object: locale code → country name.  
  Example: `{"en": "Germany", "de": "Deutschland", "fr": "Allemagne", "es": "Alemania", "ar": "ألمانيا", ...}`

- **city_name** – JSON object: locale code → city name.  
  Example: `{"en": "Frankfurt", "de": "Frankfurt", "fr": "Francfort", "ar": "فرانكفورت", ...}`

---

## 3. Example: update one server

```sql
UPDATE vpn_servers
SET
  country_names = '{
    "en": "Germany",
    "de": "Deutschland",
    "fr": "Allemagne",
    "es": "Alemania",
    "ar": "ألمانيا",
    "pt-BR": "Alemanha",
    "ru": "Германия",
    "tr": "Almanya",
    "he": "גרמניה",
    "id": "Jerman",
    "hi": "जर्मनी"
  }'::jsonb,
  city_name = '{
    "en": "Frankfurt",
    "de": "Frankfurt",
    "fr": "Francfort",
    "es": "Fráncfort",
    "ar": "فرانكفورت",
    "pt-BR": "Frankfurt",
    "ru": "Франкфурт",
    "tr": "Frankfurt",
    "he": "פרנקפורט",
    "id": "Frankfurt",
    "hi": "फ्रैंकफर्ट"
  }'::jsonb
WHERE country_code = 'de' AND city ILIKE '%frankfurt%';
```

---

## 4. Bulk update from existing `country_name` / `city`

You can set `country_names` and `city_name` from current values so at least English is filled:

```sql
-- Set country_names with en = current country_name where still null
UPDATE vpn_servers
SET country_names = jsonb_build_object('en', country_name)
WHERE country_names IS NULL AND country_name IS NOT NULL;

-- Set city_name with en = current city where still null
UPDATE vpn_servers
SET city_name = jsonb_build_object('en', city)
WHERE city_name IS NULL AND city IS NOT NULL;
```

Then update per row or per (country_code, city) with more locales as needed.

---

## 6. Seed script: translate all countries and cities

Run the seed script to fill `country_names` and `city_name` for all supported locales:

1. Ensure the migration has been run (columns exist).
2. In Supabase SQL Editor, run the contents of **`supabase/seed_translations.sql`**.

The script:

- Sets **English** from existing `country_name` and `city` for every row.
- Merges **country** names in all 11 locales (en, ar, de, es, fr, he, hi, id, pt-BR, ru, tr) for 40+ countries (AU, AT, BE, BR, CA, CL, CN, CO, CZ, DK, FI, FR, DE, GR, HK, HU, IN, ID, IE, IL, IT, JP, KR, MX, NL, NZ, NO, PL, PT, RO, RU, SG, ZA, ES, SE, CH, TR, UA, AE, GB, UK, US).
- Merges **city** names in all 11 locales for common VPN cities (e.g. Frankfurt, Berlin, London, Amsterdam, Stockholm, New York, Paris, Singapore, Tokyo, Zurich, Sydney, Toronto, Madrid, Mumbai, Hong Kong, Seoul, Los Angeles).

To add more countries or cities, add rows to the `country_i18n` or `city_i18n` CTEs in `seed_translations.sql` and run it again. Matching is by `UPPER(TRIM(country_code))` and, for cities, `LOWER(TRIM(city))`.

---

## 5. App behavior

- The app requests `vpn_servers` with `select=*` (so the new columns are included).
- It uses `localizedCountryName(preferredLocale:)` and `localizedCityName(preferredLocale:)` with the in-app language code.
- If a translation exists for that locale (or `en`), that value is shown; otherwise it falls back to `country_name` and `city`.

No API or app code change is required beyond deploying the version that uses these columns; only add the columns and fill the JSON in Supabase.
