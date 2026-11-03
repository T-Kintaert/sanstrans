# SansTrans – Sanskrit transliteration tool

**Deutsch** · [English below](#english)

**⬇ [SansTrans.exe herunterladen](https://github.com/t-kintaert/sanstrans/releases/latest/download/SansTrans.exe)** (Windows, aktuelle Version)

SansTrans hilft beim Tippen und Umwandeln von Sanskrit-Transliteration (IAST, ISO 15919 u. a.) unter Windows. Jede:r legt seine Tastenkürzel selbst fest, die App läuft in allen Programmen (Textverarbeitung, Browser, E-Mail …) und braucht keine Administratorrechte.

## Funktionen
- **Tastenkürzel für Diakritika**, z. B. `Alt+a` = ā, `Alt+s` = ś. Schemas: IAST, ISO 15919 und eigene.
- **Zusatzkürzel** (z. B. √, ḻ, ŭ) in eigenen Listen, die zusätzlich zum gewählten Schema gelten; jede Liste lässt sich im Menü unter „Zusatzkürzel“ per Klick an- oder ausschalten.
- **Zeichenpalette** (`Strg+Alt+Umschalt+P`): kleines Fenster mit allen Zusatzzeichen zum Anklicken, auch für selten benutzte Zeichen ohne Kürzel.
- **Export / Import:** Schemas, Zusatzkürzel und Einstellungen wählbar als eine `.json`-Datei sichern, auf ein anderes Gerät übertragen oder weitergeben.
- **Umwandlung** (Fenster oder Tastenkürzel): IAST, ISO 15919, Harvard-Kyoto, ITRANS, Velthuis, SLP1, Schichtschreibweise ⇄ Devanāgarī.
- **Live-Modus:** Devanāgarī direkt schreiben: Sie tippen die IAST-Umschrift auf der Tastatur, und Devanāgarī erscheint sofort (mit Ligaturen).
- **Text bereinigen:** Unicode-Normalisierung, Apostrophe, Leerzeichen, Silbentrennung.
- **Bonus (kein Sanskrit): Tibetisch.** Wylie ⇄ tibetische Schrift in den Stilen Uchen, Ume und Khyuyig (Schrift und Größe getrennt einstellbar).
- Menüs und Fenster auf **Deutsch und Englisch**.

## Download und Start
1. Direkt: [**SansTrans.exe**](https://github.com/t-kintaert/sanstrans/releases/latest/download/SansTrans.exe) herunterladen. Oder auf der Seite [**Releases**](https://github.com/t-kintaert/sanstrans/releases) die neueste Version öffnen und unter „Assets“ die Datei `SansTrans.exe` herunterladen.
2. **`SansTrans.exe`** doppelklicken. Das ā-Symbol erscheint unten rechts neben der Uhr im Infobereich der Taskleiste (ist es ausgeblendet, erscheint es erst nach einem Klick auf das kleine Pfeilsymbol am Rand des Infobereichs). Rechtsklick öffnet das Menü.
3. Optional im Menü **„Mit Windows starten“** anhaken.

> **Hinweis zu Windows-Warnungen:** Die `.exe` ist nicht signiert. Windows (die Sicherheitsfunktion „Microsoft Defender SmartScreen“) und manche Virenscanner zeigen deshalb beim ersten Start „Unbekannter Herausgeber“ an. Wählen Sie „Weitere Informationen“ ▸ „Trotzdem ausführen“.
> **Alternative ohne `.exe`:** [AutoHotkey v2](https://www.autohotkey.com/) installieren und die Datei `SansTrans.ahk` doppelklicken. Der Quelltext ist offen lesbar.

## Daten
Einstellungen, Schemas und Zusatzkürzel liegen als Textdateien im Ordner `%AppData%\SansTrans` (`%AppData%` steht für den Anwendungsdaten-Ordner des Benutzers; erreichbar über „Information…“ ▸ „Datenordner öffnen“ oder durch Eingabe von `%AppData%\SansTrans` in die Adresszeile des Explorers). Es werden keine Daten erfasst oder übertragen, und es wird keine Internetverbindung benötigt.

## Zitieren
Thomas Kintaert: *SansTrans – Sanskrit transliteration tool for Windows* (Version 1.10.5, 2026). [Institut für Südasien-, Tibet- und Buddhismuskunde](https://stb.univie.ac.at/), Universität Wien. https://github.com/t-kintaert/sanstrans

## Lizenz
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de): Die App darf geteilt und verändert werden (Namensnennung, nicht-kommerziell, Weitergabe unter gleichen Bedingungen).

## Konzeption, Quellen
- Konzeption: Thomas Kintaert, [Institut für Südasien-, Tibet- und Buddhismuskunde (ISTB)](https://stb.univie.ac.at/), Universität Wien. Erstellungszeitraum: Oktober 2026.
- Entwickelt im dialogischen Prozess mit Künstlicher Intelligenz (Claude Sonnet 5.5); geschrieben in AutoHotkey v2.
- Schichtschreibweise: entnommen dem [Sanskrit Writer](https://sri.auroville.org/projects/sanskrit-writer/) des Sanskrit Research Institute, Auroville.
- Wylie: Extended Wylie Transliteration Scheme (EWTS) der Tibetan and Himalayan Library, nach Turrell Wylie.
- IAST, ISO 15919, Harvard-Kyoto, ITRANS (Avinash Chopde), Velthuis (Frans Velthuis), SLP1 (Peter Scharf, Malcolm Hyman).

---

<a id="english"></a>
# SansTrans – Sanskrit transliteration tool (English)

**⬇ [Download SansTrans.exe](https://github.com/t-kintaert/sanstrans/releases/latest/download/SansTrans.exe)** (Windows, latest version)

SansTrans helps you type and convert Sanskrit transliteration (IAST, ISO 15919 and others) on Windows. Everyone defines their own keyboard shortcuts; it works in all programs (word processor, browser, e-mail …) and needs no administrator rights.

## Features
- **Shortcuts for diacritics**, e.g. `Alt+a` = ā, `Alt+s` = ś. Schemes: IAST, ISO 15919 and your own.
- **Extra shortcuts** (e.g. √, ḻ, ŭ) kept in lists of their own that apply in addition to the chosen scheme; each list can be switched on or off with a click in the menu under “Extra shortcuts”.
- **Character palette** (`Ctrl+Alt+Shift+P`): small window with all your extra characters to click, also for rarely used characters without a shortcut.
- **Export / Import:** save schemes, extra shortcuts and settings (selectable) as one `.json` file to move to another device or share.
- **Converter** (window or shortcuts): IAST, ISO 15919, Harvard-Kyoto, ITRANS, Velthuis, SLP1, layered notation ⇄ Devanāgarī.
- **Live mode:** write Devanāgarī directly: you type the IAST transliteration on the keyboard and Devanāgarī appears at once (with conjuncts).
- **Clean up text:** Unicode normalisation, apostrophes, spaces, hyphenation.
- **Bonus (not Sanskrit): Tibetan.** Wylie ⇄ Tibetan script in the styles Uchen, Ume and Khyuyig (font and size adjustable separately).
- Menus and windows in **German and English**.

## Download and start
1. Download directly: [**SansTrans.exe**](https://github.com/t-kintaert/sanstrans/releases/latest/download/SansTrans.exe). Or open the [**Releases**](https://github.com/t-kintaert/sanstrans/releases) page, open the latest release and download the file `SansTrans.exe` listed under “Assets”.
2. Double-click **`SansTrans.exe`**. The ā icon appears at the bottom right next to the clock, in the notification area of the taskbar (if it is hidden, it only appears after a click on the small arrow at the edge of the notification area). Right-click opens the menu.
3. Optionally tick **“Start with Windows”** in the menu.

> **About Windows warnings:** The `.exe` is not code-signed, so Windows (the security feature “Microsoft Defender SmartScreen”) and some virus scanners show “Unknown publisher” at first start. Choose “More info” ▸ “Run anyway”.
> **Alternative without the `.exe`:** install [AutoHotkey v2](https://www.autohotkey.com/) and double-click `SansTrans.ahk`. The source code is readable.

## Data
Settings, schemes and extra shortcuts are plain text files in the folder `%AppData%\SansTrans` (`%AppData%` stands for the user’s application-data folder; open it via “About…” ▸ “Open data folder”, or type `%AppData%\SansTrans` into the address bar of File Explorer). No data is collected or transmitted, and no internet connection is needed.

## Citation
Thomas Kintaert: *SansTrans – Sanskrit transliteration tool for Windows* (version 1.10.5, 2026). [Department of South Asian, Tibetan and Buddhist Studies](https://stb.univie.ac.at/en/), University of Vienna. https://github.com/t-kintaert/sanstrans

## Licence
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/): may be shared and modified (attribution, non-commercial, share-alike).

## Concept, sources
- Concept: Thomas Kintaert, [Department of South Asian, Tibetan and Buddhist Studies](https://stb.univie.ac.at/en/), University of Vienna. Created: October 2026.
- Developed in dialogue with artificial intelligence (Claude Sonnet 5.5); written in AutoHotkey v2.
- Layered notation: taken from the [Sanskrit Writer](https://sri.auroville.org/projects/sanskrit-writer/) of the Sanskrit Research Institute, Auroville.
- Wylie: Extended Wylie Transliteration Scheme (EWTS) of the Tibetan and Himalayan Library, after Turrell Wylie.
- IAST, ISO 15919, Harvard-Kyoto, ITRANS (Avinash Chopde), Velthuis (Frans Velthuis), SLP1 (Peter Scharf, Malcolm Hyman).
