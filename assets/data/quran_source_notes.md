Quran data source notes
=======================

The bundled Quran data is split for performance:

- `assets/data/quran_index.json`
- `assets/data/quran_surahs/001.json` through `114.json`

The data was imported from `quran-json@3.1.2`, `dist/chapters/tr/*.json`.

Project/source:
https://github.com/risan/quran-json

Source package notes state:

- Arabic text: Uthmani Quran text from The Noble Qur'an Encyclopedia
- Turkish translation: Turkish chapter translation from quran-json
- License: CC BY-SA 4.0

Turkish okunuş/transliteration:
The available dataset contains Latin transliteration, but it is not a verified
Turkish okunuş source. To avoid inaccurate Quran reading text, this app keeps
`turkishTransliteration` nullable for this import and leaves it as `null`.
