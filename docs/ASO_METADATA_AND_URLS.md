# FoxyWall ASO – Descriptions, Tags, Promotional Text & Links

Reference: [FoxyWall website](https://www.foxywall.xyz/) and localized pages (e.g. [Russian](https://www.foxywall.xyz/ru)).

## App Store Connect URLs

Use these in App Store Connect (or in `deliver` if you pass them):

| Purpose        | URL |
|----------------|-----|
| **Support URL** | https://www.foxywall.xyz |
| **Marketing URL** | https://www.foxywall.xyz |
| **Privacy Policy** | https://www.foxywall.xyz (or your exact privacy policy URL) |

## Localized landing pages (per language)

Use these for in-app “Learn more” / “Website” links or for regional campaigns:

| Locale   | Language   | Landing page |
|----------|------------|--------------|
| en-US    | English    | https://www.foxywall.xyz |
| ru       | Russian    | https://www.foxywall.xyz/ru |
| ar-SA    | Arabic     | https://www.foxywall.xyz/ar |
| de-DE    | German     | https://www.foxywall.xyz/de |
| es-ES    | Spanish    | https://www.foxywall.xyz/es |
| fr-FR    | French     | https://www.foxywall.xyz/fr |
| he       | Hebrew     | https://www.foxywall.xyz/he |
| id       | Indonesian | https://www.foxywall.xyz/id |
| ja       | Japanese   | https://www.foxywall.xyz/ja |
| pt-BR    | Portuguese (BR) | https://www.foxywall.xyz/pt-BR |
| tr       | Turkish    | https://www.foxywall.xyz/tr |
| uk       | Ukrainian  | https://www.foxywall.xyz/uk |
| vi       | Vietnamese | https://www.foxywall.xyz/vi |
| zh-Hans  | Chinese (Simplified) | https://www.foxywall.xyz/zh-Hans |

*(Create the same path structure on foxywall.xyz if you want each locale to open its localized page.)*

## Referral / promotional link

- **Give a friend 30 days free**: https://www.foxywall.xyz/en/refer (or localized path, e.g. `/ru/refer`).

## Metadata locations in repo

- **Descriptions, keywords, subtitle, name, promotional text**: `fastlane/metadata/<locale>/`
  - `description.txt` – full app description (up to 4000 chars)
  - `keywords.txt` – App Store keywords (up to 100 chars, comma-separated, no spaces in keywords)
  - `subtitle.txt` – subtitle (up to 30 chars)
  - `name.txt` – app name (up to 30 chars)
  - `promotional_text.txt` – promotional text (up to 170 chars; can be updated without new version)

All 14 locales above have these files filled for ASO, aligned with the messaging on https://www.foxywall.xyz/ru (professional VPN, split routing, multi-device, 200+ servers, no logs, refer-a-friend 30 days free).

## Uploading to App Store Connect

- Screenshots only: `bundle exec fastlane upload_figma_screenshots`
- Full metadata (and optional screenshots): `bundle exec fastlane upload_metadata`
