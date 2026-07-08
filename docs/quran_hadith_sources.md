# Quran and Hadith Content Sources

## Quran

Bundled Quran data is stored as:

- `assets/data/quran_index.json`
- `assets/data/quran_surahs/001.json` through `114.json`

The Quran data uses `quran-json@3.1.2` Turkish chapters:

- Project: https://github.com/risan/quran-json
- Package: https://www.npmjs.com/package/quran-json
- Quran text note from the project: Uthmani Quran text is sourced from The Noble Qur'an Encyclopedia.
- License included in the package: CC BY-SA 4.0.

The app intentionally stores only:

- Uthmani-style Arabic Quran text
- Turkish meaning/translation

Turkish transliteration/okunuş is not bundled in this version.

## Hadith

Bundled hadith data is stored as:

- `assets/data/hadith_nawawi_tr.json`

The hadith data uses the Turkish `tur-nawawi` edition from `fawazahmed0/hadith-api`:

- Project: https://github.com/fawazahmed0/hadith-api
- Edition: https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/tur-nawawi.min.json
- License in repository: Unlicense / public domain dedication.

## Validation Note

Before publishing a production Islamic app, Quran and hadith text should be reviewed by a qualified editor. Future remote/Firebase content should preserve source, reference, version, and review metadata.
