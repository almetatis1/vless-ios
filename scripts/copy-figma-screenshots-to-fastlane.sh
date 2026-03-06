#!/usr/bin/env bash
# Copies Figma export screenshots into fastlane/screenshots for deliver.
# Maps Figma locale folders to App Store Connect locale names (e.g. en -> en-US).
# Usage: ./scripts/copy-figma-screenshots-to-fastlane.sh [figma-exports/iphone_65|figma-exports/iphone_67]

set -euo pipefail

SOURCE_DIR="${1:-figma-exports/iphone_65}"
DEST_DIR="${DEST_DIR:-./fastlane/screenshots}"

# Map Figma locale code to App Store Connect (deliver) directory name
map_locale() {
  case "$1" in
    ar) echo "ar-SA" ;;
    de) echo "de-DE" ;;
    en) echo "en-US" ;;
    es) echo "es-ES" ;;
    fr) echo "fr-FR" ;;
    *) echo "$1" ;;
  esac
}

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source directory not found: ${SOURCE_DIR}"
  echo "Usage: $0 [figma-exports/iphone_65|figma-exports/iphone_67]"
  echo "  or set SOURCE_DIR (e.g. figma-exports/iphone_65)"
  exit 1
fi

# Clear destination so only valid locale dirs exist (no leftover ar, de, en, es, fr)
rm -rf "${DEST_DIR}"
mkdir -p "${DEST_DIR}"
copied=0

for locale_dir in "${SOURCE_DIR}"/*/; do
  [[ -d "${locale_dir}" ]] || continue
  locale="$(basename "${locale_dir}")"
  dest_locale_name="$(map_locale "${locale}")"
  dest_locale="${DEST_DIR}/${dest_locale_name}"
  mkdir -p "${dest_locale}"
  for f in "${locale_dir}"*.png; do
    [[ -e "${f}" ]] || continue
    name="$(basename "${f}")"
    cp "${f}" "${dest_locale}/${name}"
    ((copied++)) || true
  done
done

echo "Copied ${copied} screenshots from ${SOURCE_DIR} to ${DEST_DIR}"
if [[ ${copied} -eq 0 ]]; then
  echo "No PNG files found in ${SOURCE_DIR}/<locale>/"
  exit 1
fi
