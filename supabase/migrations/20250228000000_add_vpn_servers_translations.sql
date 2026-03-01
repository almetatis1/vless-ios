-- Add country and city translation columns to vpn_servers for full app localization.
-- Locale keys must match app: en, ar, de, es, fr, he, hi, id, pt-BR, ru, tr.

ALTER TABLE vpn_servers
  ADD COLUMN IF NOT EXISTS country_names jsonb DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS city_name jsonb DEFAULT NULL;

COMMENT ON COLUMN vpn_servers.country_names IS 'Country name by locale: {"en":"Germany","de":"Deutschland",...}';
COMMENT ON COLUMN vpn_servers.city_name IS 'City name by locale: {"en":"Frankfurt","de":"Frankfurt",...}';
