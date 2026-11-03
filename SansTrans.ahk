#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

;@Ahk2Exe-SetName SansTrans
;@Ahk2Exe-SetDescription SansTrans – Sanskrit transliteration tool for Windows
;@Ahk2Exe-SetVersion 1.7.4

; ============================================================================
;  SansTrans  -  Sonderzeichen (IAST, ISO 15919, ...) per Tastenkuerzel
;  AutoHotkey v2. Kein Admin noetig. Arbeitet in allen Programmen.
;
;  Daten:  %AppData%\SansTrans\schemes\*.txt   (ein Schema = eine Textdatei)
;          %AppData%\SansTrans\settings.ini
;  Bedienung: Symbol im Infobereich (neben der Uhr) -> Rechtsklick.
; ============================================================================

APP := "SansTrans"
AppVersion := "1.10.5"
DataDir := A_AppData "\" APP
SchemeDir := DataDir "\schemes"
ExtraDir := DataDir "\extras"      ; Zusatzkuerzel (gelten zusaetzlich zum Schema)
ExtrasOn := []                      ; Namen der eingeschalteten Zusatzkuerzel
EdTarget := ""                      ; "" = Schema, sonst Name einer Zusatzkuerzel-Liste
IniFile := DataDir "\settings.ini"

CurrentScheme := "IAST"
PauseKey := "^!F12"
Paused := false
Rows := []             ; aktives Schema: Objekte {hk, out}
Active := Map()        ; aktuell registrierte Hotkeys
EdGui := ""            ; Editor-Fenster (leer = geschlossen)
EdRows := []
EdHeader := []
DevaKey := "^!+d"        ; Strg+Alt+Umschalt+D: Auswahl -> Devanagari
LatinKey := "^!+i"       ; Strg+Alt+Umschalt+I: Auswahl -> Transliteration
CleanKey := "^!+b"       ; Strg+Alt+Umschalt+B: Auswahl bereinigen
DevaProfile := "IAST"    ; gewaehltes Transliterationssystem (fuer Tastenkuerzel-Umwandlung)
DandaDot := true         ; Punkt = Danda
JoinWords := true        ; auslautenden Konsonanten mit folgendem Wortanfang verbinden
LatinFont := "Segoe UI"  ; Schrift fuer Transliteration in den Fenstern
DevaFont := "Nirmala UI" ; Schrift fuer Devanagari in den Fenstern
FontSize := 12
DevaSize := 12
Lang := "de"             ; Sprache der Hilfe
HelpLangs := [["de", "Deutsch"], ["en", "English"]]
EN := Map()
TibId := "Tibetisch"      ; interne Kennung (nie uebersetzen)
KsId := "Kürzel-Stil"     ; interne Kennung der Schichtschreibweise
SysIds := ["IAST", "ISO 15919", "Harvard-Kyoto", "ITRANS", "Velthuis", "SLP1", KsId, "Devanāgarī", "Wylie", TibId]
TibFonts := ["Microsoft Himalaya", "Microsoft Himalaya", "Microsoft Himalaya"]
TibStyle := 1
TibSizes := [17, 17, 17]     ; Schriftgroesse je Tibetisch-Stil (Uchen, Ume, Khyuyig)
CvStyle := ""
CvStyleTxt := ""
FcTib := []
FcTibSz := []
FcPrevT := []
InfoGui := ""
LiveKey := "^!+l"        ; Strg+Alt+Umschalt+L: Live-Modus ein/aus
PalKey := "^!+p"         ; Strg+Alt+Umschalt+P: Zeichenpalette
PalGui := ""
PalChars := []
PalBtn := Map()
PalStatus := ""
PalKeep := false
XfGui := ""
XfLV := ""
XfItems := []
XfMode := ""
XfBad := 0
XfNoReload := false
FcPos := 0
FcSig := ""
FcMsgReg := false
FcScrollOn := false
FcContentH := 0
FcClientH := 0
FcTibBtn := ""
FcBlocks := []
FcBtns := []
FcTibOpen := false
LiveOn := false
LiveHks := []
LiveChunks := []
LiveEmitted := ""
LivePrev := ""
LiveSp := false
HelpGui := ""
HelpEd := ""
FontGui := ""
FcLat := ""
FcDev := ""
FcSize := ""
FcPrevL := ""
FcPrevD := ""
DevaMaps := Map()
RevMaps := Map()
DevaName := "Devanāgarī"
LatSchemes := ["IAST", "ISO 15919", "Harvard-Kyoto", "ITRANS", "Velthuis", "SLP1", KsId]
LatFwd := Map()
LatMax := Map()
LatOut := Map()
WyCons := Map()
WySubj := Map()
WyVow := Map()
WyFinal := Map()
WyFClass := Map()
WyOther := Map()
WySup := Map()
WySub := Map()
WyTokens := Map()
WyTStart := Map()
TbTop := Map()
TbSubj := Map()
TbVow := Map()
TbVowL := Map()
TbFinW := Map()
TbFinC := Map()
TbCaret := Map()
TbOther := Map()
TbStacks := Map()
TbSuf := Map()
TbAmb := Map()
TbPre := Map()
TbSuf2 := Map()
WySloppy := [["ʼ", "'"], ["ʹ", "'"], ["‘", "'"], ["’", "'"], ["ʾ", "'"], ["...", "་་་"], [" (", "_("], [") ", ")_"], ["/ ", "/_"]]
CvFrom := ""
CvTo := ""
ClGui := ""
ClIn := ""
ClOut := ""
CleanOpts := {nfc: 1, spaces: 1, quotes: 1, invis: 1, dots: 1, hyeol: 1, hyall: 0}
ClBoxes := ""
CvDot := ""
CvJoin := ""
VIRAMA := Chr(0x094D)
CvGui := ""
CvIn := ""
CvOut := ""
LV := ""
CB := ""
EdKey := ""
EdOut := ""

; ---------------------------------------------------------------- Vorlagen
PresetIAST := "
(
# SansTrans - Schema: IAST
# Format: Modifier+Taste <Tab> Ausgabe        (Zeilen mit # sind Kommentare)
# Modifier: LAlt, RAlt (=AltGr), Alt, LCtrl, RCtrl, Ctrl, Shift, Win - mit + verbinden
# Ausgabe: normale Zeichen oder \uXXXX (z.B. \u0325 = Ring unter dem Buchstaben)
# Beliebig aendern/ergaenzen; am einfachsten ueber Tray-Symbol > Kuerzel bearbeiten.

LAlt+a	ā
LAlt+Shift+a	Ā
LAlt+i	ī
LAlt+Shift+i	Ī
LAlt+u	ū
LAlt+Shift+u	Ū
LAlt+g	ṅ
LAlt+Shift+g	Ṅ
LAlt+j	ñ
LAlt+Shift+j	Ñ
LAlt+t	ṭ
LAlt+Shift+t	Ṭ
LAlt+d	ḍ
LAlt+Shift+d	Ḍ
LAlt+n	ṇ
LAlt+Shift+n	Ṇ
LAlt+s	ś
LAlt+Shift+s	Ś
LAlt+x	ṣ
LAlt+Shift+x	Ṣ
LAlt+h	ḥ
LAlt+Shift+h	Ḥ
LAlt+r	ṛ
LAlt+Shift+r	Ṛ
LAlt+5	ṝ
LAlt+Shift+5	Ṝ
LAlt+l	ḷ
LAlt+Shift+l	Ḷ
LAlt+p	ḹ
LAlt+Shift+p	Ḹ
LAlt+m	ṃ
LAlt+Shift+m	Ṃ
)"

PresetIASTx := "
(
# SansTrans - Schema: Eigenes Schema
# Format: Modifier+Taste <Tab> Ausgabe        (Zeilen mit # sind Kommentare)
# Modifier: LAlt, RAlt (=AltGr), Alt, LCtrl, RCtrl, Ctrl, Shift, Win - mit + verbinden
# Ausgabe: normale Zeichen oder \uXXXX (z.B. \u0325 = Ring unter dem Buchstaben)
# Beliebig aendern/ergaenzen; am einfachsten ueber Tray-Symbol > Kuerzel bearbeiten.
# SC028 = Taste rechts neben ö (auf deutscher Tastatur: ä), unabhaengig vom Layout.

LAlt+a	ā
LAlt+Shift+a	Ā
LAlt+i	ī
LAlt+Shift+i	Ī
LAlt+u	ū
LAlt+Shift+u	Ū
LAlt+g	ṅ
LAlt+Shift+g	Ṅ
LAlt+j	ñ
LAlt+Shift+j	Ñ
LAlt+t	ṭ
LAlt+Shift+t	Ṭ
LAlt+d	ḍ
LAlt+Shift+d	Ḍ
LAlt+n	ṇ
LAlt+Shift+n	Ṇ
LAlt+s	ś
LAlt+Shift+s	Ś
LAlt+x	ṣ
LAlt+Shift+x	Ṣ
LAlt+h	ḥ
LAlt+Shift+h	Ḥ
LAlt+r	ṛ
LAlt+Shift+r	Ṛ
LAlt+5	ṝ
LAlt+Shift+5	Ṝ
LAlt+l	ḷ
LAlt+Shift+l	Ḷ
LAlt+p	ḹ
LAlt+Shift+p	Ḹ
LAlt+m	ṃ
LAlt+Shift+m	Ṃ
LAlt+e	ē
LAlt+Shift+e	Ē
LAlt+o	ō
LAlt+Shift+o	Ō
LAlt+z	ŭ
LAlt+Shift+z	Ŭ
LAlt+c	ç
LAlt+Shift+c	Ç
LAlt+SC028	’
LAlt+Shift+w	√
)"

PresetISO := "
(
# SansTrans - Schema: ISO 15919
# Format: Modifier+Taste <Tab> Ausgabe        (Zeilen mit # sind Kommentare)
# Modifier: LAlt, RAlt (=AltGr), Alt, LCtrl, RCtrl, Ctrl, Shift, Win - mit + verbinden
# Ausgabe: normale Zeichen oder \uXXXX (z.B. \u0325 = Ring unter dem Buchstaben)
# Beliebig aendern/ergaenzen; am einfachsten ueber Tray-Symbol > Kuerzel bearbeiten.
# ISO 15919: r̥ = r + U+0325, ṁ = Anusvara, m̐ = Candrabindu (Alt+c); ṛ (ड़) und ḷ (ळ) fehlen absichtlich.

LAlt+a	ā
LAlt+Shift+a	Ā
LAlt+i	ī
LAlt+Shift+i	Ī
LAlt+u	ū
LAlt+Shift+u	Ū
LAlt+g	ṅ
LAlt+Shift+g	Ṅ
LAlt+j	ñ
LAlt+Shift+j	Ñ
LAlt+t	ṭ
LAlt+Shift+t	Ṭ
LAlt+d	ḍ
LAlt+Shift+d	Ḍ
LAlt+n	ṇ
LAlt+Shift+n	Ṇ
LAlt+s	ś
LAlt+Shift+s	Ś
LAlt+x	ṣ
LAlt+Shift+x	Ṣ
LAlt+h	ḥ
LAlt+Shift+h	Ḥ
LAlt+r	r\u0325
LAlt+Shift+r	R\u0325
LAlt+5	r\u0325\u0304
LAlt+Shift+5	R\u0325\u0304
LAlt+l	l\u0325
LAlt+Shift+l	L\u0325
LAlt+p	l\u0325\u0304
LAlt+Shift+p	L\u0325\u0304
LAlt+m	ṁ
LAlt+Shift+m	Ṁ
LAlt+c	m\u0310
LAlt+Shift+c	M\u0310
LAlt+e	ē
LAlt+Shift+e	Ē
LAlt+o	ō
LAlt+Shift+o	Ō
)"

Presets := Map("IAST", PresetIAST, "ISO 15919", PresetISO)

; ------------------------------------------- Tabellen fuer Devanagari-Umwandlung
; Zeile: Zeichenfolge|Art|Zeichen|Matra   (Art: C Konsonant, V Vokal, M Zeichen wie Anusvara)
DevaTableIAST := "
(
A|V|अ|
B|C|ब|
C|C|च|
D|C|द|
E|V|ए|े
G|C|ग|
H|C|ह|
I|V|इ|ि
J|C|ज|
K|C|क|
L|C|ल|
M|C|म|
N|C|न|
O|V|ओ|ो
P|C|प|
R|C|र|
S|C|स|
T|C|त|
U|V|उ|ु
V|C|व|
Y|C|य|
a|V|अ|
b|C|ब|
c|C|च|
d|C|द|
e|V|ए|े
g|C|ग|
h|C|ह|
i|V|इ|ि
j|C|ज|
k|C|क|
l|C|ल|
m|C|म|
n|C|न|
o|V|ओ|ो
p|C|प|
r|C|र|
s|C|स|
t|C|त|
u|V|उ|ु
v|C|व|
y|C|य|
Ñ|C|ञ|
ñ|C|ञ|
Ā|V|आ|ा
ā|V|आ|ा
Ē|V|ए|े
ē|V|ए|े
Ī|V|ई|ी
ī|V|ई|ी
Ō|V|ओ|ो
ō|V|ओ|ो
Ś|C|श|
ś|C|श|
Ū|V|ऊ|ू
ū|V|ऊ|ू
Ḍ|C|ड|
ḍ|C|ड|
Ḥ|M|ः|
ḥ|M|ः|
Ḷ|V|ऌ|ॢ
ḷ|V|ऌ|ॢ
Ḹ|V|ॡ|ॣ
ḹ|V|ॡ|ॣ
Ṁ|M|ं|
ṁ|M|ं|
Ṃ|M|ं|
ṃ|M|ं|
Ṅ|C|ङ|
ṅ|C|ङ|
Ṇ|C|ण|
ṇ|C|ण|
Ṛ|V|ऋ|ृ
ṛ|V|ऋ|ृ
Ṝ|V|ॠ|ॄ
ṝ|V|ॠ|ॄ
Ṣ|C|ष|
ṣ|C|ष|
Ṭ|C|ट|
ṭ|C|ट|
AI|V|ऐ|ै
AU|V|औ|ौ
Ai|V|ऐ|ै
Au|V|औ|ौ
Ā|V|आ|ा
BH|C|भ|
Bh|C|भ|
CH|C|छ|
Ch|C|छ|
DH|C|ध|
Dh|C|ध|
Ḍ|C|ड|
Ē|V|ए|े
GH|C|घ|
Gh|C|घ|
Ḥ|M|ः|
Ī|V|ई|ी
JH|C|झ|
Jh|C|झ|
KH|C|ख|
Kh|C|ख|
Ḷ|V|ऌ|ॢ
L̥|V|ऌ|ॢ
Ṁ|M|ं|
M̐|M|ँ|
Ṃ|M|ं|
Ñ|C|ञ|
Ṅ|C|ङ|
Ṇ|C|ण|
Ō|V|ओ|ो
PH|C|फ|
Ph|C|फ|
Ṛ|V|ऋ|ृ
R̥|V|ऋ|ृ
Ś|C|श|
Ṣ|C|ष|
TH|C|थ|
Th|C|थ|
Ṭ|C|ट|
Ū|V|ऊ|ू
ai|V|ऐ|ै
au|V|औ|ौ
ā|V|आ|ा
bh|C|भ|
ch|C|छ|
dh|C|ध|
ḍ|C|ड|
ē|V|ए|े
gh|C|घ|
ḥ|M|ः|
ī|V|ई|ी
jh|C|झ|
kh|C|ख|
ḷ|V|ऌ|ॢ
l̥|V|ऌ|ॢ
ṁ|M|ं|
m̐|M|ँ|
ṃ|M|ं|
ñ|C|ञ|
ṅ|C|ङ|
ṇ|C|ण|
ō|V|ओ|ो
ph|C|फ|
ṛ|V|ऋ|ृ
r̥|V|ऋ|ृ
ś|C|श|
ṣ|C|ष|
th|C|थ|
ṭ|C|ट|
ū|V|ऊ|ू
ḌH|C|ढ|
Ḍh|C|ढ|
ḍh|C|ढ|
ṬH|C|ठ|
Ṭh|C|ठ|
ṭh|C|ठ|
ḌH|C|ढ|
Ḍh|C|ढ|
Ḹ|V|ॡ|ॣ
L̥̄|V|ॡ|ॣ
Ṝ|V|ॠ|ॄ
R̥̄|V|ॠ|ॄ
ṬH|C|ठ|
Ṭh|C|ठ|
ḍh|C|ढ|
ḹ|V|ॡ|ॣ
l̥̄|V|ॡ|ॣ
ṝ|V|ॠ|ॄ
r̥̄|V|ॠ|ॄ
ṭh|C|ठ|
)"

DevaTableISO := "
(
A|V|अ|
B|C|ब|
C|C|च|
D|C|द|
E|V|ए|े
G|C|ग|
H|C|ह|
I|V|इ|ि
J|C|ज|
K|C|क|
L|C|ल|
M|C|म|
N|C|न|
O|V|ओ|ो
P|C|प|
R|C|र|
S|C|स|
T|C|त|
U|V|उ|ु
V|C|व|
Y|C|य|
a|V|अ|
b|C|ब|
c|C|च|
d|C|द|
e|V|ए|े
g|C|ग|
h|C|ह|
i|V|इ|ि
j|C|ज|
k|C|क|
l|C|ल|
m|C|म|
n|C|न|
o|V|ओ|ो
p|C|प|
r|C|र|
s|C|स|
t|C|त|
u|V|उ|ु
v|C|व|
y|C|य|
Ñ|C|ञ|
ñ|C|ञ|
Ā|V|आ|ा
ā|V|आ|ा
Ē|V|ए|े
ē|V|ए|े
Ī|V|ई|ी
ī|V|ई|ी
Ō|V|ओ|ो
ō|V|ओ|ो
Ś|C|श|
ś|C|श|
Ū|V|ऊ|ू
ū|V|ऊ|ू
Ḍ|C|ड|
ḍ|C|ड|
Ḥ|M|ः|
ḥ|M|ः|
Ḷ|C|ळ|
ḷ|C|ळ|
Ṁ|M|ं|
ṁ|M|ं|
Ṃ|M|ं|
ṃ|M|ं|
Ṅ|C|ङ|
ṅ|C|ङ|
Ṇ|C|ण|
ṇ|C|ण|
Ṛ|C|ड़|
ṛ|C|ड़|
Ṣ|C|ष|
ṣ|C|ष|
Ṭ|C|ट|
ṭ|C|ट|
AI|V|ऐ|ै
AU|V|औ|ौ
Ai|V|ऐ|ै
Au|V|औ|ौ
Ā|V|आ|ा
BH|C|भ|
Bh|C|भ|
CH|C|छ|
Ch|C|छ|
DH|C|ध|
Dh|C|ध|
Ḍ|C|ड|
Ē|V|ए|े
GH|C|घ|
Gh|C|घ|
Ḥ|M|ः|
Ī|V|ई|ी
JH|C|झ|
Jh|C|झ|
KH|C|ख|
Kh|C|ख|
Ḷ|C|ळ|
L̥|V|ऌ|ॢ
Ṁ|M|ं|
M̐|M|ँ|
Ṃ|M|ं|
Ñ|C|ञ|
Ṅ|C|ङ|
Ṇ|C|ण|
Ō|V|ओ|ो
PH|C|फ|
Ph|C|फ|
Ṛ|C|ड़|
R̥|V|ऋ|ृ
Ś|C|श|
Ṣ|C|ष|
TH|C|थ|
Th|C|थ|
Ṭ|C|ट|
Ū|V|ऊ|ू
ai|V|ऐ|ै
au|V|औ|ौ
ā|V|आ|ा
bh|C|भ|
ch|C|छ|
dh|C|ध|
ḍ|C|ड|
ē|V|ए|े
gh|C|घ|
ḥ|M|ः|
ī|V|ई|ी
jh|C|झ|
kh|C|ख|
ḷ|C|ळ|
l̥|V|ऌ|ॢ
ṁ|M|ं|
m̐|M|ँ|
ṃ|M|ं|
ñ|C|ञ|
ṅ|C|ङ|
ṇ|C|ण|
ō|V|ओ|ो
ph|C|फ|
ṛ|C|ड़|
r̥|V|ऋ|ृ
ś|C|श|
ṣ|C|ष|
th|C|थ|
ṭ|C|ट|
ū|V|ऊ|ू
ḌH|C|ढ|
Ḍh|C|ढ|
ḍh|C|ढ|
ṚH|C|ढ़|
Ṛh|C|ढ़|
ṛh|C|ढ़|
ṬH|C|ठ|
Ṭh|C|ठ|
ṭh|C|ठ|
ḌH|C|ढ|
Ḍh|C|ढ|
L̥̄|V|ॡ|ॣ
ṚH|C|ढ़|
Ṛh|C|ढ़|
R̥̄|V|ॠ|ॄ
ṬH|C|ठ|
Ṭh|C|ठ|
ḍh|C|ढ|
l̥̄|V|ॡ|ॣ
ṛh|C|ढ़|
r̥̄|V|ॠ|ॄ
ṭh|C|ठ|
)"

; Rueckrichtung: Devanagari|Art|IAST|ISO 15919
DevaRevTable := "
(
क|C|k|k
ख|C|kh|kh
ग|C|g|g
घ|C|gh|gh
ङ|C|ṅ|ṅ
च|C|c|c
छ|C|ch|ch
ज|C|j|j
झ|C|jh|jh
ञ|C|ñ|ñ
ट|C|ṭ|ṭ
ठ|C|ṭh|ṭh
ड|C|ḍ|ḍ
ढ|C|ḍh|ḍh
ण|C|ṇ|ṇ
त|C|t|t
थ|C|th|th
द|C|d|d
ध|C|dh|dh
न|C|n|n
प|C|p|p
फ|C|ph|ph
ब|C|b|b
भ|C|bh|bh
म|C|m|m
य|C|y|y
र|C|r|r
ल|C|l|l
व|C|v|v
श|C|ś|ś
ष|C|ṣ|ṣ
स|C|s|s
ह|C|h|h
ळ|C|ḻ|ḷ
ड़|C|ḍ|ṛ
ढ़|C|ḍh|ṛh
ड़|C|ḍ|ṛ
ढ़|C|ḍh|ṛh
क़|C|q|q
ख़|C|x|x
ग़|C|ġ|ġ
ज़|C|z|z
फ़|C|f|f
अ|V|a|a
आ|V|ā|ā
इ|V|i|i
ई|V|ī|ī
उ|V|u|u
ऊ|V|ū|ū
ए|V|e|ē
ऐ|V|ai|ai
ओ|V|o|ō
औ|V|au|au
ऋ|V|ṛ|r̥
ॠ|V|ṝ|r̥̄
ऌ|V|ḷ|l̥
ॡ|V|ḹ|l̥̄
ा|M|ā|ā
ि|M|i|i
ी|M|ī|ī
ु|M|u|u
ू|M|ū|ū
े|M|e|ē
ै|M|ai|ai
ो|M|o|ō
ौ|M|au|au
ृ|M|ṛ|r̥
ॄ|M|ṝ|r̥̄
ॢ|M|ḷ|l̥
ॣ|M|ḹ|l̥̄
ं|K|ṃ|ṁ
ँ|K|m̐|m̐
ः|K|ḥ|ḥ
ऽ|K|’|’
ॐ|K|oṃ|oṃ
०|K|0|0
१|K|1|1
२|K|2|2
३|K|3|3
४|K|4|4
५|K|5|5
६|K|6|6
७|K|7|7
८|K|8|8
९|K|9|9
)"

; Tabellen fuer die Umwandlung zwischen Transliterationssystemen
; Zeile: System|Zeichenfolge|IAST-Token|GrossFlag
LatFwdTable := "
(
IAST|a|a|0
IAST|A|a|1
IAST|ā|ā|0
IAST|Ā|ā|1
IAST|ā|ā|0
IAST|Ā|ā|1
IAST|i|i|0
IAST|I|i|1
IAST|ī|ī|0
IAST|Ī|ī|1
IAST|ī|ī|0
IAST|Ī|ī|1
IAST|u|u|0
IAST|U|u|1
IAST|ū|ū|0
IAST|Ū|ū|1
IAST|ū|ū|0
IAST|Ū|ū|1
IAST|ṛ|ṛ|0
IAST|Ṛ|ṛ|1
IAST|ṛ|ṛ|0
IAST|Ṛ|ṛ|1
IAST|ṝ|ṝ|0
IAST|Ṝ|ṝ|1
IAST|ṝ|ṝ|0
IAST|Ṝ|ṝ|1
IAST|ḷ|ḷ|0
IAST|Ḷ|ḷ|1
IAST|ḷ|ḷ|0
IAST|Ḷ|ḷ|1
IAST|ḹ|ḹ|0
IAST|Ḹ|ḹ|1
IAST|ḹ|ḹ|0
IAST|Ḹ|ḹ|1
IAST|e|e|0
IAST|E|e|1
IAST|ai|ai|0
IAST|AI|ai|1
IAST|Ai|ai|1
IAST|o|o|0
IAST|O|o|1
IAST|au|au|0
IAST|Au|au|1
IAST|AU|au|1
IAST|ṃ|ṃ|0
IAST|Ṃ|ṃ|1
IAST|ṃ|ṃ|0
IAST|Ṃ|ṃ|1
IAST|ḥ|ḥ|0
IAST|Ḥ|ḥ|1
IAST|ḥ|ḥ|0
IAST|Ḥ|ḥ|1
IAST|m̐|m̐|0
IAST|M̐|m̐|1
IAST|k|k|0
IAST|K|k|1
IAST|kh|kh|0
IAST|Kh|kh|1
IAST|KH|kh|1
IAST|g|g|0
IAST|G|g|1
IAST|gh|gh|0
IAST|GH|gh|1
IAST|Gh|gh|1
IAST|ṅ|ṅ|0
IAST|Ṅ|ṅ|1
IAST|ṅ|ṅ|0
IAST|Ṅ|ṅ|1
IAST|c|c|0
IAST|C|c|1
IAST|ch|ch|0
IAST|Ch|ch|1
IAST|CH|ch|1
IAST|j|j|0
IAST|J|j|1
IAST|jh|jh|0
IAST|JH|jh|1
IAST|Jh|jh|1
IAST|ñ|ñ|0
IAST|Ñ|ñ|1
IAST|ñ|ñ|0
IAST|Ñ|ñ|1
IAST|ṭ|ṭ|0
IAST|Ṭ|ṭ|1
IAST|ṭ|ṭ|0
IAST|Ṭ|ṭ|1
IAST|ṭh|ṭh|0
IAST|ṬH|ṭh|1
IAST|Ṭh|ṭh|1
IAST|ṭh|ṭh|0
IAST|ṬH|ṭh|1
IAST|Ṭh|ṭh|1
IAST|ḍ|ḍ|0
IAST|Ḍ|ḍ|1
IAST|ḍ|ḍ|0
IAST|Ḍ|ḍ|1
IAST|ḍh|ḍh|0
IAST|ḌH|ḍh|1
IAST|Ḍh|ḍh|1
IAST|ḍh|ḍh|0
IAST|Ḍh|ḍh|1
IAST|ḌH|ḍh|1
IAST|ṇ|ṇ|0
IAST|Ṇ|ṇ|1
IAST|ṇ|ṇ|0
IAST|Ṇ|ṇ|1
IAST|t|t|0
IAST|T|t|1
IAST|th|th|0
IAST|TH|th|1
IAST|Th|th|1
IAST|d|d|0
IAST|D|d|1
IAST|dh|dh|0
IAST|DH|dh|1
IAST|Dh|dh|1
IAST|n|n|0
IAST|N|n|1
IAST|p|p|0
IAST|P|p|1
IAST|ph|ph|0
IAST|Ph|ph|1
IAST|PH|ph|1
IAST|b|b|0
IAST|B|b|1
IAST|bh|bh|0
IAST|BH|bh|1
IAST|Bh|bh|1
IAST|m|m|0
IAST|M|m|1
IAST|y|y|0
IAST|Y|y|1
IAST|r|r|0
IAST|R|r|1
IAST|l|l|0
IAST|L|l|1
IAST|v|v|0
IAST|V|v|1
IAST|ś|ś|0
IAST|Ś|ś|1
IAST|ś|ś|0
IAST|Ś|ś|1
IAST|ṣ|ṣ|0
IAST|Ṣ|ṣ|1
IAST|ṣ|ṣ|0
IAST|Ṣ|ṣ|1
IAST|s|s|0
IAST|S|s|1
IAST|h|h|0
IAST|H|h|1
IAST|’|’|1
IAST|ṁ|ṃ|0
IAST|Ṁ|ṃ|1
IAST|ṁ|ṃ|0
IAST|Ṁ|ṃ|1
IAST|ē|e|0
IAST|Ē|e|1
IAST|ē|e|0
IAST|Ē|e|1
IAST|ō|o|0
IAST|Ō|o|1
IAST|ō|o|0
IAST|Ō|o|1
ISO 15919|a|a|0
ISO 15919|A|a|1
ISO 15919|ā|ā|0
ISO 15919|Ā|ā|1
ISO 15919|ā|ā|0
ISO 15919|Ā|ā|1
ISO 15919|i|i|0
ISO 15919|I|i|1
ISO 15919|ī|ī|0
ISO 15919|Ī|ī|1
ISO 15919|ī|ī|0
ISO 15919|Ī|ī|1
ISO 15919|u|u|0
ISO 15919|U|u|1
ISO 15919|ū|ū|0
ISO 15919|Ū|ū|1
ISO 15919|ū|ū|0
ISO 15919|Ū|ū|1
ISO 15919|ṛ|ṛ|0
ISO 15919|Ṛ|ṛ|1
ISO 15919|ṛ|ṛ|0
ISO 15919|Ṛ|ṛ|1
ISO 15919|r̥|ṛ|0
ISO 15919|R̥|ṛ|1
ISO 15919|r̥̄|ṝ|0
ISO 15919|R̥̄|ṝ|1
ISO 15919|ṝ|ṝ|0
ISO 15919|Ṝ|ṝ|1
ISO 15919|ṝ|ṝ|0
ISO 15919|Ṝ|ṝ|1
ISO 15919|l̥|ḷ|0
ISO 15919|L̥|ḷ|1
ISO 15919|ḷ|ḷ|0
ISO 15919|Ḷ|ḷ|1
ISO 15919|ḷ|ḷ|0
ISO 15919|Ḷ|ḷ|1
ISO 15919|l̥̄|ḹ|0
ISO 15919|L̥̄|ḹ|1
ISO 15919|ḹ|ḹ|0
ISO 15919|Ḹ|ḹ|1
ISO 15919|ḹ|ḹ|0
ISO 15919|Ḹ|ḹ|1
ISO 15919|ē|e|0
ISO 15919|Ē|e|1
ISO 15919|ē|e|0
ISO 15919|Ē|e|1
ISO 15919|e|e|0
ISO 15919|E|e|1
ISO 15919|ai|ai|0
ISO 15919|AI|ai|1
ISO 15919|Ai|ai|1
ISO 15919|o|o|0
ISO 15919|O|o|1
ISO 15919|ō|o|0
ISO 15919|Ō|o|1
ISO 15919|ō|o|0
ISO 15919|Ō|o|1
ISO 15919|au|au|0
ISO 15919|Au|au|1
ISO 15919|AU|au|1
ISO 15919|ṁ|ṃ|0
ISO 15919|Ṁ|ṃ|1
ISO 15919|ṁ|ṃ|0
ISO 15919|Ṁ|ṃ|1
ISO 15919|ṃ|ṃ|0
ISO 15919|Ṃ|ṃ|1
ISO 15919|ṃ|ṃ|0
ISO 15919|Ṃ|ṃ|1
ISO 15919|ḥ|ḥ|0
ISO 15919|Ḥ|ḥ|1
ISO 15919|ḥ|ḥ|0
ISO 15919|Ḥ|ḥ|1
ISO 15919|m̐|m̐|0
ISO 15919|M̐|m̐|1
ISO 15919|k|k|0
ISO 15919|K|k|1
ISO 15919|kh|kh|0
ISO 15919|Kh|kh|1
ISO 15919|KH|kh|1
ISO 15919|g|g|0
ISO 15919|G|g|1
ISO 15919|gh|gh|0
ISO 15919|GH|gh|1
ISO 15919|Gh|gh|1
ISO 15919|ṅ|ṅ|0
ISO 15919|Ṅ|ṅ|1
ISO 15919|ṅ|ṅ|0
ISO 15919|Ṅ|ṅ|1
ISO 15919|c|c|0
ISO 15919|C|c|1
ISO 15919|ch|ch|0
ISO 15919|Ch|ch|1
ISO 15919|CH|ch|1
ISO 15919|j|j|0
ISO 15919|J|j|1
ISO 15919|jh|jh|0
ISO 15919|JH|jh|1
ISO 15919|Jh|jh|1
ISO 15919|ñ|ñ|0
ISO 15919|Ñ|ñ|1
ISO 15919|ñ|ñ|0
ISO 15919|Ñ|ñ|1
ISO 15919|ṭ|ṭ|0
ISO 15919|Ṭ|ṭ|1
ISO 15919|ṭ|ṭ|0
ISO 15919|Ṭ|ṭ|1
ISO 15919|ṭh|ṭh|0
ISO 15919|ṬH|ṭh|1
ISO 15919|Ṭh|ṭh|1
ISO 15919|ṭh|ṭh|0
ISO 15919|ṬH|ṭh|1
ISO 15919|Ṭh|ṭh|1
ISO 15919|ḍ|ḍ|0
ISO 15919|Ḍ|ḍ|1
ISO 15919|ḍ|ḍ|0
ISO 15919|Ḍ|ḍ|1
ISO 15919|ḍh|ḍh|0
ISO 15919|ḌH|ḍh|1
ISO 15919|Ḍh|ḍh|1
ISO 15919|ḍh|ḍh|0
ISO 15919|Ḍh|ḍh|1
ISO 15919|ḌH|ḍh|1
ISO 15919|ṇ|ṇ|0
ISO 15919|Ṇ|ṇ|1
ISO 15919|ṇ|ṇ|0
ISO 15919|Ṇ|ṇ|1
ISO 15919|t|t|0
ISO 15919|T|t|1
ISO 15919|th|th|0
ISO 15919|TH|th|1
ISO 15919|Th|th|1
ISO 15919|d|d|0
ISO 15919|D|d|1
ISO 15919|dh|dh|0
ISO 15919|DH|dh|1
ISO 15919|Dh|dh|1
ISO 15919|n|n|0
ISO 15919|N|n|1
ISO 15919|p|p|0
ISO 15919|P|p|1
ISO 15919|ph|ph|0
ISO 15919|Ph|ph|1
ISO 15919|PH|ph|1
ISO 15919|b|b|0
ISO 15919|B|b|1
ISO 15919|bh|bh|0
ISO 15919|BH|bh|1
ISO 15919|Bh|bh|1
ISO 15919|m|m|0
ISO 15919|M|m|1
ISO 15919|y|y|0
ISO 15919|Y|y|1
ISO 15919|r|r|0
ISO 15919|R|r|1
ISO 15919|l|l|0
ISO 15919|L|l|1
ISO 15919|v|v|0
ISO 15919|V|v|1
ISO 15919|ś|ś|0
ISO 15919|Ś|ś|1
ISO 15919|ś|ś|0
ISO 15919|Ś|ś|1
ISO 15919|ṣ|ṣ|0
ISO 15919|Ṣ|ṣ|1
ISO 15919|ṣ|ṣ|0
ISO 15919|Ṣ|ṣ|1
ISO 15919|s|s|0
ISO 15919|S|s|1
ISO 15919|h|h|0
ISO 15919|H|h|1
ISO 15919|’|’|1
Harvard-Kyoto|A|ā|0
Harvard-Kyoto|I|ī|0
Harvard-Kyoto|U|ū|0
Harvard-Kyoto|R|ṛ|0
Harvard-Kyoto|RR|ṝ|0
Harvard-Kyoto|lR|ḷ|0
Harvard-Kyoto|lRR|ḹ|0
Harvard-Kyoto|M|ṃ|0
Harvard-Kyoto|H|ḥ|0
Harvard-Kyoto|G|ṅ|0
Harvard-Kyoto|J|ñ|0
Harvard-Kyoto|T|ṭ|0
Harvard-Kyoto|Th|ṭh|0
Harvard-Kyoto|D|ḍ|0
Harvard-Kyoto|Dh|ḍh|0
Harvard-Kyoto|N|ṇ|0
Harvard-Kyoto|z|ś|0
Harvard-Kyoto|S|ṣ|0
Harvard-Kyoto|'|’|0
Harvard-Kyoto|a|a|0
Harvard-Kyoto|i|i|0
Harvard-Kyoto|u|u|0
Harvard-Kyoto|e|e|0
Harvard-Kyoto|ai|ai|0
Harvard-Kyoto|o|o|0
Harvard-Kyoto|au|au|0
Harvard-Kyoto|m̐|m̐|0
Harvard-Kyoto|k|k|0
Harvard-Kyoto|kh|kh|0
Harvard-Kyoto|g|g|0
Harvard-Kyoto|gh|gh|0
Harvard-Kyoto|c|c|0
Harvard-Kyoto|ch|ch|0
Harvard-Kyoto|j|j|0
Harvard-Kyoto|jh|jh|0
Harvard-Kyoto|t|t|0
Harvard-Kyoto|th|th|0
Harvard-Kyoto|d|d|0
Harvard-Kyoto|dh|dh|0
Harvard-Kyoto|n|n|0
Harvard-Kyoto|p|p|0
Harvard-Kyoto|ph|ph|0
Harvard-Kyoto|b|b|0
Harvard-Kyoto|bh|bh|0
Harvard-Kyoto|m|m|0
Harvard-Kyoto|y|y|0
Harvard-Kyoto|r|r|0
Harvard-Kyoto|l|l|0
Harvard-Kyoto|v|v|0
Harvard-Kyoto|s|s|0
Harvard-Kyoto|h|h|0
ITRANS|aa|ā|0
ITRANS|ii|ī|0
ITRANS|uu|ū|0
ITRANS|RRi|ṛ|0
ITRANS|RRI|ṝ|0
ITRANS|LLi|ḷ|0
ITRANS|LLI|ḹ|0
ITRANS|M|ṃ|0
ITRANS|H|ḥ|0
ITRANS|.N|m̐|0
ITRANS|~N|ṅ|0
ITRANS|Ch|ch|0
ITRANS|~n|ñ|0
ITRANS|T|ṭ|0
ITRANS|Th|ṭh|0
ITRANS|D|ḍ|0
ITRANS|Dh|ḍh|0
ITRANS|N|ṇ|0
ITRANS|sh|ś|0
ITRANS|Sh|ṣ|0
ITRANS|.a|’|0
ITRANS|a|a|0
ITRANS|i|i|0
ITRANS|u|u|0
ITRANS|e|e|0
ITRANS|ai|ai|0
ITRANS|o|o|0
ITRANS|au|au|0
ITRANS|k|k|0
ITRANS|kh|kh|0
ITRANS|g|g|0
ITRANS|gh|gh|0
ITRANS|c|c|0
ITRANS|j|j|0
ITRANS|jh|jh|0
ITRANS|t|t|0
ITRANS|th|th|0
ITRANS|d|d|0
ITRANS|dh|dh|0
ITRANS|n|n|0
ITRANS|p|p|0
ITRANS|ph|ph|0
ITRANS|b|b|0
ITRANS|bh|bh|0
ITRANS|m|m|0
ITRANS|y|y|0
ITRANS|r|r|0
ITRANS|l|l|0
ITRANS|v|v|0
ITRANS|s|s|0
ITRANS|h|h|0
ITRANS|A|ā|0
ITRANS|I|ī|0
ITRANS|U|ū|0
ITRANS|R^i|ṛ|0
ITRANS|R^I|ṝ|0
ITRANS|L^i|ḷ|0
ITRANS|L^I|ḹ|0
ITRANS|.n|ṃ|0
ITRANS|.m|ṃ|0
ITRANS|chh|ch|0
ITRANS|N^|ṅ|0
ITRANS|JN|ñ|0
ITRANS|x|kṣ|0
ITRANS|GY|jñ|0
Velthuis|aa|ā|0
Velthuis|ii|ī|0
Velthuis|uu|ū|0
Velthuis|.r|ṛ|0
Velthuis|.rr|ṝ|0
Velthuis|.l|ḷ|0
Velthuis|.ll|ḹ|0
Velthuis|.m|ṃ|0
Velthuis|.h|ḥ|0
Velthuis|"n|ṅ|0
Velthuis|~n|ñ|0
Velthuis|.t|ṭ|0
Velthuis|.th|ṭh|0
Velthuis|.d|ḍ|0
Velthuis|.dh|ḍh|0
Velthuis|.n|ṇ|0
Velthuis|"s|ś|0
Velthuis|.s|ṣ|0
Velthuis|'|’|0
Velthuis|a|a|0
Velthuis|i|i|0
Velthuis|u|u|0
Velthuis|e|e|0
Velthuis|ai|ai|0
Velthuis|o|o|0
Velthuis|au|au|0
Velthuis|m̐|m̐|0
Velthuis|k|k|0
Velthuis|kh|kh|0
Velthuis|g|g|0
Velthuis|gh|gh|0
Velthuis|c|c|0
Velthuis|ch|ch|0
Velthuis|j|j|0
Velthuis|jh|jh|0
Velthuis|t|t|0
Velthuis|th|th|0
Velthuis|d|d|0
Velthuis|dh|dh|0
Velthuis|n|n|0
Velthuis|p|p|0
Velthuis|ph|ph|0
Velthuis|b|b|0
Velthuis|bh|bh|0
Velthuis|m|m|0
Velthuis|y|y|0
Velthuis|r|r|0
Velthuis|l|l|0
Velthuis|v|v|0
Velthuis|s|s|0
Velthuis|h|h|0
SLP1|A|ā|0
SLP1|I|ī|0
SLP1|U|ū|0
SLP1|f|ṛ|0
SLP1|F|ṝ|0
SLP1|x|ḷ|0
SLP1|X|ḹ|0
SLP1|E|ai|0
SLP1|O|au|0
SLP1|M|ṃ|0
SLP1|H|ḥ|0
SLP1|~|m̐|0
SLP1|K|kh|0
SLP1|G|gh|0
SLP1|N|ṅ|0
SLP1|C|ch|0
SLP1|J|jh|0
SLP1|Y|ñ|0
SLP1|w|ṭ|0
SLP1|W|ṭh|0
SLP1|q|ḍ|0
SLP1|Q|ḍh|0
SLP1|R|ṇ|0
SLP1|T|th|0
SLP1|D|dh|0
SLP1|P|ph|0
SLP1|B|bh|0
SLP1|S|ś|0
SLP1|z|ṣ|0
SLP1|'|’|0
SLP1|a|a|0
SLP1|i|i|0
SLP1|u|u|0
SLP1|e|e|0
SLP1|o|o|0
SLP1|k|k|0
SLP1|g|g|0
SLP1|c|c|0
SLP1|j|j|0
SLP1|t|t|0
SLP1|d|d|0
SLP1|n|n|0
SLP1|p|p|0
SLP1|b|b|0
SLP1|m|m|0
SLP1|y|y|0
SLP1|r|r|0
SLP1|l|l|0
SLP1|v|v|0
SLP1|s|s|0
SLP1|h|h|0
Kürzel-Stil|-a|ā|0
Kürzel-Stil|-i|ī|0
Kürzel-Stil|-u|ū|0
Kürzel-Stil|r.|ṛ|0
Kürzel-Stil|-r.|ṝ|0
Kürzel-Stil|l.|ḷ|0
Kürzel-Stil|-l.|ḹ|0
Kürzel-Stil|m.|ṃ|0
Kürzel-Stil|h.|ḥ|0
Kürzel-Stil|m~|m̐|0
Kürzel-Stil|.n|ṅ|0
Kürzel-Stil|~n|ñ|0
Kürzel-Stil|t.|ṭ|0
Kürzel-Stil|t.h|ṭh|0
Kürzel-Stil|d.|ḍ|0
Kürzel-Stil|d.h|ḍh|0
Kürzel-Stil|n.|ṇ|0
Kürzel-Stil|'s|ś|0
Kürzel-Stil|s.|ṣ|0
Kürzel-Stil|'|’|0
Kürzel-Stil|a|a|0
Kürzel-Stil|i|i|0
Kürzel-Stil|u|u|0
Kürzel-Stil|e|e|0
Kürzel-Stil|ai|ai|0
Kürzel-Stil|o|o|0
Kürzel-Stil|au|au|0
Kürzel-Stil|k|k|0
Kürzel-Stil|kh|kh|0
Kürzel-Stil|g|g|0
Kürzel-Stil|gh|gh|0
Kürzel-Stil|c|c|0
Kürzel-Stil|ch|ch|0
Kürzel-Stil|j|j|0
Kürzel-Stil|jh|jh|0
Kürzel-Stil|t|t|0
Kürzel-Stil|th|th|0
Kürzel-Stil|d|d|0
Kürzel-Stil|dh|dh|0
Kürzel-Stil|n|n|0
Kürzel-Stil|p|p|0
Kürzel-Stil|ph|ph|0
Kürzel-Stil|b|b|0
Kürzel-Stil|bh|bh|0
Kürzel-Stil|m|m|0
Kürzel-Stil|y|y|0
Kürzel-Stil|r|r|0
Kürzel-Stil|l|l|0
Kürzel-Stil|v|v|0
Kürzel-Stil|s|s|0
Kürzel-Stil|h|h|0
Kürzel-Stil|\.|.|0
Kürzel-Stil|\-|-|0
Kürzel-Stil|\~|~|0
Kürzel-Stil|\'|’|0
Kürzel-Stil|--|-|0
Kürzel-Stil|``s|ś|0
Kürzel-Stil|’s|ś|0
Kürzel-Stil|´s|ś|0
)"

; Zeile: System|IAST-Token|Zeichenfolge im System
LatOutTable := "
(
ISO 15919|ṛ|r̥
ISO 15919|ṝ|r̥̄
ISO 15919|ḷ|l̥
ISO 15919|ḹ|l̥̄
ISO 15919|ṃ|ṁ
ISO 15919|e|ē
ISO 15919|o|ō
Harvard-Kyoto|ā|A
Harvard-Kyoto|ī|I
Harvard-Kyoto|ū|U
Harvard-Kyoto|ṛ|R
Harvard-Kyoto|ṝ|RR
Harvard-Kyoto|ḷ|lR
Harvard-Kyoto|ḹ|lRR
Harvard-Kyoto|ṃ|M
Harvard-Kyoto|ḥ|H
Harvard-Kyoto|ṅ|G
Harvard-Kyoto|ñ|J
Harvard-Kyoto|ṭ|T
Harvard-Kyoto|ṭh|Th
Harvard-Kyoto|ḍ|D
Harvard-Kyoto|ḍh|Dh
Harvard-Kyoto|ṇ|N
Harvard-Kyoto|ś|z
Harvard-Kyoto|ṣ|S
Harvard-Kyoto|’|'
ITRANS|ā|aa
ITRANS|ī|ii
ITRANS|ū|uu
ITRANS|ṛ|RRi
ITRANS|ṝ|RRI
ITRANS|ḷ|LLi
ITRANS|ḹ|LLI
ITRANS|ṃ|M
ITRANS|ḥ|H
ITRANS|m̐|.N
ITRANS|ṅ|~N
ITRANS|ñ|~n
ITRANS|ṭ|T
ITRANS|ṭh|Th
ITRANS|ḍ|D
ITRANS|ḍh|Dh
ITRANS|ṇ|N
ITRANS|ś|sh
ITRANS|ṣ|Sh
ITRANS|ch|Ch
ITRANS|’|.a
Velthuis|ā|aa
Velthuis|ī|ii
Velthuis|ū|uu
Velthuis|ṛ|.r
Velthuis|ṝ|.rr
Velthuis|ḷ|.l
Velthuis|ḹ|.ll
Velthuis|ṃ|.m
Velthuis|ḥ|.h
Velthuis|ṅ|"n
Velthuis|ñ|~n
Velthuis|ṭ|.t
Velthuis|ṭh|.th
Velthuis|ḍ|.d
Velthuis|ḍh|.dh
Velthuis|ṇ|.n
Velthuis|ś|"s
Velthuis|ṣ|.s
Velthuis|’|'
SLP1|ā|A
SLP1|ī|I
SLP1|ū|U
SLP1|ṛ|f
SLP1|ṝ|F
SLP1|ḷ|x
SLP1|ḹ|X
SLP1|ai|E
SLP1|au|O
SLP1|ṃ|M
SLP1|ḥ|H
SLP1|m̐|~
SLP1|kh|K
SLP1|gh|G
SLP1|ṅ|N
SLP1|ch|C
SLP1|jh|J
SLP1|ñ|Y
SLP1|ṭ|w
SLP1|ṭh|W
SLP1|ḍ|q
SLP1|ḍh|Q
SLP1|ṇ|R
SLP1|th|T
SLP1|dh|D
SLP1|ph|P
SLP1|bh|B
SLP1|ś|S
SLP1|ṣ|z
SLP1|’|'
Kürzel-Stil|ā|-a
Kürzel-Stil|ī|-i
Kürzel-Stil|ū|-u
Kürzel-Stil|ṝ|-r.
Kürzel-Stil|ḹ|-l.
Kürzel-Stil|ṛ|r.
Kürzel-Stil|ḷ|l.
Kürzel-Stil|ṭ|t.
Kürzel-Stil|ṭh|t.h
Kürzel-Stil|ḍ|d.
Kürzel-Stil|ḍh|d.h
Kürzel-Stil|ṇ|n.
Kürzel-Stil|ṣ|s.
Kürzel-Stil|ḥ|h.
Kürzel-Stil|ṃ|m.
Kürzel-Stil|m̐|m~
Kürzel-Stil|ś|'s
Kürzel-Stil|ṅ|.n
Kürzel-Stil|ñ|~n
Kürzel-Stil|’|'
)"

; Wylie (EWTS) -> Tibetisch: Art Schluessel Wert (Unicode hexadezimal)
WylieTable := "
(
CONS 006B 0F40
CONS 006B-0068 0F41
CONS 0067 0F42
CONS 0067-0068 0F42-0FB7
CONS 0067-002B-0068 0F42-0FB7
CONS 006E-0067 0F44
CONS 0063 0F45
CONS 0063-0068 0F46
CONS 006A 0F47
CONS 006E-0079 0F49
CONS 0054 0F4A
CONS 002D-0074 0F4A
CONS 0054-0068 0F4B
CONS 002D-0074-0068 0F4B
CONS 0044 0F4C
CONS 002D-0064 0F4C
CONS 0044-0068 0F4C-0FB7
CONS 0044-002B-0068 0F4C-0FB7
CONS 002D-0064-0068 0F4C-0FB7
CONS 002D-0064-002B-0068 0F4C-0FB7
CONS 004E 0F4E
CONS 002D-006E 0F4E
CONS 0074 0F4F
CONS 0074-0068 0F50
CONS 0064 0F51
CONS 0064-0068 0F51-0FB7
CONS 0064-002B-0068 0F51-0FB7
CONS 006E 0F53
CONS 0070 0F54
CONS 0070-0068 0F55
CONS 0062 0F56
CONS 0062-0068 0F56-0FB7
CONS 0062-002B-0068 0F56-0FB7
CONS 006D 0F58
CONS 0074-0073 0F59
CONS 0074-0073-0068 0F5A
CONS 0064-007A 0F5B
CONS 0064-007A-0068 0F5B-0FB7
CONS 0064-007A-002B-0068 0F5B-0FB7
CONS 0077 0F5D
CONS 007A-0068 0F5E
CONS 007A 0F5F
CONS 0027 0F60
CONS 0079 0F61
CONS 0072 0F62
CONS 006C 0F63
CONS 0073-0068 0F64
CONS 0053-0068 0F65
CONS 002D-0073-0068 0F65
CONS 0073 0F66
CONS 0068 0F67
CONS 0057 0F5D
CONS 0059 0F61
CONS 0052 0F6A
CONS 0066 0F55-0F39
CONS 0076 0F56-0F39
SUBJ 006B 0F90
SUBJ 006B-0068 0F91
SUBJ 0067 0F92
SUBJ 0067-0068 0F92-0FB7
SUBJ 0067-002B-0068 0F92-0FB7
SUBJ 006E-0067 0F94
SUBJ 0063 0F95
SUBJ 0063-0068 0F96
SUBJ 006A 0F97
SUBJ 006E-0079 0F99
SUBJ 0054 0F9A
SUBJ 002D-0074 0F9A
SUBJ 0054-0068 0F9B
SUBJ 002D-0074-0068 0F9B
SUBJ 0044 0F9C
SUBJ 002D-0064 0F9C
SUBJ 0044-0068 0F9C-0FB7
SUBJ 0044-002B-0068 0F9C-0FB7
SUBJ 002D-0064-0068 0F9C-0FB7
SUBJ 002D-0064-002B-0068 0F9C-0FB7
SUBJ 004E 0F9E
SUBJ 002D-006E 0F9E
SUBJ 0074 0F9F
SUBJ 0074-0068 0FA0
SUBJ 0064 0FA1
SUBJ 0064-0068 0FA1-0FB7
SUBJ 0064-002B-0068 0FA1-0FB7
SUBJ 006E 0FA3
SUBJ 0070 0FA4
SUBJ 0070-0068 0FA5
SUBJ 0062 0FA6
SUBJ 0062-0068 0FA6-0FB7
SUBJ 0062-002B-0068 0FA6-0FB7
SUBJ 006D 0FA8
SUBJ 0074-0073 0FA9
SUBJ 0074-0073-0068 0FAA
SUBJ 0064-007A 0FAB
SUBJ 0064-007A-0068 0FAB-0FB7
SUBJ 0064-007A-002B-0068 0FAB-0FB7
SUBJ 0077 0FAD
SUBJ 007A-0068 0FAE
SUBJ 007A 0FAF
SUBJ 0027 0FB0
SUBJ 0079 0FB1
SUBJ 0072 0FB2
SUBJ 006C 0FB3
SUBJ 0073-0068 0FB4
SUBJ 0053-0068 0FB5
SUBJ 002D-0073-0068 0FB5
SUBJ 0073 0FB6
SUBJ 0068 0FB7
SUBJ 0061 0FB8
SUBJ 0057 0FBA
SUBJ 0059 0FBB
SUBJ 0052 0FBC
VOW 0061 0F68
VOW 0041 0F71
VOW 0069 0F72
VOW 0049 0F71-0F72
VOW 0075 0F74
VOW 0055 0F71-0F74
VOW 0065 0F7A
VOW 0061-0069 0F7B
VOW 006F 0F7C
VOW 0061-0075 0F7D
VOW 002D-0069 0F80
VOW 002D-0049 0F71-0F80
FINAL 004D 0F7E
FINAL 007E-004D 0F83
FINAL 0058 0F37
FINAL 007E-0058 0F35
FINAL 0048 0F7F
FINAL 003F 0F84
FINAL 005E 0F39
FINAL 0026 0F85
FCLASS 004D 004D
FCLASS 007E-004D 004D
FCLASS 0058 0058
FCLASS 007E-0058 0058
FCLASS 0048 0048
FCLASS 003F 003F
FCLASS 005E 005E
FCLASS 0026 0026
OTHER 0030 0F20
OTHER 0031 0F21
OTHER 0032 0F22
OTHER 0033 0F23
OTHER 0034 0F24
OTHER 0035 0F25
OTHER 0036 0F26
OTHER 0037 0F27
OTHER 0038 0F28
OTHER 0039 0F29
OTHER 0020 0F0B
OTHER 002A 0F0C
OTHER 002F 0F0D
OTHER 002F-002F 0F0E
OTHER 003B 0F0F
OTHER 007C 0F11
OTHER 0021 0F08
OTHER 003A 0F14
OTHER 005F 0020
OTHER 003D 0F34
OTHER 003C 0F3A
OTHER 003E 0F3B
OTHER 0028 0F3C
OTHER 0029 0F3D
OTHER 0040 0F04
OTHER 0023 0F05
OTHER 0024 0F06
OTHER 0025 0F07
SUP 0072 0062
SUP 0072 0062-002B-0077
SUP 0072 0064
SUP 0072 0064-007A
SUP 0072 0067
SUP 0072 0067-002B-0077
SUP 0072 0067-002B-0079
SUP 0072 006A
SUP 0072 006B
SUP 0072 006B-002B-0079
SUP 0072 006D
SUP 0072 006D-002B-0079
SUP 0072 006E
SUP 0072 006E-0067
SUP 0072 006E-0079
SUP 0072 0074
SUP 0072 0074-0073
SUP 0072 0074-0073-002B-0077
SUP 006C 0062
SUP 006C 0063
SUP 006C 0064
SUP 006C 0067
SUP 006C 0068
SUP 006C 006A
SUP 006C 006B
SUP 006C 006E-0067
SUP 006C 0070
SUP 006C 0074
SUP 0073 0062
SUP 0073 0062-002B-0072
SUP 0073 0062-002B-0079
SUP 0073 0064
SUP 0073 0067
SUP 0073 0067-002B-0072
SUP 0073 0067-002B-0079
SUP 0073 006B
SUP 0073 006B-002B-0072
SUP 0073 006B-002B-0079
SUP 0073 006D
SUP 0073 006D-002B-0072
SUP 0073 006D-002B-0079
SUP 0073 006E
SUP 0073 006E-002B-0072
SUP 0073 006E-0067
SUP 0073 006E-0079
SUP 0073 0070
SUP 0073 0070-002B-0072
SUP 0073 0070-002B-0079
SUP 0073 0074
SUP 0073 0074-0073
SUP 0079 0062
SUP 0079 0067
SUP 0079 006B
SUP 0079 006B-0068
SUP 0079 006D
SUP 0079 0070
SUP 0079 0070-0068
SUP 0079 0072-002B-0067
SUP 0079 0072-002B-006B
SUP 0079 0072-002B-006D
SUP 0079 0073-002B-0062
SUP 0079 0073-002B-0067
SUP 0079 0073-002B-006B
SUP 0079 0073-002B-006D
SUP 0079 0073-002B-0070
SUB 0079 0062
SUB 0079 0067
SUB 0079 006B
SUB 0079 006B-0068
SUB 0079 006D
SUB 0079 0070
SUB 0079 0070-0068
SUB 0079 0072-002B-0067
SUB 0079 0072-002B-006B
SUB 0079 0072-002B-006D
SUB 0079 0073-002B-0062
SUB 0079 0073-002B-0067
SUB 0079 0073-002B-006B
SUB 0079 0073-002B-006D
SUB 0079 0073-002B-0070
SUB 0072 0062
SUB 0072 0064
SUB 0072 0064-007A
SUB 0072 0067
SUB 0072 0068
SUB 0072 006B
SUB 0072 006B-0068
SUB 0072 006D
SUB 0072 006E
SUB 0072 0070
SUB 0072 0070-0068
SUB 0072 0073
SUB 0072 0073-002B-0062
SUB 0072 0073-002B-0067
SUB 0072 0073-002B-006B
SUB 0072 0073-002B-006D
SUB 0072 0073-002B-006E
SUB 0072 0073-002B-0070
SUB 0072 0073-0068
SUB 0072 0074
SUB 0072 0074-0068
SUB 006C 0062
SUB 006C 0067
SUB 006C 006B
SUB 006C 0072
SUB 006C 0073
SUB 006C 007A
SUB 0077 0063
SUB 0077 0064
SUB 0077 0064-002B-0072
SUB 0077 0067
SUB 0077 0067-002B-0072
SUB 0077 0068
SUB 0077 006B
SUB 0077 006B-0068
SUB 0077 006C
SUB 0077 006E-0079
SUB 0077 0070-0068-002B-0079
SUB 0077 0072
SUB 0077 0072-002B-0067
SUB 0077 0072-002B-0074-0073
SUB 0077 0073
SUB 0077 0073-0068
SUB 0077 0074
SUB 0077 0074-0073
SUB 0077 0074-0073-0068
SUB 0077 007A
SUB 0077 007A-0068
TOK 002D-0064-002B-0068 _
TOK 0064-007A-002B-0068 _
TOK 002D-0064-0068 _
TOK 002D-0073-0068 _
TOK 002D-0074-0068 _
TOK 0044-002B-0068 _
TOK 0062-002B-0068 _
TOK 0064-002B-0068 _
TOK 0064-007A-0068 _
TOK 0067-002B-0068 _
TOK 0074-0073-0068 _
TOK 002D-0049 _
TOK 002D-0064 _
TOK 002D-0069 _
TOK 002D-006E _
TOK 002D-0074 _
TOK 002F-002F _
TOK 0044-0068 _
TOK 0053-0068 _
TOK 0054-0068 _
TOK 0061-0069 _
TOK 0061-0075 _
TOK 0062-0068 _
TOK 0063-0068 _
TOK 0064-0068 _
TOK 0064-007A _
TOK 0067-0068 _
TOK 006B-0068 _
TOK 006E-0067 _
TOK 006E-0079 _
TOK 0070-0068 _
TOK 0073-0068 _
TOK 0074-0068 _
TOK 0074-0073 _
TOK 007A-0068 _
TOK 007E-004D _
TOK 007E-0058 _
TOK 000D-000A _
TOP 0F40 006B
TOP 0F41 006B-0068
TOP 0F42 0067
TOP 0F43 0067-002B-0068
TOP 0F44 006E-0067
TOP 0F45 0063
TOP 0F46 0063-0068
TOP 0F47 006A
TOP 0F49 006E-0079
TOP 0F4A 0054
TOP 0F4B 0054-0068
TOP 0F4C 0044
TOP 0F4D 0044-002B-0068
TOP 0F4E 004E
TOP 0F4F 0074
TOP 0F50 0074-0068
TOP 0F51 0064
TOP 0F52 0064-002B-0068
TOP 0F53 006E
TOP 0F54 0070
TOP 0F55 0070-0068
TOP 0F56 0062
TOP 0F57 0062-002B-0068
TOP 0F58 006D
TOP 0F59 0074-0073
TOP 0F5A 0074-0073-0068
TOP 0F5B 0064-007A
TOP 0F5C 0064-007A-002B-0068
TOP 0F5D 0077
TOP 0F5E 007A-0068
TOP 0F5F 007A
TOP 0F60 0027
TOP 0F61 0079
TOP 0F62 0072
TOP 0F63 006C
TOP 0F64 0073-0068
TOP 0F65 0053-0068
TOP 0F66 0073
TOP 0F67 0068
TOP 0F68 0061
TOP 0F69 006B-002B-0053-0068
TOP 0F6A 0052
TSUBJ 0F90 006B
TSUBJ 0F91 006B-0068
TSUBJ 0F92 0067
TSUBJ 0F93 0067-002B-0068
TSUBJ 0F94 006E-0067
TSUBJ 0F95 0063
TSUBJ 0F96 0063-0068
TSUBJ 0F97 006A
TSUBJ 0F99 006E-0079
TSUBJ 0F9A 0054
TSUBJ 0F9B 0054-0068
TSUBJ 0F9C 0044
TSUBJ 0F9D 0044-002B-0068
TSUBJ 0F9E 004E
TSUBJ 0F9F 0074
TSUBJ 0FA0 0074-0068
TSUBJ 0FA1 0064
TSUBJ 0FA2 0064-002B-0068
TSUBJ 0FA3 006E
TSUBJ 0FA4 0070
TSUBJ 0FA5 0070-0068
TSUBJ 0FA6 0062
TSUBJ 0FA7 0062-002B-0068
TSUBJ 0FA8 006D
TSUBJ 0FA9 0074-0073
TSUBJ 0FAA 0074-0073-0068
TSUBJ 0FAB 0064-007A
TSUBJ 0FAC 0064-007A-002B-0068
TSUBJ 0FAD 0077
TSUBJ 0FAE 007A-0068
TSUBJ 0FAF 007A
TSUBJ 0FB0 0027
TSUBJ 0FB1 0079
TSUBJ 0FB2 0072
TSUBJ 0FB3 006C
TSUBJ 0FB4 0073-0068
TSUBJ 0FB5 0053-0068
TSUBJ 0FB6 0073
TSUBJ 0FB7 0068
TSUBJ 0FB8 0061
TSUBJ 0FB9 006B-002B-0053-0068
TSUBJ 0FBA 0057
TSUBJ 0FBB 0059
TSUBJ 0FBC 0052
TVOW 0F71 0041
TVOW 0F72 0069
TVOW 0F73 0049
TVOW 0F74 0075
TVOW 0F75 0055
TVOW 0F7A 0065
TVOW 0F7B 0061-0069
TVOW 0F7C 006F
TVOW 0F7D 0061-0075
TVOW 0F80 002D-0069
TVOWL 0069 0049
TVOWL 0075 0055
TVOWL 002D-0069 002D-0049
TFINW 0F7E 004D
TFINW 0F82 007E-004D-0060
TFINW 0F83 007E-004D
TFINW 0F37 0058
TFINW 0F35 007E-0058
TFINW 0F39 005E
TFINW 0F7F 0048
TFINW 0F84 003F
TFINW 0F85 0026
TFINC 0F7E 004D
TFINC 0F82 004D
TFINC 0F83 004D
TFINC 0F37 0058
TFINC 0F35 0058
TFINC 0F39 005E
TFINC 0F7F 0048
TFINC 0F84 003F
TFINC 0F85 0026
TCARET 0070-0068 0066
TCARET 0062 0076
TOTH 0020 005F
TOTH 0F04 0040
TOTH 0F05 0023
TOTH 0F06 0024
TOTH 0F07 0025
TOTH 0F08 0021
TOTH 0F0B 0020
TOTH 0F0C 002A
TOTH 0F0D 002F
TOTH 0F0E 002F-002F
TOTH 0F0F 003B
TOTH 0F11 007C
TOTH 0F14 003A
TOTH 0F20 0030
TOTH 0F21 0031
TOTH 0F22 0032
TOTH 0F23 0033
TOTH 0F24 0034
TOTH 0F25 0035
TOTH 0F26 0036
TOTH 0F27 0037
TOTH 0F28 0038
TOTH 0F29 0039
TOTH 0F34 003D
TOTH 0F3A 003C
TOTH 0F3B 003E
TOTH 0F3C 0028
TOTH 0F3D 0029
TSTK 0062-002B-006C _
TSTK 0062-002B-0072 _
TSTK 0062-002B-0079 _
TSTK 0063-002B-0077 _
TSTK 0064-002B-0072 _
TSTK 0064-002B-0072-002B-0077 _
TSTK 0064-002B-0077 _
TSTK 0064-007A-002B-0072 _
TSTK 0067-002B-006C _
TSTK 0067-002B-0072 _
TSTK 0067-002B-0072-002B-0077 _
TSTK 0067-002B-0077 _
TSTK 0067-002B-0079 _
TSTK 0068-002B-0072 _
TSTK 0068-002B-0077 _
TSTK 006B-002B-006C _
TSTK 006B-002B-0072 _
TSTK 006B-002B-0077 _
TSTK 006B-002B-0079 _
TSTK 006B-0068-002B-0072 _
TSTK 006B-0068-002B-0077 _
TSTK 006B-0068-002B-0079 _
TSTK 006C-002B-0062 _
TSTK 006C-002B-0063 _
TSTK 006C-002B-0064 _
TSTK 006C-002B-0067 _
TSTK 006C-002B-0068 _
TSTK 006C-002B-006A _
TSTK 006C-002B-006B _
TSTK 006C-002B-006E-0067 _
TSTK 006C-002B-0070 _
TSTK 006C-002B-0074 _
TSTK 006C-002B-0077 _
TSTK 006D-002B-0072 _
TSTK 006D-002B-0079 _
TSTK 006E-002B-0072 _
TSTK 006E-0079-002B-0077 _
TSTK 0070-002B-0072 _
TSTK 0070-002B-0079 _
TSTK 0070-0068-002B-0072 _
TSTK 0070-0068-002B-0079 _
TSTK 0070-0068-002B-0079-002B-0077 _
TSTK 0072-002B-0062 _
TSTK 0072-002B-0064 _
TSTK 0072-002B-0064-007A _
TSTK 0072-002B-0067 _
TSTK 0072-002B-0067-002B-0077 _
TSTK 0072-002B-0067-002B-0079 _
TSTK 0072-002B-006A _
TSTK 0072-002B-006B _
TSTK 0072-002B-006B-002B-0079 _
TSTK 0072-002B-006C _
TSTK 0072-002B-006D _
TSTK 0072-002B-006D-002B-0079 _
TSTK 0072-002B-006E _
TSTK 0072-002B-006E-0067 _
TSTK 0072-002B-006E-0079 _
TSTK 0072-002B-0074 _
TSTK 0072-002B-0074-0073 _
TSTK 0072-002B-0074-0073-002B-0077 _
TSTK 0072-002B-0077 _
TSTK 0073-002B-0062 _
TSTK 0073-002B-0062-002B-0072 _
TSTK 0073-002B-0062-002B-0079 _
TSTK 0073-002B-0064 _
TSTK 0073-002B-0067 _
TSTK 0073-002B-0067-002B-0072 _
TSTK 0073-002B-0067-002B-0079 _
TSTK 0073-002B-006B _
TSTK 0073-002B-006B-002B-0072 _
TSTK 0073-002B-006B-002B-0079 _
TSTK 0073-002B-006C _
TSTK 0073-002B-006D _
TSTK 0073-002B-006D-002B-0072 _
TSTK 0073-002B-006D-002B-0079 _
TSTK 0073-002B-006E _
TSTK 0073-002B-006E-002B-0072 _
TSTK 0073-002B-006E-0067 _
TSTK 0073-002B-006E-0079 _
TSTK 0073-002B-0070 _
TSTK 0073-002B-0070-002B-0072 _
TSTK 0073-002B-0070-002B-0079 _
TSTK 0073-002B-0072 _
TSTK 0073-002B-0074 _
TSTK 0073-002B-0074-0073 _
TSTK 0073-002B-0077 _
TSTK 0073-0068-002B-0072 _
TSTK 0073-0068-002B-0077 _
TSTK 0074-002B-0072 _
TSTK 0074-002B-0077 _
TSTK 0074-0068-002B-0072 _
TSTK 0074-0073-002B-0077 _
TSTK 0074-0073-0068-002B-0077 _
TSTK 007A-002B-006C _
TSTK 007A-002B-0077 _
TSTK 007A-0068-002B-0077 _
TSUF 0027 _
TSUF 0067 _
TSUF 006E-0067 _
TSUF 0064 _
TSUF 006E _
TSUF 0062 _
TSUF 006D _
TSUF 0072 _
TSUF 006C _
TSUF 0073 _
TSUF 004E _
TSUF 0054 _
TSUF 002D-006E _
TSUF 002D-0074 _
TAMB 0064-0067-0073 0031
TAMB 0064-006D-0073 0031
TAMB 0064-006E-0067-0073 0030
TAMB 0027-0067-0073 0031
TAMB 0027-0062-0073 0031
TAMB 006D-006E-0067-0073 0030
TAMB 006D-0067-0073 0030
TAMB 0062-0067-0073 0030
TAMB 0064-0062-0073 0031
TPRE 0067 0063
TPRE 0067 006E-0079
TPRE 0067 0074
TPRE 0067 0064
TPRE 0067 006E
TPRE 0067 0074-0073
TPRE 0067 007A-0068
TPRE 0067 007A
TPRE 0067 0079
TPRE 0067 0073-0068
TPRE 0067 0073
TPRE 0064 006B
TPRE 0064 0067
TPRE 0064 006E-0067
TPRE 0064 0070
TPRE 0064 0062
TPRE 0064 006D
TPRE 0064 006B-002B-0079
TPRE 0064 0067-002B-0079
TPRE 0064 0070-002B-0079
TPRE 0064 0062-002B-0079
TPRE 0064 006D-002B-0079
TPRE 0064 006B-002B-0072
TPRE 0064 0067-002B-0072
TPRE 0064 0070-002B-0072
TPRE 0064 0062-002B-0072
TPRE 0062 006B
TPRE 0062 0067
TPRE 0062 0063
TPRE 0062 0074
TPRE 0062 0064
TPRE 0062 0074-0073
TPRE 0062 007A-0068
TPRE 0062 007A
TPRE 0062 0073-0068
TPRE 0062 0073
TPRE 0062 0072
TPRE 0062 006C
TPRE 0062 006B-002B-0079
TPRE 0062 0067-002B-0079
TPRE 0062 006B-002B-0072
TPRE 0062 0067-002B-0072
TPRE 0062 0072-002B-006C
TPRE 0062 0073-002B-006C
TPRE 0062 0072-002B-006B
TPRE 0062 0072-002B-0067
TPRE 0062 0072-002B-006E-0067
TPRE 0062 0072-002B-006A
TPRE 0062 0072-002B-006E-0079
TPRE 0062 0072-002B-0074
TPRE 0062 0072-002B-0064
TPRE 0062 0072-002B-006E
TPRE 0062 0072-002B-0074-0073
TPRE 0062 0072-002B-0064-007A
TPRE 0062 0073-002B-006B
TPRE 0062 0073-002B-0067
TPRE 0062 0073-002B-006E-0067
TPRE 0062 0073-002B-006E-0079
TPRE 0062 0073-002B-0074
TPRE 0062 0073-002B-0064
TPRE 0062 0073-002B-006E
TPRE 0062 0073-002B-0074-0073
TPRE 0062 0072-002B-006B-002B-0079
TPRE 0062 0072-002B-0067-002B-0079
TPRE 0062 0073-002B-006B-002B-0079
TPRE 0062 0073-002B-0067-002B-0079
TPRE 0062 0073-002B-006B-002B-0072
TPRE 0062 0073-002B-0067-002B-0072
TPRE 0062 006C-002B-0064
TPRE 0062 006C-002B-0074
TPRE 0062 006B-002B-006C
TPRE 0062 0073-002B-0072
TPRE 0062 007A-002B-006C
TPRE 0062 0073-002B-0077
TPRE 006D 006B-0068
TPRE 006D 0067
TPRE 006D 006E-0067
TPRE 006D 0063-0068
TPRE 006D 006A
TPRE 006D 006E-0079
TPRE 006D 0074-0068
TPRE 006D 0064
TPRE 006D 006E
TPRE 006D 0074-0073-0068
TPRE 006D 0064-007A
TPRE 006D 006B-0068-002B-0079
TPRE 006D 0067-002B-0079
TPRE 006D 006B-0068-002B-0072
TPRE 006D 0067-002B-0072
TPRE 0027 006B-0068
TPRE 0027 0067
TPRE 0027 0063-0068
TPRE 0027 006A
TPRE 0027 0074-0068
TPRE 0027 0064
TPRE 0027 0070-0068
TPRE 0027 0062
TPRE 0027 0074-0073-0068
TPRE 0027 0064-007A
TPRE 0027 006B-0068-002B-0079
TPRE 0027 0067-002B-0079
TPRE 0027 0070-0068-002B-0079
TPRE 0027 0062-002B-0079
TPRE 0027 006B-0068-002B-0072
TPRE 0027 0067-002B-0072
TPRE 0027 0064-002B-0072
TPRE 0027 0070-0068-002B-0072
TPRE 0027 0062-002B-0072
TSUF2 0073 0067
TSUF2 0073 006E-0067
TSUF2 0073 0062
TSUF2 0073 006D
TSUF2 0064 006E
TSUF2 0064 0072
TSUF2 0064 006C
)"

Main()
return

; ================================================================== START
; Daten frueherer Versionen: Ordner TranslitKeys -> SansTrans, deutsche Dateinamen -> englische
MigrateOldData() {
    old := A_AppData "\TranslitKeys"
    if (!DirExist(DataDir) && DirExist(old)) {
        try {
            DirCopy(old, DataDir)
        }
    }
    DirCreate(SchemeDir)
    DirCreate(ExtraDir)
    for oldName in ["Eigenes Schema", "IAST erweitert"] {
        if (FileExist(SchemePath(oldName)) && !FileExist(SchemePath("Own_scheme"))) {
            try {
                FileMove(SchemePath(oldName), SchemePath("Own_scheme"))
            }
        }
    }
    if (FileExist(ExtraPath("Eigene Kürzel")) && !FileExist(ExtraPath("Own_shortcuts"))) {
        try {
            FileMove(ExtraPath("Eigene Kürzel"), ExtraPath("Own_shortcuts"))
        }
    }
    try {
        sch := IniRead(IniFile, "General", "Scheme", "")
        if (sch = "Eigenes Schema" || sch = "IAST erweitert") {
            IniWrite("Own_scheme", IniFile, "General", "Scheme")
        }
        ex := IniRead(IniFile, "General", "Extras", "")
        if (InStr(ex, "Eigene Kürzel")) {
            IniWrite(StrReplace(ex, "Eigene Kürzel", "Own_shortcuts"), IniFile, "General", "Extras")
        }
    }
}

Main() {
    global CurrentScheme, PauseKey, DevaKey, LatinKey, DevaProfile, DandaDot, JoinWords
    global LatinFont, DevaFont, FontSize, DevaSize, Lang, LiveKey, CleanKey, PalKey, PalKeep
    LoadEn()
    MigrateOldData()
    EnsurePresets(false)

    firstRun := !FileExist(IniFile)
    if (firstRun) {
        IniWrite("IAST", IniFile, "General", "Scheme")
        IniWrite("^!F12", IniFile, "General", "PauseKey")
    }
    CurrentScheme := IniRead(IniFile, "General", "Scheme", "IAST")
    PauseKey := IniRead(IniFile, "General", "PauseKey", "^!F12")
    DevaKey := IniRead(IniFile, "General", "DevaKey", "^!+d")
    LatinKey := IniRead(IniFile, "General", "LatinKey", "^!+i")
    DandaDot := (IniRead(IniFile, "General", "DandaDot", "1") = "1")
    JoinWords := (IniRead(IniFile, "General", "JoinWords", "1") = "1")
    LiveKey := IniRead(IniFile, "General", "LiveKey", "^!+l")
    CleanKey := IniRead(IniFile, "General", "CleanKey", "^!+b")
    PalKey := IniRead(IniFile, "General", "PalKey", "^!+p")
    PalKeep := (IniRead(IniFile, "General", "PalKeep", "0") = "1")
    LatinFont := IniRead(IniFile, "General", "LatinFont", "Segoe UI")
    DevaFont := IniRead(IniFile, "General", "DevaFont", "Nirmala UI")
    FontSize := FontSizeOf(IniRead(IniFile, "General", "FontSize", "12"))
    DevaSize := FontSizeOf(IniRead(IniFile, "General", "DevaSize", String(FontSize)))
    Lang := IniRead(IniFile, "General", "Lang", "")
    if (Lang != "de" && Lang != "en") {
        Lang := firstRun ? "" : DefaultLang()
    }
    LoadTibSettings()
    DevaProfile := IniRead(IniFile, "General", "DevaProfile", "IAST")
    if (!LatIsScheme(DevaProfile)) {
        DevaProfile := "IAST"
    }
    LoadDevaTables()
    LoadLatTables()
    LoadWylieTables()
    LoadCleanOpts()
    LoadExtras()
    if (!FileExist(SchemePath(CurrentScheme))) {
        CurrentScheme := "IAST"
    }

    try {
        Hotkey(PauseKey, (*) => TogglePause())
    } catch as e {
        HkErr("Pause", PauseKey, e.Message, "PauseKey")
    }

    try {
        Hotkey(DevaKey, (*) => ConvertSelection("toDeva"))
    } catch as e {
        HkErr("Devanāgarī", DevaKey, e.Message, "DevaKey")
    }
    try {
        Hotkey(LatinKey, (*) => ConvertSelection("toLatin"))
    } catch as e {
        HkErr("Transliteration", LatinKey, e.Message, "LatinKey")
    }

    try {
        Hotkey(LiveKey, (*) => LiveToggle())
    } catch as e {
        HkErr("Live-Modus", LiveKey, e.Message, "LiveKey")
    }

    try {
        Hotkey(CleanKey, (*) => CleanSelection())
    } catch as e {
        HkErr("Bereinigen", CleanKey, e.Message, "CleanKey")
    }

    try {
        Hotkey(PalKey, (*) => TogglePalette())
    } catch as e {
        HkErr(PalLbl(), PalKey, e.Message, "PalKey")
    }
    OnMessage(0x200, PalMove)

    ShowErrors(ActivateScheme(CurrentScheme))

    if (firstRun) {
        ChooseLang()
        ShowHelp(true)
        if (MsgBox("Soll SansTrans künftig automatisch mit Windows starten?`nShould SansTrans start automatically with Windows?", APP, "YesNo Icon?") = "Yes") {
            SetAutostart(true)
            BuildTray()
        }
    } else {
        TrayTip(T("Aktiv: ") CurrentScheme, APP)
    }
}

; ================================================================ SPRACHE
LoadEn() {
    EN["Aktiv: "] := "Active: "
    EN["Pausiert - normale Tastatur"] := "Paused - normal keyboard"
    EN["Pausiert (normale Tastatur)"] := "Paused (normal keyboard)"
    EN[" + Live-Modus"] := " + live mode"
    EN["Sprache: Deutsch"] := "Language: English"
    EN["Diese Zeilen wurden übersprungen:`n`n"] := "These lines were skipped:`n`n"
    EN["Pausieren / Fortsetzen"] := "Pause / Resume"
    EN["Schema wählen"] := "Choose scheme"
        EN["Kürzel bearbeiten..."] := "Edit shortcuts..."
    EN["Schema neu laden (nach Änderung im Texteditor)"] := "Reload scheme (after editing it in a text editor)"
    EN["Neues Schema (Kopie des aktuellen)..."] := "New scheme (copy of the current one)..."
    EN["Schema-Ordner öffnen"] := "Open scheme folder"
    EN["Mitgelieferte Vorlagen wiederherstellen"] := "Restore bundled templates"
    EN["Umwandlung (Fenster): Transliteration, Devanāgarī, Tibetisch..."] := "Converter (window): transliteration, Devanāgarī, Tibetan..."
    EN["Text bereinigen (Fenster)..."] := "Clean up text (window)..."
    EN["Markierten Text bereinigen (Strg+Alt+Umschalt+B)"] := "Clean up selected text (Ctrl+Alt+Shift+B)"
    EN["Transliterationssystem für Strg+Alt+Umschalt+D/I"] := "Transliteration system for Ctrl+Alt+Shift+D/I"
    EN["Punkt (.) = Daṇḍa"] := "Full stop (.) = daṇḍa"
    EN["Auslautende Konsonanten mit dem nächsten Anlaut verbinden"] := "Join final consonants with the beginning of the next word"
    EN["Umwandlung: Optionen"] := "Converter options"
    EN["Live-Modus: Transliteration tippen, Devanāgarī erscheint (Strg+Alt+Umschalt+L)"] := "Live mode: type transliteration, Devanāgarī appears (Ctrl+Alt+Shift+L)"
    EN["Schriftart..."] := "Fonts..."
    EN["Zusatzkürzel (gelten zusätzlich zum Schema)"] := "Extra shortcuts (apply in addition to the scheme)"
    EN["Zusatzkürzel bearbeiten..."] := "Edit extra shortcuts..."
    EN["Neue Zusatzkürzelliste..."] := "New list of extra shortcuts..."
    EN["Zusatzkürzel-Ordner öffnen"] := "Open extra shortcuts folder"
    EN["Zusatzkürzel"] := "Extra shortcuts"
    EN["Zeichenpalette"] := "Character palette"
    EN["Export / Import"] := "Export / Import"
    EN["Exportieren..."] := "Export..."
    EN["Importieren..."] := "Import..."
    EN["Exportieren"] := "Export"
    EN["Importieren"] := "Import"
    EN["Hake an, was exportiert werden soll:"] := "Tick what should be exported:"
    EN["Hake an, was importiert werden soll:"] := "Tick what should be imported:"
    EN["Inhalt"] := "Content"
    EN["Art"] := "Type"
    EN["Alle"] := "All"
    EN["Keine"] := "None"
    EN["Schema"] := "Scheme"
    EN["Zusatzkürzelliste"] := "List of extra shortcuts"
    EN["Einstellungen"] := "Settings"
    EN["Sprache"] := "Language"
    EN["Bereinigen: Optionen"] := "Clean-up options"
    EN["Tastenkürzel der App (Umwandlung, Live-Modus, Bereinigen, Zeichenpalette, Pause)"] := "App shortcuts (converter, live mode, clean-up, character palette, pause)"
    EN["Schriften und Größen (auf anderen Geräten evtl. nicht installiert)"] := "Fonts and sizes (may not be installed on other devices)"
    EN["Aktive Auswahl (Schema, eingeschaltete Zusatzkürzellisten)"] := "Active selection (scheme, switched-on lists of extra shortcuts)"
    EN["Nichts angehakt."] := "Nothing ticked."
    EN["Es gibt nichts zu exportieren."] := "There is nothing to export."
    EN["Datei nicht lesbar: "] := "File not readable: "
    EN["Das ist keine SansTrans-Exportdatei."] := "This is not a SansTrans export file."
    EN["Die Datei enthält nichts Importierbares."] := "The file contains nothing that can be imported."
    EN["Konnte nicht schreiben: "] := "Could not write: "
    EN["Exportiert: {1} Einträge nach {2}"] := "Exported: {1} entries to {2}"
    EN["'{1}' gibt es schon. Was soll geschehen?"] := "'{1}' already exists. What should happen?"
    EN["Überschreiben"] := "Overwrite"
    EN["Neuer Name"] := "New name"
    EN["Überspringen"] := "Skip"
    EN["Für alle weiteren gleich entscheiden"] := "Decide the same way for all others"
    EN["Importiert: {1} Einträge.{2}`nSansTrans startet jetzt neu, um alles zu laden."] := "Imported: {1} entries.{2}`nSansTrans now restarts to load everything."
    EN["`n{1} ungültige Einträge wurden übersprungen."] := "`n{1} invalid entries were skipped."
    EN["Zeichenpalette (Strg+Alt+Umschalt+P)"] := "Character palette (Ctrl+Alt+Shift+P)"
    EN["In der Zeichenpalette anzeigen"] := "Show in character palette"
    EN["Taste leer lassen: Das Zeichen erscheint dann nur in der Zeichenpalette."] := "Leave the key empty: the character then appears only in the character palette."
    EN["Ohne Kürzel muss das Zeichen in der Zeichenpalette erscheinen."] := "Without a shortcut the character must appear in the character palette."
    EN["Die Zeichenpalette ist leer. Schalten Sie unter 'Zusatzkürzel' eine Liste mit Zeichen ein oder legen Sie Zeichen im Zusatzkürzel-Editor an."] := "The character palette is empty. Switch on a list with characters under 'Extra shortcuts' or add characters in the extra-shortcuts editor."
    EN["offen lassen"] := "keep open"
    EN["ja"] := "yes"
    EN["nein"] := "no"
    EN["Klick = Zeichen einfügen"] := "Click = insert character"
    EN["kein Kürzel"] := "no shortcut"
    EN["Name der neuen Zusatzkürzelliste:"] := "Name of the new list of extra shortcuts:"
    EN["Eine Liste mit diesem Namen gibt es bereits."] := "A list with this name already exists."
    EN["Zusatzkürzel '{1}' nicht lesbar: {2}"] := "Extra shortcuts '{1}' not readable: {2}"
    EN["Größe Uchen"] := "Size Uchen"
    EN["Mit Windows starten"] := "Start with Windows"
    EN["Anleitung..."] := "Guide..."
    EN["Information..."] := "About..."
    EN["Beenden"] := "Exit"
    EN["Name des neuen Schemas (es wird als Kopie des aktuellen angelegt):"] := "Name of the new scheme (it is created as a copy of the current one):"
    EN["Ungültiger Name (keine Zeichen wie \ / : * ? `" < > |)."] := "Invalid name (no characters such as \ / : * ? `" < > |)."
    EN["Ein Schema mit diesem Namen gibt es schon."] := "A scheme with this name already exists."
    EN["Die Schemas IAST und ISO 15919 werden auf den Auslieferungszustand zurückgesetzt.`nEigene Änderungen daran gehen verloren (selbst angelegte Schemas und Zusatzkürzel bleiben).`n`nFortfahren?"] := "The schemes IAST and ISO 15919 will be reset to their original state.`nYour changes to them will be lost (Custom scheme and schemes you created stay).`n`nContinue?"
    EN["Autostart konnte nicht geändert werden: "] := "Autostart could not be changed: "
    EN["Schema nicht lesbar: "] := "Scheme not readable: "
    EN["Kürzel bearbeiten: "] := "Edit shortcuts: "
    EN["Taste"] := "Key"
    EN["Ausgabe"] := "Output"
    EN["Setzen"] := "Set"
    EN["Löschen"] := "Delete"
    EN["Taste: a, 5, F5, Numpad1, SC028 (= Tastenposition) ...   Ausgabe: Zeichen oder ̥ (Unicode-Code).`n"] := "Key: a, 5, F5, Numpad1, SC028 (= key position) ...   Output: characters or \u0325 (Unicode code).`n"
    EN["'Setzen' fügt hinzu oder überschreibt das gleiche Kürzel. Erst 'Speichern' übernimmt alles."] := "'Set' adds or overwrites the same shortcut. Only 'Save' applies everything."
    EN["Ausgabe ist leer"] := "Output is empty"
    EN["Speichern und anwenden"] := "Save and apply"
    EN["Abbrechen"] := "Cancel"
    EN["Datei im Editor öffnen"] := "Open file in editor"
    EN["Konnte nicht speichern: "] := "Could not save: "
    EN["Nichts markiert."] := "Nothing selected."
    EN["Umwandlung"] := "Converter"
    EN["Eingabe hier schreiben oder einfügen:"] := "Type or paste input here:"
    EN["Von:"] := "From:"
    EN["Nach:"] := "To:"
    EN["Tibetische Schrift:"] := "Tibetan script:"
    EN["Ergebnis:"] := "Result:"
    EN["Ergebnis kopieren"] := "Copy result"
    EN["Schließen"] := "Close"
    EN["Ergebnis in der Zwischenablage."] := "Result copied to the clipboard."
    EN["Tauschen"] := "Swap"
    EN["Diese Kombination ist nicht möglich. Tibetisch geht nur mit Wylie."] := "This combination is not possible. Tibetan works only with Wylie."
    EN["Tibetisch"] := "Tibetan"
    EN["Tibetische Schrift"] := "Tibetan script"
    EN["Schichtschreibweise"] := "Layered notation"
    EN["Text bereinigen"] := "Clean up text"
    EN["Text hier einfügen:"] := "Paste text here:"
    EN["Unicode normalisieren (zusammengesetzte Zeichen, NFC: ā als ein Zeichen)"] := "Normalise Unicode (composed characters, NFC: ā as one character)"
    EN["Apostrophe vereinheitlichen (ʼ ‘ ´ ` → ’ , das Zeichen für den Avagraha)"] := "Unify apostrophes (ʼ ‘ ´ ` → ’, the avagraha sign)"
    EN["Doppelten Punkt „..“ zu einem Punkt „.“ machen"] := "Turn a double full stop `"..`" into one full stop `".`""
    EN["Überflüssige Leerzeichen entfernen (doppelte, am Zeilenende)"] := "Remove surplus spaces (double ones, at line ends)"
    EN["Unsichtbare Zeichen entfernen (Zero-Width-Space, BOM, weicher Bindestrich)"] := "Remove invisible characters (zero-width space, BOM, soft hyphen)"
    EN["Silbentrennung am Zeilenende aufheben (Trennstrich + Zeilenumbruch entfernen)"] := "Undo hyphenation at line ends (remove hyphen + line break)"
    EN["Alle Bindestriche zwischen Buchstaben entfernen (deva-datta → devadatta)"] := "Remove all hyphens between letters (deva-datta → devadatta)"
    EN["Live-Modus an: Transliteration tippen, Devanāgarī erscheint sofort."] := "Live mode on: type transliteration, Devanāgarī appears at once."
    EN["Live-Modus aus."] := "Live mode off."
    EN["Schriftart"] := "Fonts"
    EN["Schrift für Transliteration (Buchstaben mit Diakritika wie ā, ḍ, ś):"] := "Font for transliteration (letters with diacritics such as ā, ḍ, ś):"
    EN["▼ Bonus: Tibetisch einblenden"] := "▼ Bonus: Tibetan – show"
    EN["▲ Bonus: Tibetisch ausblenden"] := "▲ Bonus: Tibetan – hide"
    EN["Schrift für Devanāgarī:"] := "Font for Devanāgarī:"
    EN["Schrift für Tibetisch: Uchen (dbu can)"] := "Font for Tibetan: Uchen (dbu can)"
    EN["Schrift für Tibetisch: Ume (dbu med)"] := "Font for Tibetan: Ume (dbu med)"
    EN["Schrift für Tibetisch: Khyuyig ('khyug yig)"] := "Font for Tibetan: Khyuyig ('khyug yig)"
    EN["Größe:"] := "Size:"
    EN["Vorschau:"] := "Preview:"
    EN["Übernehmen"] := "Apply"
    EN["Standard"] := "Default"
    EN["Information"] := "About"
    EN["Version"] := "Version"
    EN["Anleitung öffnen"] := "Open guide"
    EN["Datenordner öffnen"] := "Open data folder"
    EN["Anleitung"] := "Guide"
}

; T("deutscher Text") liefert bei Lang = "en" die englische Fassung (Tabelle EN), sonst den deutschen Text
T(de) {
    if (Lang = "en" && EN.Has(de)) {
        return EN[de]
    }
    return de
}

; wie T, mit Platzhaltern {1}, {2} ...
TF(de, args*) {
    r := T(de)
    for i, a in args {
        r := StrReplace(r, "{" i "}", a)
    }
    return r
}

JoinLbl() => T("Auslautende Konsonanten mit dem nächsten Anlaut verbinden")

HkErr(what, key, msg, iniKey) {
    MsgBox(TF("Das Kürzel '{1}' ({2}) ist ungültig ({3}).`nBitte in {4} unter {5} korrigieren.", key, what, msg, IniFile, iniKey), APP, "Icon!")
}

; Anzeigename eines Umwandlungssystems
SysLabel(id) {
    if (id == "Wylie") {
        return "Wylie (" T("Tibetisch") ")"
    }
    if (id == TibId) {
        return T("Tibetische Schrift")
    }
    if (id == KsId) {
        return T("Schichtschreibweise")
    }
    return id
}

SysIndex(id) {
    for i, x in SysIds {
        if (x == id) {
            return i
        }
    }
    return 1
}

IsTibSys(id) => (id == "Wylie" || id == TibId)

; ============================================================ SCHEMA-DATEIEN
SchemePath(name) => SchemeDir "\" name ".txt"
ExtraPath(name) => ExtraDir "\" name ".txt"
; Reihenfolge nach dem Sanskrit-Alphabet (Vokale, Anusvara/Visarga, Konsonanten); Kleinbuchstabe vor Grossbuchstabe
AlphaRank(out) {
    static tbl := ""
    if (!IsObject(tbl)) {
        tbl := Map()
        tbl.CaseSense := "Off"
        groups := [["a"], ["ā", "a\u0304", "a" Chr(0x304)], ["i"], ["ī", "i\u0304", "i" Chr(0x304)], ["u"], ["ū", "u\u0304", "u" Chr(0x304)]
            , ["ṛ", "r\u0323", "r\u0325", "r" Chr(0x323), "r" Chr(0x325)]
            , ["ṝ", "ṛ\u0304", "r\u0323\u0304", "r\u0325\u0304", "r" Chr(0x325) Chr(0x304), "r" Chr(0x323) Chr(0x304)]
            , ["ḷ", "l\u0323", "l\u0325", "l" Chr(0x323), "l" Chr(0x325)]
            , ["ḹ", "ḷ\u0304", "l\u0323\u0304", "l\u0325\u0304", "l" Chr(0x325) Chr(0x304), "l" Chr(0x323) Chr(0x304)]
            , ["e"], ["ē", "e\u0304", "e" Chr(0x304)], ["o"], ["ō", "o\u0304", "o" Chr(0x304)]
            , ["ṃ", "m\u0323", "m" Chr(0x323)], ["ṁ", "m\u0307", "m" Chr(0x307)], ["m\u0310", "m" Chr(0x310)], ["ḥ", "h\u0323", "h" Chr(0x323)]
            , ["k"], ["kh"], ["g"], ["gh"], ["ṅ", "n\u0307", "n" Chr(0x307)], ["c"], ["ch"], ["j"], ["jh"], ["ñ", "n\u0303", "n" Chr(0x303)]
            , ["ṭ", "t\u0323", "t" Chr(0x323)], ["ṭh"], ["ḍ", "d\u0323", "d" Chr(0x323)], ["ḍh"], ["ṇ", "n\u0323", "n" Chr(0x323)]
            , ["t"], ["th"], ["d"], ["dh"], ["n"], ["p"], ["ph"], ["b"], ["bh"], ["m"], ["y"], ["r"], ["l"], ["v"]
            , ["ś", "s\u0301", "s" Chr(0x301)], ["ṣ", "s\u0323", "s" Chr(0x323)], ["s"], ["h"]]
        for gi, g in groups {
            for v in g {
                if (!tbl.Has(v)) {
                    tbl[v] := gi
                }
            }
        }
    }
    fc := SubStr(out, 1, 1)
    lo := StrLower(out)
    if (tbl.Has(lo)) {
        return tbl[lo] * 2 + (lo != out && StrLower(fc) != fc ? 1 : 0)
    }
    return 100000
}

; stabile Sortierung der Zeilen (Einfuegesortierung)
SortRowsAlpha(rows) {
    arr := []
    for i, r in rows {
        arr.Push({r: r, k: AlphaRank(r.out), i: i})
    }
    Loop arr.Length - 1 {
        j := A_Index + 1
        cur := arr[j]
        m := j - 1
        while (m >= 1 && (arr[m].k > cur.k || (arr[m].k = cur.k && arr[m].i > cur.i))) {
            arr[m + 1] := arr[m]
            m -= 1
        }
        arr[m + 1] := cur
    }
    res := []
    for e in arr {
        res.Push(e.r)
    }
    return res
}

EdPath() => (EdTarget = "" ? SchemePath(CurrentScheme) : ExtraPath(EdTarget))

; Zusatzkuerzel: eigene Kuerzel, die zusaetzlich zu IAST / ISO 15919 / eigenem Schema gelten
LoadExtras() {
    global ExtrasOn
    ExtrasOn := []
    DirCreate(ExtraDir)
    if (IniRead(IniFile, "General", "ExtrasInit", "") != "2") {
        MigrateExtras()
        IniWrite("2", IniFile, "General", "ExtrasInit")
    }
    for nm in StrSplit(IniRead(IniFile, "General", "Extras", ""), "|") {
        if (nm != "" && FileExist(ExtraPath(nm))) {
            ExtrasOn.Push(nm)
        }
    }
}

SaveExtras() {
    str := ""
    for nm in ExtrasOn {
        str .= (str = "" ? "" : "|") nm
    }
    try {
        IniWrite(str, IniFile, "General", "Extras")
    }
}

ExtraHeader() => "# " APP " - Zusatzkürzel (gelten zusätzlich zum gewählten Schema)`n# Format: Modifier+Taste <Tab> Ausgabe   (wie in den Schemas; Zeilen mit # sind Kommentare)`n# Beispiel (ohne # davor wirksam):`n# LAlt+c<Tab>ç`n# Nur in der Zeichenpalette (ohne Kürzel):`n# -<Tab>ă`n# Mit Kürzel, aber nicht in der Zeichenpalette: am Zeilenende <Tab>hide`n"

; Erster Start: leerer Satz "Own_shortcuts" (nur Kommentare), damit man gleich einen Platz fuer eigene Kuerzel hat
MigrateExtras() {
    path := ExtraPath("Own_shortcuts")
    if (!FileExist(path)) {
        try {
            FileAppend(ExtraHeader(), path, "UTF-8-RAW")
        }
    }
}

ToggleExtra(name, *) {
    global ExtrasOn
    idx := 0
    for i, nm in ExtrasOn {
        if (nm = name) {
            idx := i
        }
    }
    if (idx) {
        ExtrasOn.RemoveAt(idx)
    } else {
        ExtrasOn.Push(name)
    }
    SaveExtras()
    ShowErrors(ActivateScheme(CurrentScheme))
}

IsExtraOn(name) {
    for nm in ExtrasOn {
        if (nm = name) {
            return true
        }
    }
    return false
}

NewExtra(*) {
    ib := InputBox(T("Name der neuen Zusatzkürzelliste:"), APP, "w400 h140")
    if (ib.Result != "OK") {
        return
    }
    name := Trim(ib.Value)
    if (!RegExMatch(name, '^[^\\/:*?"<>|]+$')) {
        MsgBox(T("Ungültiger Name (keine Zeichen wie \ / : * ? `" < > |)."), APP, "Icon!")
        return
    }
    if (FileExist(ExtraPath(name))) {
        MsgBox(T("Eine Liste mit diesem Namen gibt es bereits."), APP, "Icon!")
        return
    }
    try {
        FileAppend(ExtraHeader(), ExtraPath(name), "UTF-8-RAW")
    }
    ToggleExtra(name)
    ShowEditor(name)
}

EnsurePresets(overwrite) {
    if (!FileExist(SchemePath("Own_scheme"))) {
        try {
            FileAppend(StrReplace(PresetIAST, "Schema: IAST", "Schema: Own_scheme") "`n", SchemePath("Own_scheme"), "UTF-8-RAW")
        }
    }
    for name, text in Presets {
        path := SchemePath(name)
        if (overwrite || !FileExist(path)) {
            try {
                if (FileExist(path)) {
                    FileDelete(path)
                }
                FileAppend(text "`n", path, "UTF-8-RAW")
            } catch as e {
                MsgBox(TF("Konnte Vorlage '{1}' nicht schreiben: {2}", name, e.Message), APP, "Icon!")
            }
        }
    }
}

; Liest Schematext -> {rows: [{mods,key,out}], header: [Kommentarzeilen vor der ersten Zeile]}
ParseScheme(text) {
    rows := []
    header := []
    for line in StrSplit(text, "`n", "`r") {
        t := Trim(line)
        if (t = "") {
            continue
        }
        if (SubStr(t, 1, 1) = "#") {
            if (rows.Length = 0) {
                header.Push(t)
            }
            continue
        }
        if (!RegExMatch(t, "^(\S+)\s+(.+)$", &m)) {
            continue
        }
        spec := m[1]
        pos := InStr(spec, "+", false, -1)
        if (pos) {
            mods := SubStr(spec, 1, pos - 1)
            key := SubStr(spec, pos + 1)
        } else {
            mods := ""
            key := spec
        }
        outv := m[2]
        pal := ""
        tp := InStr(outv, "`t")
        if (tp) {
            pal := StrLower(Trim(SubStr(outv, tp + 1)))
            outv := RTrim(SubStr(outv, 1, tp - 1))
        }
        rows.Push({mods: mods, key: key, out: outv, pal: pal})
    }
    return {rows: rows, header: header}
}

RowSpec(r) => (r.mods = "" ? r.key : r.mods "+" r.key)

; Modifier-Text + Taste -> AHK-Hotkey-Text (oder Fehler)
MakeHotkey(mods, key) {
    m := Map()
    m.CaseSense := "Off"
    m["lalt"] := "<!"
    m["ralt"] := "<^>!"
    m["altgr"] := "<^>!"
    m["alt"] := "!"
    m["lctrl"] := "<^"
    m["lstrg"] := "<^"
    m["rctrl"] := ">^"
    m["rstrg"] := ">^"
    m["ctrl"] := "^"
    m["strg"] := "^"
    m["shift"] := "+"
    m["umschalt"] := "+"
    m["win"] := "#"
    m["lwin"] := "<#"
    m["rwin"] := ">#"

    prefix := ""
    hasReal := false
    for part in StrSplit(mods, "+") {
        p := Trim(part)
        if (p = "") {
            continue
        }
        if (!m.Has(p)) {
            throw Error("Unbekannter Modifier: " p)
        }
        prefix .= m[p]
        if (m[p] != "+") {
            hasReal := true
        }
    }
    if (!hasReal) {
        throw Error("Mindestens ein Modifier außer Umschalt nötig (z.B. LAlt), sonst würde normales Tippen blockiert.")
    }
    k := Trim(key)
    if (k = "") {
        throw Error("Taste fehlt")
    }
    if (StrLen(k) = 1 && InStr("<>!^+#~*$&", k)) {
        throw Error("Diese Taste ist nicht erlaubt: " k)
    }
    if (!GetKeyVK(k) && !GetKeySC(k)) {
        throw Error("Unbekannte Taste: " k)
    }
    return prefix k
}

; \uXXXX, \u{X..}, \\, \t, \n -> echte Zeichen
Unescape(s) {
    out := ""
    i := 1
    n := StrLen(s)
    while (i <= n) {
        c := SubStr(s, i, 1)
        if (c != "\") {
            out .= c
            i += 1
            continue
        }
        nx := SubStr(s, i + 1, 1)
        if (nx = "u") {
            if (SubStr(s, i + 2, 1) = "{") {
                close := InStr(s, "}", false, i + 3)
                if (!close) {
                    throw Error("Fehlende } in \u{...}")
                }
                hex := SubStr(s, i + 3, close - i - 3)
                i := close + 1
            } else {
                hex := SubStr(s, i + 2, 4)
                i += 6
            }
            if (!RegExMatch(hex, "^[0-9A-Fa-f]{1,6}$")) {
                throw Error("Ungültiger \u-Code: " hex)
            }
            out .= Chr(Integer("0x" hex))
        } else if (nx = "\") {
            out .= "\"
            i += 2
        } else if (nx = "t") {
            out .= "`t"
            i += 2
        } else if (nx = "n") {
            out .= "`n"
            i += 2
        } else {
            out .= c
            i += 1
        }
    }
    return out
}

; ======================================================== AKTIVIEREN / PAUSE
; Laedt Schema, registriert Hotkeys (wenn nicht pausiert); gibt Fehlertext zurueck
ActivateScheme(name) {
    global CurrentScheme, Rows
    UnregisterAll()
    PalClose()
    PalChars.Length := 0
    CurrentScheme := name
    errs := ""
    Rows := []
    seen := Map()
    seen.CaseSense := "Off"
    try {
        parsed := ParseScheme(FileRead(SchemePath(name), "UTF-8"))
    } catch as e {
        BuildTray()
        return "Schema '" name "' nicht lesbar: " e.Message "`n"
    }
    allrows := []
    for nm in ExtrasOn {
        try {
            for r in ParseScheme(FileRead(ExtraPath(nm), "UTF-8")).rows {
                r.DefineProp("src", {value: "x" nm})
                allrows.Push(r)
            }
        } catch as e {
            errs .= TF("Zusatzkürzel '{1}' nicht lesbar: {2}", nm, e.Message) "`n"
        }
    }
    for r in parsed.rows {
        r.DefineProp("src", {value: "scheme"})
        allrows.Push(r)
    }
    for r in allrows {
        palOnly := (r.mods = "" && r.key = "-")
        try {
            hk := (palOnly ? "" : MakeHotkey(r.mods, r.key))
            out := Unescape(r.out)
        } catch as e {
            errs .= RowSpec(r) ": " e.Message "`n"
            continue
        }
        if (SubStr(r.src, 1, 1) = "x" && r.pal != "hide") {
            PalChars.Push({out: out, tip: (palOnly ? "" : RowSpec(r))})
        }
        if (palOnly) {
            continue
        }
        if (seen.Has(hk)) {
            ; gleiche Taste in Zusatzkuerzel und Schema (oder zwei Saetzen): der Zusatzsatz gilt, kein Hinweis noetig
            if (seen[hk] = r.src) {
                errs .= RowSpec(r) ": doppelt (die erste Zeile gilt)`n"
            }
            continue
        }
        seen[hk] := r.src
        Rows.Push({hk: hk, out: out})
    }
    if (!Paused) {
        errs .= RegisterAll()
    }
    try {
        IniWrite(name, IniFile, "General", "Scheme")
    }
    BuildTray()
    return errs
}

RegisterAll() {
    global Active
    errs := ""
    for r in Rows {
        try {
            Hotkey(r.hk, SendOut.Bind(r.out), "On")
            Active[r.hk] := true
        } catch as e {
            errs .= r.hk ": " e.Message "`n"
        }
    }
    if (LiveOn) {
        errs .= LiveRegister()
    }
    return errs
}

UnregisterAll() {
    global Active
    for hk, v in Active {
        try {
            Hotkey(hk, "Off")
        }
    }
    Active := Map()
    LiveUnregister()
}

SendOut(out, *) {
    if (LiveOn && !Paused) {
        LiveKeyIn(out)
        return
    }
    SendText(out)
}

TogglePause(*) {
    global Paused
    Paused := !Paused
    if (Paused) {
        UnregisterAll()
    } else {
        ShowErrors(RegisterAll())
    }
    BuildTray()
    TrayTip((Paused ? T("Pausiert - normale Tastatur") : T("Aktiv: ") CurrentScheme), APP)
}

ShowErrors(errs) {
    if (errs = "") {
        return
    }
    lines := StrSplit(Trim(errs, "`n"), "`n")
    shown := ""
    for i, l in lines {
        if (i > 15) {
            shown .= TF("... und {1} weitere`n", lines.Length - 15)
            break
        }
        shown .= l "`n"
    }
    MsgBox(T("Diese Zeilen wurden übersprungen:`n`n") shown, APP, "Icon!")
}

; ============================================================== TRAY-MENUE
BuildTray() {
    A_TrayMenu.Delete()
    extra := LiveOn ? T(" + Live-Modus") : ""
    status := Paused ? T("Pausiert (normale Tastatur)") : T("Aktiv: ") CurrentScheme extra
    A_IconTip := APP " " AppVersion " – " status
    verLine := APP " " AppVersion " – Sanskrit transliteration tool for Windows"
    A_TrayMenu.Add(verLine, (*) => ShowInfo())
    A_TrayMenu.Add(status, (*) => 0)
    A_TrayMenu.Disable(status)
    lsub := Menu()
    for lp in HelpLangs {
        lsub.Add(lp[2], SetLang.Bind(lp[1]))
        if (lp[1] = Lang) {
            lsub.Check(lp[2])
        }
    }
    A_TrayMenu.Add("Sprache / Language", lsub)
    A_TrayMenu.Add()
    A_TrayMenu.Add(T("Pausieren / Fortsetzen"), TogglePause)

    sub := Menu()
    sub.Add("IAST", SelectScheme.Bind("IAST"))
    sub.Add("ISO 15919", SelectScheme.Bind("ISO 15919"))
    others := 0
    Loop Files SchemeDir "\*.txt" {
        nm := RegExReplace(A_LoopFileName, "\.txt$")
        if (nm = "IAST" || nm = "ISO 15919") {
            continue
        }
        if (others = 0) {
            sub.Add()
        }
        others += 1
        sub.Add(nm, SelectScheme.Bind(nm))
        if (nm = CurrentScheme) {
            sub.Check(nm)
        }
    }
    try {
        sub.Check(CurrentScheme)
    }
    A_TrayMenu.Add(T("Schema wählen"), sub)
    xsub := Menu()
    xn := 0
    Loop Files ExtraDir "\*.txt" {
        nm := RegExReplace(A_LoopFileName, "\.txt$")
        xsub.Add(nm, ToggleExtra.Bind(nm))
        if (IsExtraOn(nm)) {
            xsub.Check(nm)
        }
        xn += 1
    }
    if (xn > 0) {
        xsub.Add()
    }
    xsub.Add(T("Zusatzkürzel bearbeiten..."), ShowExtraEditorMenu)
    xsub.Add(T("Neue Zusatzkürzelliste..."), NewExtra)
    xsub.Add(T("Zusatzkürzel-Ordner öffnen"), (*) => Run('explorer.exe "' ExtraDir '"'))
    A_TrayMenu.Add(T("Zusatzkürzel (gelten zusätzlich zum Schema)"), xsub)
    A_TrayMenu.Add(T("Kürzel bearbeiten..."), (*) => ShowEditor())
    A_TrayMenu.Add(T("Schema neu laden (nach Änderung im Texteditor)"), ReloadScheme)
    A_TrayMenu.Add(T("Neues Schema (Kopie des aktuellen)..."), NewScheme)
    A_TrayMenu.Add(T("Schema-Ordner öffnen"), (*) => Run('explorer.exe "' SchemeDir '"'))
    A_TrayMenu.Add(T("Mitgelieferte Vorlagen wiederherstellen"), RestorePresets)
    A_TrayMenu.Add()
    A_TrayMenu.Add(T("Umwandlung (Fenster): Transliteration, Devanāgarī, Tibetisch..."), ShowConverter)
    A_TrayMenu.Add(T("Text bereinigen (Fenster)..."), ShowCleaner)
    A_TrayMenu.Add(T("Markierten Text bereinigen (Strg+Alt+Umschalt+B)"), (*) => CleanSelection())
    dsub := Menu()
    for dp in LatSchemes {
        dsub.Add(SysLabel(dp), SetDevaProfile.Bind(dp))
        if (dp = DevaProfile) {
            dsub.Check(SysLabel(dp))
        }
    }
    A_TrayMenu.Add(T("Transliterationssystem für Strg+Alt+Umschalt+D/I"), dsub)
    osub := Menu()
    osub.Add(T("Punkt (.) = Daṇḍa"), ToggleOpt.Bind("dot"))
    osub.Add(JoinLbl(), ToggleOpt.Bind("join"))
    if (DandaDot) {
        osub.Check(T("Punkt (.) = Daṇḍa"))
    }
    if (JoinWords) {
        osub.Check(JoinLbl())
    }
    A_TrayMenu.Add(T("Umwandlung: Optionen"), osub)
    A_TrayMenu.Add(T("Zeichenpalette (Strg+Alt+Umschalt+P)"), TogglePalette)
    A_TrayMenu.Add(T("Live-Modus: Transliteration tippen, Devanāgarī erscheint (Strg+Alt+Umschalt+L)"), LiveToggle)
    if (LiveOn) {
        A_TrayMenu.Check(T("Live-Modus: Transliteration tippen, Devanāgarī erscheint (Strg+Alt+Umschalt+L)"))
    }
    A_TrayMenu.Add(T("Schriftart..."), ShowFontDlg)
    xfsub := Menu()
    xfsub.Add(T("Exportieren..."), (*) => XfShow("export"))
    xfsub.Add(T("Importieren..."), (*) => XfShow("import"))
    A_TrayMenu.Add(T("Export / Import"), xfsub)
    A_TrayMenu.Add()
    A_TrayMenu.Add(T("Mit Windows starten"), ToggleAutostart)
    if (FileExist(StartupLink())) {
        A_TrayMenu.Check(T("Mit Windows starten"))
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add(T("Anleitung..."), (*) => ShowHelp(false))
    A_TrayMenu.Add(T("Information..."), (*) => ShowInfo())
    A_TrayMenu.Add(T("Beenden"), (*) => ExitApp())
    A_TrayMenu.Default := T("Kürzel bearbeiten...")
}

SetLang(code, *) {
    global Lang
    Lang := code
    SaveLang()
    ; offene Fenster schliessen, damit sie beim naechsten Oeffnen in der neuen Sprache erscheinen
    CvClose()
    ClClose()
    EdClose()
    FcClose()
    HelpClose()
    InfoClose()
    BuildTray()
    TrayTip(T("Sprache: Deutsch"), APP)
}

SelectScheme(name, *) {
    EdClose()
    ShowErrors(ActivateScheme(name))
}

ReloadScheme(*) {
    EdClose()
    ShowErrors(ActivateScheme(CurrentScheme))
}

NewScheme(*) {
    ib := InputBox(T("Name des neuen Schemas (es wird als Kopie des aktuellen angelegt):"), APP, "w400 h140")
    if (ib.Result != "OK") {
        return
    }
    name := Trim(ib.Value)
    if (!RegExMatch(name, '^[^\\/:*?"<>|]+$')) {
        MsgBox(T("Ungültiger Name (keine Zeichen wie \ / : * ? `" < > |)."), APP, "Icon!")
        return
    }
    if (FileExist(SchemePath(name))) {
        MsgBox(T("Ein Schema mit diesem Namen gibt es schon."), APP, "Icon!")
        return
    }
    EdClose()
    FileCopy(SchemePath(CurrentScheme), SchemePath(name))
    ShowErrors(ActivateScheme(name))
    ShowEditor()
}

RestorePresets(*) {
    if (MsgBox(T("Die Schemas IAST und ISO 15919 werden auf den Auslieferungszustand zurückgesetzt.`nEigene Änderungen daran gehen verloren (selbst angelegte Schemas und Zusatzkürzel bleiben).`n`nFortfahren?"), APP, "YesNo Icon?") != "Yes") {
        return
    }
    EdClose()
    EnsurePresets(true)
    ShowErrors(ActivateScheme(CurrentScheme))
}

; ============================================================== AUTOSTART
StartupLink() => A_Startup "\" APP ".lnk"

ToggleAutostart(*) {
    SetAutostart(FileExist(StartupLink()) ? false : true)
    BuildTray()
}

SetAutostart(on) {
    link := StartupLink()
    try {
        if (on) {
            if (A_IsCompiled) {
                FileCreateShortcut(A_ScriptFullPath, link, A_ScriptDir)
            } else {
                FileCreateShortcut(A_AhkPath, link, A_ScriptDir, '"' A_ScriptFullPath '"')
            }
        } else if (FileExist(link)) {
            FileDelete(link)
        }
    } catch as e {
        MsgBox(T("Autostart konnte nicht geändert werden: ") e.Message, APP, "Icon!")
    }
}

; ================================================================ EXPORT / IMPORT
; --- kleines JSON (nur was hier gebraucht wird) ---
JStr(sv) {
    sv := StrReplace(sv, "\", "\\")
    sv := StrReplace(sv, '"', '\"')
    sv := StrReplace(sv, "`n", "\n")
    sv := StrReplace(sv, "`r", "\r")
    sv := StrReplace(sv, "`t", "\t")
    while (RegExMatch(sv, "[\x00-\x1F]", &mc)) {
        sv := StrReplace(sv, mc[0], Format("\u{:04x}", Ord(mc[0])))
    }
    return '"' sv '"'
}

JParse(txt) {
    ps := 1
    v := JVal(txt, &ps)
    JWs(txt, &ps)
    if (ps <= StrLen(txt)) {
        throw Error("Unerwartete Zeichen am Ende")
    }
    return v
}

JWs(txt, &ps) {
    while (ps <= StrLen(txt) && InStr(" `t`r`n", SubStr(txt, ps, 1))) {
        ps += 1
    }
}

JVal(txt, &ps) {
    JWs(txt, &ps)
    ch := SubStr(txt, ps, 1)
    if (ch = "{") {
        ps += 1
        mp := Map()
        JWs(txt, &ps)
        if (SubStr(txt, ps, 1) = "}") {
            ps += 1
            return mp
        }
        loop {
            JWs(txt, &ps)
            if (SubStr(txt, ps, 1) != '"') {
                throw Error("Schlüssel erwartet bei Position " ps)
            }
            k := JStrP(txt, &ps)
            JWs(txt, &ps)
            if (SubStr(txt, ps, 1) != ":") {
                throw Error(": erwartet bei Position " ps)
            }
            ps += 1
            mp[k] := JVal(txt, &ps)
            JWs(txt, &ps)
            nx := SubStr(txt, ps, 1)
            ps += 1
            if (nx = ",") {
                continue
            }
            if (nx = "}") {
                break
            }
            throw Error(", oder } erwartet bei Position " (ps - 1))
        }
        return mp
    }
    if (ch = "[") {
        ps += 1
        ar := []
        JWs(txt, &ps)
        if (SubStr(txt, ps, 1) = "]") {
            ps += 1
            return ar
        }
        loop {
            ar.Push(JVal(txt, &ps))
            JWs(txt, &ps)
            nx := SubStr(txt, ps, 1)
            ps += 1
            if (nx = ",") {
                continue
            }
            if (nx = "]") {
                break
            }
            throw Error(", oder ] erwartet bei Position " (ps - 1))
        }
        return ar
    }
    if (ch = '"') {
        return JStrP(txt, &ps)
    }
    if (RegExMatch(txt, "A)-?\d+(\.\d+)?([eE][+-]?\d+)?", &mn, ps)) {
        ps += StrLen(mn[0])
        return mn[0]
    }
    for lit in ["true", "false", "null"] {
        if (SubStr(txt, ps, StrLen(lit)) = lit) {
            ps += StrLen(lit)
            return lit
        }
    }
    throw Error("Ungültiges JSON bei Position " ps)
}

JStrP(txt, &ps) {
    ps += 1
    out := ""
    loop {
        if (ps > StrLen(txt)) {
            throw Error("Zeichenkette nicht beendet")
        }
        if (RegExMatch(txt, 'A)[^"\\]+', &mc, ps)) {
            out .= mc[0]
            ps += StrLen(mc[0])
            continue
        }
        ch := SubStr(txt, ps, 1)
        if (ch = '"') {
            ps += 1
            return out
        }
        nx := SubStr(txt, ps + 1, 1)
        if (nx = "u") {
            hx := SubStr(txt, ps + 2, 4)
            if (!RegExMatch(hx, "^[0-9A-Fa-f]{4}$")) {
                throw Error("Ungültiger \u-Code bei Position " ps)
            }
            out .= Chr(Integer("0x" hx))
            ps += 6
            continue
        }
        if (nx = "n") {
            out .= "`n"
        } else if (nx = "r") {
            out .= "`r"
        } else if (nx = "t") {
            out .= "`t"
        } else if (nx = "b") {
            out .= Chr(8)
        } else if (nx = "f") {
            out .= Chr(12)
        } else if (nx = '"' || nx = "\" || nx = "/") {
            out .= nx
        } else {
            throw Error("Ungültige Escape-Folge bei Position " ps)
        }
        ps += 2
    }
}

; --- Inhalte ---
XfGroups() {
    clean := []
    for k in ["nfc", "quotes", "dots", "spaces", "invis", "hyeol", "hyall"] {
        clean.Push("Clean." k)
    }
    return [
        {id: "lang", lbl: T("Sprache"), keys: ["General.Lang"]},
        {id: "conv", lbl: T("Umwandlung: Optionen"), keys: ["General.DandaDot", "General.JoinWords", "General.DevaProfile"]},
        {id: "clean", lbl: T("Bereinigen: Optionen"), keys: clean},
        {id: "keys", lbl: T("Tastenkürzel der App (Umwandlung, Live-Modus, Bereinigen, Zeichenpalette, Pause)"), keys: ["General.PauseKey", "General.DevaKey", "General.LatinKey", "General.LiveKey", "General.CleanKey", "General.PalKey"]},
        {id: "fonts", lbl: T("Schriften und Größen (auf anderen Geräten evtl. nicht installiert)"), keys: ["General.LatinFont", "General.DevaFont", "General.FontSize", "General.DevaSize", "General.TibFont1", "General.TibFont2", "General.TibFont3", "General.TibSize1", "General.TibSize2", "General.TibSize3"]},
        {id: "active", lbl: T("Aktive Auswahl (Schema, eingeschaltete Zusatzkürzellisten)"), keys: ["General.Scheme", "General.Extras"]}
    ]
}

XfNorm(txt) => Trim(StrReplace(txt, "`r"), " `t`n")

XfSafeName(nm) {
    if (!(nm is String) || StrLen(nm) < 1 || StrLen(nm) > 80) {
        return false
    }
    if (!RegExMatch(nm, '^[^\\/:*?"<>|\x00-\x1F]+$') || SubStr(nm, 1, 1) = "." || SubStr(nm, -1) = "." || SubStr(nm, -1) = " ") {
        return false
    }
    if (RegExMatch(nm, "i)^(con|prn|aux|nul|com\d|lpt\d)$")) {
        return false
    }
    return true
}

XfSafeValue(key, v) {
    if (!(v is String) || StrLen(v) > 200 || RegExMatch(v, "[\r\n\x00]")) {
        return false
    }
    if (key = "General.Lang") {
        return (v = "de" || v = "en")
    }
    if (RegExMatch(key, "^(Clean\.|General\.(DandaDot|JoinWords))")) {
        return (v = "0" || v = "1")
    }
    if (RegExMatch(key, "^General\.(FontSize|DevaSize|TibSize\d)$")) {
        return RegExMatch(v, "^\d{1,2}$") ? true : false
    }
    if (key = "General.Scheme") {
        return XfSafeName(v)
    }
    if (key = "General.Extras") {
        for nm in StrSplit(v, "|") {
            if (nm != "" && !XfSafeName(nm)) {
                return false
            }
        }
    }
    return true
}

XfShow(mode, *) {
    global XfGui, XfLV, XfItems, XfMode
    if (IsObject(XfGui)) {
        XfGui.Destroy()
        XfGui := ""
    }
    XfMode := mode
    XfItems := []
    if (mode = "export") {
        XfBuildExport()
        if (XfItems.Length = 0) {
            MsgBox(T("Es gibt nichts zu exportieren."), APP, "Icon!")
            return
        }
    } else {
        if (!XfBuildImport()) {
            return
        }
    }
    XfGui := Gui(, APP " – " (mode = "export" ? T("Exportieren") : T("Importieren")))
    XfGui.SetFont("s10", FontFam(LatinFont))
    XfGui.Add("Text", "w600", mode = "export" ? T("Hake an, was exportiert werden soll:") : T("Hake an, was importiert werden soll:"))
    XfLV := XfGui.Add("ListView", "r14 w600 Checked -Multi", [T("Inhalt"), T("Art")])
    for it in XfItems {
        XfLV.Add(it.chk ? "Check" : "", it.label, it.art)
    }
    XfLV.ModifyCol(1, 440)
    XfLV.ModifyCol(2, 140)
    XfGui.Add("Button", "xm w90", T("Alle")).OnEvent("Click", (*) => XfAll(true))
    XfGui.Add("Button", "x+5 w90", T("Keine")).OnEvent("Click", (*) => XfAll(false))
    XfGui.Add("Button", "x+60 w130 Default", mode = "export" ? T("Exportieren") : T("Importieren")).OnEvent("Click", XfGo)
    XfGui.Add("Button", "x+5 w110", T("Abbrechen")).OnEvent("Click", XfClose)
    XfGui.OnEvent("Close", XfClose)
    XfGui.OnEvent("Escape", XfClose)
    XfGui.Show()
}

XfClose(*) {
    global XfGui
    if (IsObject(XfGui)) {
        XfGui.Destroy()
    }
    XfGui := ""
}

XfAll(on) {
    Loop XfItems.Length {
        XfLV.Modify(A_Index, on ? "Check" : "-Check")
    }
}

XfChecked() {
    sel := []
    row := 0
    while (row := XfLV.GetNext(row, "Checked")) {
        sel.Push(row)
    }
    return sel
}

XfBuildExport() {
    Loop Files SchemeDir "\*.txt" {
        nm := RegExReplace(A_LoopFileName, "\.txt$")
        if (Presets.Has(nm)) {
            try {
                if (XfNorm(FileRead(A_LoopFileFullPath, "UTF-8")) = XfNorm(Presets[nm])) {
                    continue
                }
            }
        }
        XfItems.Push({kind: "scheme", name: nm, label: nm, art: T("Schema"), chk: (nm = "Own_scheme")})
    }
    Loop Files ExtraDir "\*.txt" {
        nm := RegExReplace(A_LoopFileName, "\.txt$")
        XfItems.Push({kind: "extra", name: nm, label: nm, art: T("Zusatzkürzelliste"), chk: (nm = "Own_shortcuts")})
    }
    for g in XfGroups() {
        XfItems.Push({kind: "group", id: g.id, keys: g.keys, label: g.lbl, art: T("Einstellungen"), chk: false})
    }
}

; Liest die Importdatei und fuellt XfItems; false bei Abbruch/Fehler
XfBuildImport(f := "") {
    global XfBad
    if (f = "") {
        f := FileSelect(1, A_Desktop, APP " – " T("Importieren"), "JSON (*.json)")
    }
    if (f = "") {
        return false
    }
    try {
        if (FileGetSize(f) > 5000000) {
            throw Error("Datei zu groß")
        }
        data := JParse(FileRead(f, "UTF-8"))
    } catch as e {
        MsgBox(T("Datei nicht lesbar: ") e.Message, APP, "Icon!")
        return false
    }
    if (!(data is Map) || !data.Has("format") || data["format"] != "SansTrans-Export") {
        MsgBox(T("Das ist keine SansTrans-Exportdatei."), APP, "Icon!")
        return false
    }
    bad := 0
    for kind, sect in Map("scheme", "schemes", "extra", "extras") {
        if (!data.Has(sect) || !(data[sect] is Map)) {
            continue
        }
        for nm, txt in data[sect] {
            if (!XfSafeName(nm) || !(txt is String) || txt = "" || StrLen(txt) > 500000) {
                bad += 1
                continue
            }
            XfItems.Push({kind: kind, name: nm, text: txt, label: nm, art: (kind = "scheme" ? T("Schema") : T("Zusatzkürzelliste")), chk: true})
        }
    }
    if (data.Has("settings") && data["settings"] is Map) {
        st := data["settings"]
        for g in XfGroups() {
            vals := Map()
            for k in g.keys {
                if (st.Has(k)) {
                    if (XfSafeValue(k, st[k])) {
                        vals[k] := st[k]
                    } else {
                        bad += 1
                    }
                }
            }
            if (vals.Count > 0) {
                XfItems.Push({kind: "group", id: g.id, keys: g.keys, vals: vals, label: g.lbl, art: T("Einstellungen"), chk: (g.id != "fonts")})
            }
        }
    }
    XfBad := bad
    if (XfItems.Length = 0) {
        MsgBox(T("Die Datei enthält nichts Importierbares."), APP, "Icon!")
        return false
    }
    return true
}

XfGo(*) {
    sel := XfChecked()
    if (sel.Length = 0) {
        MsgBox(T("Nichts angehakt."), APP, "Icon!")
        return
    }
    if (XfMode = "export") {
        XfDoExport(sel)
    } else {
        XfDoImport(sel)
    }
}

XfBuildJson(sel, &n) {
    sch := ""
    ext := ""
    st := ""
    n := 0
    for i in sel {
        it := XfItems[i]
        if (it.kind = "scheme" || it.kind = "extra") {
            try {
                body := FileRead((it.kind = "scheme" ? SchemePath(it.name) : ExtraPath(it.name)), "UTF-8")
            } catch {
                continue
            }
            entry := "    " JStr(it.name) ": " JStr(body)
            if (it.kind = "scheme") {
                sch .= (sch = "" ? "" : ",`n") entry
            } else {
                ext .= (ext = "" ? "" : ",`n") entry
            }
            n += 1
        } else {
            for k in it.keys {
                parts := StrSplit(k, ".")
                v := IniRead(IniFile, parts[1], parts[2], "`a")
                if (v != "`a") {
                    st .= (st = "" ? "" : ",`n") "    " JStr(k) ": " JStr(v)
                }
            }
            n += 1
        }
    }
    out := "{`n  " JStr("format") ": " JStr("SansTrans-Export") ",`n  " JStr("version") ": 1,`n  " JStr("app") ": " JStr(APP " " AppVersion) ",`n"
    out .= "  " JStr("schemes") ": {`n" sch "`n  },`n  " JStr("extras") ": {`n" ext "`n  },`n  " JStr("settings") ": {`n" st "`n  }`n}`n"
    return out
}

XfDoExport(sel) {
    f := FileSelect("S16", A_Desktop "\SansTrans_Export.json", APP " – " T("Exportieren"), "JSON (*.json)")
    if (f = "") {
        return
    }
    if (!RegExMatch(f, "i)\.json$")) {
        f .= ".json"
    }
    out := XfBuildJson(sel, &n)
    try {
        fh := FileOpen(f, "w", "UTF-8-RAW")
        fh.Write(out)
        fh.Close()
    } catch as e {
        MsgBox(T("Konnte nicht schreiben: ") e.Message, APP, "Icon!")
        return
    }
    XfClose()
    MsgBox(TF("Exportiert: {1} Einträge nach {2}", n, f), APP, "Iconi")
}

XfFreeName(dir, nm) {
    n := 2
    while (FileExist(dir "\" nm " (" n ").txt")) {
        n += 1
    }
    return nm " (" n ")"
}

XfPick(g, cb, res, c) {
    res.c := c
    res.all := cb.Value
    g.Destroy()
}

XfAsk(nm) {
    res := {c: "", all: false}
    g := Gui("+AlwaysOnTop" (IsObject(XfGui) ? " +Owner" XfGui.Hwnd : ""), APP)
    g.SetFont("s10", FontFam(LatinFont))
    g.Add("Text", "w420", TF("'{1}' gibt es schon. Was soll geschehen?", nm))
    cb := g.Add("Checkbox", "xm", T("Für alle weiteren gleich entscheiden"))
    g.Add("Button", "xm w130", T("Überschreiben")).OnEvent("Click", (*) => XfPick(g, cb, res, "over"))
    g.Add("Button", "x+5 w130", T("Neuer Name")).OnEvent("Click", (*) => XfPick(g, cb, res, "rename"))
    g.Add("Button", "x+5 w130", T("Überspringen")).OnEvent("Click", (*) => XfPick(g, cb, res, "skip"))
    g.OnEvent("Close", (*) => XfPick(g, cb, res, "skip"))
    g.OnEvent("Escape", (*) => XfPick(g, cb, res, "skip"))
    g.Show()
    while (res.c = "") {
        Sleep(50)
    }
    return res
}

XfDoImport(sel) {
    pol := ""
    ren := Map()
    n := 0
    for i in sel {
        it := XfItems[i]
        if (it.kind != "scheme" && it.kind != "extra") {
            continue
        }
        dir := (it.kind = "scheme" ? SchemeDir : ExtraDir)
        nm := it.name
        if (FileExist(dir "\" nm ".txt")) {
            c := pol
            if (c = "") {
                r := XfAsk(nm)
                c := r.c
                if (r.all) {
                    pol := c
                }
            }
            if (c = "skip") {
                continue
            }
            if (c = "rename") {
                nm := XfFreeName(dir, nm)
            }
        }
        path := dir "\" nm ".txt"
        try {
            DirCreate(dir)
            if (FileExist(path)) {
                FileDelete(path)
            }
            FileAppend(StrReplace(StrReplace(it.text, "`r`n", "`n"), "`n", "`r`n"), path, "UTF-8-RAW")
            ren[it.kind "|" it.name] := nm
            n += 1
        } catch as e {
            MsgBox(T("Konnte nicht schreiben: ") e.Message, APP, "Icon!")
        }
    }
    for i in sel {
        it := XfItems[i]
        if (it.kind != "group") {
            continue
        }
        for k, v in it.vals {
            parts := StrSplit(k, ".")
            if (k = "General.Scheme") {
                v := ren.Has("scheme|" v) ? ren["scheme|" v] : v
                if (!FileExist(SchemePath(v))) {
                    continue
                }
            } else if (k = "General.Extras") {
                lst := ""
                for xe in StrSplit(v, "|") {
                    xe := ren.Has("extra|" xe) ? ren["extra|" xe] : xe
                    if (xe != "" && FileExist(ExtraPath(xe))) {
                        lst .= (lst = "" ? "" : "|") xe
                    }
                }
                v := lst
            }
            try {
                IniWrite(v, IniFile, parts[1], parts[2])
            }
        }
        n += 1
    }
    XfClose()
    extra := (XfBad > 0 ? TF("`n{1} ungültige Einträge wurden übersprungen.", XfBad) : "")
    MsgBox(TF("Importiert: {1} Einträge.{2}`nSansTrans startet jetzt neu, um alles zu laden.", n, extra), APP, "Iconi")
    if (!XfNoReload) {
        Reload()
    }
}

; ================================================================ ZEICHENPALETTE
PalLbl() => T("Zeichenpalette")

TogglePalette(*) {
    if (IsObject(PalGui)) {
        PalClose()
    } else {
        ShowPalette()
    }
}

PalClose(*) {
    global PalGui, PalBtn
    if (IsObject(PalGui)) {
        try {
            PalGui.Destroy()
        }
    }
    PalGui := ""
    PalBtn := Map()
}

; Kleines Fenster, das den Fokus nicht nimmt (WS_EX_NOACTIVATE): ein Klick fuegt das Zeichen im Zielprogramm ein
ShowPalette() {
    global PalGui, PalBtn, PalStatus
    if (PalChars.Length = 0) {
        MsgBox(T("Die Zeichenpalette ist leer. Schalten Sie unter 'Zusatzkürzel' eine Liste mit Zeichen ein oder legen Sie Zeichen im Zusatzkürzel-Editor an."), APP, "Icon!")
        return
    }
    per := 10
    bw := 46
    bh := 40
    PalGui := Gui("+AlwaysOnTop +ToolWindow +E0x08000000", APP " – " PalLbl())
    PalBtn := Map()
    for i, c in PalChars {
        if (RegExMatch(c.out, "^[\x{0900}-\x{097F}]")) {
            PalGui.SetFont("s" (DevaSize + 3), FontFam(DevaFont))
        } else {
            PalGui.SetFont("s" (FontSize + 3), FontFam(LatinFont))
        }
        if (i = 1) {
            opt := "xm"
        } else if (Mod(i - 1, per) = 0) {
            opt := "xm y+4"
        } else {
            opt := "x+4 yp"
        }
        b := PalGui.Add("Button", opt " w" bw " h" bh, c.out)
        b.OnEvent("Click", PalSend.Bind(c.out))
        PalBtn[b.Hwnd] := c
    }
    PalGui.SetFont("s9", FontFam(LatinFont))
    wTot := Min(PalChars.Length, per) * (bw + 4) - 4
    PalStatus := PalGui.Add("Text", "xm y+8 w" wTot, PalHint())
    cb := PalGui.Add("Checkbox", "xm y+4", T("offen lassen"))
    cb.Value := PalKeep ? 1 : 0
    cb.OnEvent("Click", PalKeepClick)
    PalGui.OnEvent("Close", PalClose)
    PalGui.Show("Hide AutoSize")
    PalGui.GetPos(, , &w, &h)
    MonitorGetWorkArea(, &l, &t0, &r, &b)
    PalGui.Show("NoActivate x" (r - w - 20) " y" (b - h - 20))
}

PalHint() => T("Klick = Zeichen einfügen")

PalKeepClick(ctrl, *) {
    global PalKeep
    PalKeep := (ctrl.Value = 1)
    try {
        IniWrite(PalKeep ? "1" : "0", IniFile, "General", "PalKeep")
    }
}

PalSend(out, *) {
    SendOut(out)
    if (!PalKeep) {
        PalClose()
    }
}

; Mauszeiger ueber einer Schaltflaeche: Zeichen, Unicode-Code und Kuerzel in der Statuszeile
PalMove(wParam, lParam, msg, hwnd) {
    if (!IsObject(PalGui) || !IsObject(PalStatus)) {
        return
    }
    if (PalBtn.Has(hwnd)) {
        c := PalBtn[hwnd]
        codes := ""
        for ch in StrSplit(c.out) {
            codes .= (codes = "" ? "" : " ") "U+" Format("{:04X}", Ord(ch))
        }
        txt := codes "   " (c.tip = "" ? T("kein Kürzel") : c.tip)
    } else {
        txt := PalHint()
    }
    try {
        if (PalStatus.Text != txt) {
            PalStatus.Text := txt
        }
    }
}

; ================================================================ EDITOR
ShowExtraEditorMenu(*) {
    ; offene Saetze zur Auswahl: einer eingeschaltet -> dieser, sonst der erste
    first := ""
    Loop Files ExtraDir "\*.txt" {
        nm := RegExReplace(A_LoopFileName, "\.txt$")
        if (first = "") {
            first := nm
        }
        if (IsExtraOn(nm)) {
            ShowEditor(nm)
            return
        }
    }
    if (first = "") {
        NewExtra()
    } else {
        ShowEditor(first)
    }
}

ShowEditor(target := "", *) {
    global EdGui, EdRows, EdHeader, LV, CB, EdKey, EdOut, EdTarget, PalCB
    if (!(target is String)) {
        target := ""
    }
    if (IsObject(EdGui)) {
        EdGui.Destroy()
        EdGui := ""
    }
    EdTarget := target
    try {
        parsed := ParseScheme(FileRead(EdPath(), "UTF-8"))
    } catch as e {
        MsgBox(T("Schema nicht lesbar: ") e.Message, APP, "Icon!")
        return
    }
    EdRows := (EdTarget = "" ? SortRowsAlpha(parsed.rows) : parsed.rows)
    EdHeader := parsed.header

    EdGui := Gui(, APP " – " T("Kürzel bearbeiten: ") (EdTarget = "" ? CurrentScheme : T("Zusatzkürzel") " " EdTarget))
    EdGui.SetFont("s10", FontFam(LatinFont))
    cols := ["Modifier", T("Taste"), T("Ausgabe")]
    if (EdTarget != "") {
        cols.Push(PalLbl())
    }
    LV := EdGui.Add("ListView", "r14 w600 Grid -Multi", cols)
    LV.OnEvent("ItemSelect", EdSelect)

    EdGui.Add("Text", "xm w170", "Modifier")
    EdGui.Add("Text", "x+10 w110", T("Taste"))
    EdGui.Add("Text", "x+10 w200", T("Ausgabe"))
    CB := EdGui.Add("ComboBox", "xm w170", ["LAlt", "LAlt+Shift", "AltGr", "AltGr+Shift", "Ctrl+Alt", "Ctrl+Alt+Shift", "Ctrl", "Ctrl+Shift", "Win", "Win+Shift"])
    CB.Text := "LAlt"
    EdKey := EdGui.Add("Edit", "x+10 w110")
    EdOut := EdGui.Add("Edit", "x+10 w200")
    EdGui.Add("Button", "x+10 w90", T("Setzen")).OnEvent("Click", EdAddUpdate)
    EdGui.Add("Button", "x+5 w80", T("Löschen")).OnEvent("Click", EdDelete)
    PalCB := ""
    if (EdTarget != "") {
        PalCB := EdGui.Add("Checkbox", "xm Checked", T("In der Zeichenpalette anzeigen"))
        PalCB.OnEvent("Click", EdPalToggle)
    }
    EdGui.Add("Text", "xm w600", T("Taste: a, 5, F5, Numpad1, SC028 (= Tastenposition) ...   Ausgabe: Zeichen oder ̥ (Unicode-Code).`n")
        . T("'Setzen' fügt hinzu oder überschreibt das gleiche Kürzel. Erst 'Speichern' übernimmt alles.")
        . (EdTarget != "" ? "`n" T("Taste leer lassen: Das Zeichen erscheint dann nur in der Zeichenpalette.") : ""))
    EdGui.Add("Button", "xm w170 Default", T("Speichern und anwenden")).OnEvent("Click", EdSave)
    EdGui.Add("Button", "x+10 w100", T("Abbrechen")).OnEvent("Click", EdClose)
    EdGui.Add("Button", "x+10 w200", T("Datei im Editor öffnen")).OnEvent("Click", EdOpenFile)
    EdGui.OnEvent("Close", EdClose)
    EdGui.OnEvent("Escape", EdClose)

    RefreshLV()
    EdGui.Show()
}

RefreshLV() {
    LV.Delete()
    for r in EdRows {
        if (EdTarget != "") {
            LV.Add("", r.mods, r.key, r.out, (r.pal = "hide" ? T("nein") : T("ja")))
        } else {
            LV.Add("", r.mods, r.key, r.out)
        }
    }
    LV.ModifyCol(1, 150)
    LV.ModifyCol(2, 120)
    LV.ModifyCol(3, EdTarget != "" ? 190 : 300)
    if (EdTarget != "") {
        LV.ModifyCol(4, 110)
    }
}

EdSelect(ctrl, item, selected) {
    if (selected && item > 0 && item <= EdRows.Length) {
        r := EdRows[item]
        palOnly := (r.mods = "" && r.key = "-")
        CB.Text := (palOnly ? "LAlt" : r.mods)
        EdKey.Value := (palOnly ? "" : r.key)
        EdOut.Value := r.out
        if (IsObject(PalCB)) {
            PalCB.Value := (r.pal = "hide" ? 0 : 1)
        }
    }
}

; Haken sofort auf die markierte Zeile anwenden
EdPalToggle(ctrl, *) {
    idx := LV.GetNext(0)
    if (!idx || idx > EdRows.Length) {
        return
    }
    r := EdRows[idx]
    if (!ctrl.Value && r.mods = "" && r.key = "-") {
        ctrl.Value := 1
        MsgBox(T("Ohne Kürzel muss das Zeichen in der Zeichenpalette erscheinen."), APP, "Icon!")
        return
    }
    r.pal := (ctrl.Value ? "" : "hide")
    RefreshLV()
    LV.Modify(idx, "Select Vis")
}

EdAddUpdate(*) {
    mods := Trim(CB.Text)
    key := Trim(EdKey.Value)
    out := EdOut.Value
    palOn := (IsObject(PalCB) ? PalCB.Value : 1)
    palOnly := (IsObject(PalCB) && key = "")
    hk := ""
    try {
        if (out = "") {
            throw Error(T("Ausgabe ist leer"))
        }
        Unescape(out)
        if (palOnly) {
            if (!palOn) {
                throw Error(T("Ohne Kürzel muss das Zeichen in der Zeichenpalette erscheinen."))
            }
        } else {
            hk := MakeHotkey(mods, key)
        }
    } catch as e {
        MsgBox(e.Message, APP, "Icon!")
        return
    }
    if (palOnly) {
        mods := ""
        key := "-"
    }
    idx := 0
    for i, r in EdRows {
        if (palOnly) {
            if (r.mods = "" && r.key = "-" && r.out = out) {
                idx := i
                break
            }
            continue
        }
        try {
            if (StrLower(MakeHotkey(r.mods, r.key)) = StrLower(hk)) {
                idx := i
                break
            }
        }
    }
    row := {mods: mods, key: key, out: out, pal: (palOn ? "" : "hide")}
    if (idx) {
        EdRows[idx] := row
    } else {
        EdRows.Push(row)
    }
    if (EdTarget = "") {
        EdRows := SortRowsAlpha(EdRows)
    }
    idx := EdRows.Length
    for i, r in EdRows {
        if (r == row) {
            idx := i
        }
    }
    RefreshLV()
    LV.Modify(idx, "Select Vis")
}

EdDelete(*) {
    idx := LV.GetNext(0)
    if (!idx) {
        return
    }
    EdRows.RemoveAt(idx)
    RefreshLV()
}

EdSave(*) {
    text := ""
    for h in EdHeader {
        text .= h "`n"
    }
    if (EdHeader.Length > 0) {
        text .= "`n"
    }
    for r in EdRows {
        text .= RowSpec(r) "`t" r.out (r.pal = "hide" ? "`thide" : "") "`n"
    }
    path := EdPath()
    try {
        if (FileExist(path)) {
            FileDelete(path)
        }
        FileAppend(text, path, "UTF-8-RAW")
    } catch as e {
        MsgBox(T("Konnte nicht speichern: ") e.Message, APP, "Icon!")
        return
    }
    EdClose()
    ShowErrors(ActivateScheme(CurrentScheme))
}

EdOpenFile(*) {
    Run('notepad.exe "' EdPath() '"')
}

EdClose(*) {
    global EdGui
    if (IsObject(EdGui)) {
        EdGui.Destroy()
    }
    EdGui := ""
}

; ======================================================= TRANSLITERATIONS-SYSTEME
; Unicode-Normalisierung (form 1 = NFC, 2 = NFD)
NormStr(s, form := 1) {
    if (s = "") {
        return ""
    }
    size := DllCall("Normaliz\NormalizeString", "Int", form, "WStr", s, "Int", -1, "Ptr", 0, "Int", 0, "Int")
    if (size <= 0) {
        return s
    }
    buf := Buffer(size * 2 + 16, 0)
    r := DllCall("Normaliz\NormalizeString", "Int", form, "WStr", s, "Int", -1, "Ptr", buf, "Int", size, "Int")
    if (r <= 0) {
        return s
    }
    return StrGet(buf, "UTF-16")
}

LoadLatTables() {
    for line in StrSplit(LatFwdTable, "`n", "`r") {
        p := StrSplit(line, "|")
        if (p.Length < 4) {
            continue
        }
        if (!LatFwd.Has(p[1])) {
            LatFwd[p[1]] := Map()
            LatMax[p[1]] := 1
        }
        LatFwd[p[1]][p[2]] := {t: p[3], cap: (p[4] = "1")}
        if (StrLen(p[2]) > LatMax[p[1]]) {
            LatMax[p[1]] := StrLen(p[2])
        }
    }
    for line in StrSplit(LatOutTable, "`n", "`r") {
        p := StrSplit(line, "|")
        if (p.Length < 3) {
            continue
        }
        if (!LatOut.Has(p[1])) {
            LatOut[p[1]] := Map()
        }
        LatOut[p[1]][p[2]] := p[3]
    }
    for nm in LatSchemes {
        if (!LatOut.Has(nm)) {
            LatOut[nm] := Map()
        }
    }
}

LatCapFirst(s) => StrUpper(SubStr(s, 1, 1)) SubStr(s, 2)

LatIsCase(name) => (name == "IAST" || name == "ISO 15919")

; zerlegt text nach dem laengsten Treffer der Tabelle des Schemas; t = "" bei unbekanntem Zeichen
LatTokens(text, name) {
    f := LatFwd[name]
    mx := LatMax[name]
    res := []
    i := 1
    n := StrLen(text)
    while (i <= n) {
        L := Min(mx, n - i + 1)
        found := false
        while (L >= 1) {
            s := SubStr(text, i, L)
            if (f.Has(s)) {
                e := f[s]
                res.Push({raw: s, t: e.t, cap: e.cap})
                i += L
                found := true
                break
            }
            L -= 1
        }
        if (!found) {
            res.Push({raw: SubStr(text, i, 1), t: "", cap: false})
            i += 1
        }
    }
    return res
}

; Schema -> IAST (Zwischenform)
LatToPivot(text, name) {
    if (name == "IAST") {
        return text
    }
    o := ""
    for tk in LatTokens(text, name) {
        if (tk.t == "") {
            o .= tk.raw
        } else if (tk.cap) {
            o .= LatCapFirst(tk.t)
        } else {
            o .= tk.t
        }
    }
    return LatIsCase(name) ? NormStr(o, 1) : o
}

; IAST -> Schema
LatFromPivot(text, name) {
    if (name == "IAST") {
        return text
    }
    out := LatOut[name]
    pcs := []
    for tk in LatTokens(text, "IAST") {
        if (tk.t == "") {
            pcs.Push({p: tk.raw, t: ""})
        } else {
            piece := out.Has(tk.t) ? out[tk.t] : tk.t
            if (tk.cap && LatIsCase(name)) {
                piece := LatCapFirst(piece)
            }
            pcs.Push({p: piece, t: tk.t})
        }
    }
    o := ""
    if (name !== "Kürzel-Stil") {
        for pc in pcs {
            o .= pc.p
        }
        return o
    }
    n := pcs.Length
    for k, pc in pcs {
        p := pc.p
        prev := (k > 1) ? pcs[k - 1].p : ""
        nxt := (k < n) ? pcs[k + 1].p : ""
        n1 := SubStr(nxt, 1, 1)
        pl := SubStr(prev, -1)
        if (pc.t == "") {
            if (p == "." && ((prev != "" && InStr("tdnshmrl.", pl, true)) || n1 == "n")) {
                p := "\."
            } else if (p == "-" && n1 != "" && InStr("-aiurl", n1, true)) {
                p := "\-"
            } else if (p == "~" && ((prev != "" && pl == "m") || n1 == "n")) {
                p := "\~"
            }
        } else if (pc.t == "’" && n1 == "s") {
            p := "\'"
        }
        o .= p
    }
    return o
}

LatConvert(text, src, dst) {
    if (src == dst) {
        return text
    }
    return LatFromPivot(LatToPivot(text, src), dst)
}

; Allgemeine Umwandlung. Systeme: die Latein-Schemata, "Devanāgarī", "Wylie" (nur Eingabe), "Tibetisch" (nur Ausgabe)
ConvertAny(text, src, dst, forceDot := false) {
    if (src == "Wylie") {
        return (dst == "Tibetisch") ? WylieToTibetan(text) : ""
    }
    if (src == "Tibetisch") {
        return (dst == "Wylie") ? TibetanToWylie(text) : ""
    }
    srcLat := LatIsScheme(src)
    dstLat := LatIsScheme(dst)
    if (srcLat && dstLat) {
        return LatConvert(text, src, dst)
    }
    if (srcLat && dst == DevaName) {
        prof := (src == "ISO 15919") ? "ISO 15919" : "IAST"
        piv := (prof == "IAST") ? LatToPivot(text, src) : text
        return ConvertToDeva(piv, prof, forceDot)
    }
    if (src == DevaName && dstLat) {
        prof := (dst == "ISO 15919") ? "ISO 15919" : "IAST"
        lat := ConvertFromDeva(text, prof)
        return (prof == "IAST") ? LatFromPivot(lat, dst) : lat
    }
    if (src == DevaName && dst == DevaName) {
        return text
    }
    return ""
}

LatIsScheme(name) {
    for nm in LatSchemes {
        if (nm == name) {
            return true
        }
    }
    return false
}

; ------------------------------------------------------------------ WYLIE -> TIBETISCH
HexStr(h) {
    if (h == "_") {
        return ""
    }
    s := ""
    for part in StrSplit(h, "-") {
        s .= Chr(Integer("0x" part))
    }
    return s
}

LoadWylieTables() {
    for line in StrSplit(WylieTable, "`n", "`r") {
        p := StrSplit(line, " ")
        if (p.Length < 3) {
            continue
        }
        k := HexStr(p[2])
        v := HexStr(p[3])
        switch p[1] {
            case "CONS": WyCons[k] := v
            case "SUBJ": WySubj[k] := v
            case "VOW": WyVow[k] := v
            case "FINAL": WyFinal[k] := v
            case "FCLASS": WyFClass[k] := v
            case "OTHER": WyOther[k] := v
            case "SUP", "SUB":
                tb := (p[1] == "SUP") ? WySup : WySub
                if (!tb.Has(k)) {
                    tb[k] := Map()
                }
                tb[k][v] := 1
            case "TOP": TbTop[k] := v
            case "TSUBJ": TbSubj[k] := v
            case "TVOW": TbVow[k] := v
            case "TVOWL": TbVowL[k] := v
            case "TFINW": TbFinW[k] := v
            case "TFINC": TbFinC[k] := v
            case "TCARET": TbCaret[k] := v
            case "TOTH": TbOther[k] := v
            case "TSTK": TbStacks[k] := 1
            case "TSUF": TbSuf[k] := 1
            case "TAMB": TbAmb[k] := v
            case "TPRE", "TSUF2":
                tb2 := (p[1] == "TPRE") ? TbPre : TbSuf2
                if (!tb2.Has(k)) {
                    tb2[k] := Map()
                }
                tb2[k][v] := 1
            case "TOK":
                WyTokens[k] := 1
                if (StrLen(k) >= 2) {
                    c := SubStr(k, 1, 1)
                    if (!WyTStart.Has(c) || WyTStart[c] < StrLen(k)) {
                        WyTStart[c] := StrLen(k)
                    }
                }
        }
    }
}

WyNormalize(s) {
    for pr in WySloppy {
        s := StrReplace(s, pr[1], pr[2], true)
    }
    loop 10 {
        d := A_Index - 1
        s := StrReplace(s, " " d, "_" d, true)
    }
    s := StrReplace(s, "_ ", "__", true)
    for c in ["G", "K", "C", "B", "P", "L", "Z"] {
        s := StrReplace(s, c, StrLower(c), true)
    }
    s := StrReplace(s, "Sh", Chr(0xE000), true)
    s := StrReplace(s, "S", "s", true)
    s := StrReplace(s, Chr(0xE000), "Sh", true)
    return s
}

WySplit(s) {
    res := []
    i := 1
    n := StrLen(s)
    while (i <= n) {
        c := SubStr(s, i, 1)
        k := 0
        if (WyTStart.Has(c)) {
            l := WyTStart[c]
            while (l >= 2) {
                if (i + l - 1 <= n && WyTokens.Has(SubStr(s, i, l))) {
                    k := l
                    break
                }
                l -= 1
            }
        }
        if (k > 0) {
            res.Push(SubStr(s, i, k))
            i += k
        } else {
            res.Push(c)
            i += 1
        }
    }
    return res
}

; ein Stapel ab Position i (1-basiert); liefert {out, used, visa}
WyStack(tk, i) {
    n := tk.Length
    orig := i
    out := ""
    cons := 0
    vf := ""
    plus := false
    caret := 0
    fin := Map()
    t := tk[i]
    t2 := (i + 1 <= n) ? tk[i + 1] : ""
    if (t2 != "" && WySup.Has(t) && WySup[t].Has(t2)) {
        out .= WyCons[t]
        cons += 1
        i += 1
        while (i <= n && tk[i] == "^") {
            caret += 1
            i += 1
        }
    }
    loop {
        t := (i <= n) ? tk[i] : ""
        if (WyCons.Has(t)) {
            out .= (out != "") ? WySubj[t] : WyCons[t]
            i += 1
            if (t == "a") {
                vf := "a"
            } else {
                cons += 1
            }
            while (i <= n && tk[i] == "^") {
                caret += 1
                i += 1
            }
            z := 0
            while (z < 2) {
                t2 := (i <= n) ? tk[i] : ""
                if (t2 != "" && WySub.Has(t2)) {
                    if (t2 == "l" && cons > 1) {
                        break
                    }
                    out .= WySubj[t2]
                    i += 1
                    cons += 1
                    while (i <= n && tk[i] == "^") {
                        caret += 1
                        i += 1
                    }
                    t := t2
                } else {
                    break
                }
                z += 1
            }
        }
        if (caret > 0) {
            fin[WyFClass["^"]] := "^"
            out .= WyFinal["^"]
            caret := 0
        }
        t := (i <= n) ? tk[i] : ""
        if (t != "" && WyVow.Has(t)) {
            if (out = "") {
                out .= WyVow["a"]
            }
            if (t !== "a") {
                out .= WyVow[t]
            }
            i += 1
            vf := t
        }
        t := (i <= n) ? tk[i] : ""
        if (t == "+") {
            i += 1
            plus := true
            t := (i <= n) ? tk[i] : ""
            if (t == "" || (!WyVow.Has(t) && !WySubj.Has(t))) {
                break
            }
            continue
        }
        break
    }
    t := (i <= n) ? tk[i] : ""
    while (t != "" && WyFClass.Has(t)) {
        k := WyFClass[t]
        if (!fin.Has(k)) {
            fin[k] := t
            out .= WyFinal[t]
        }
        i += 1
        t := (i <= n) ? tk[i] : ""
    }
    if (i <= n && tk[i] == ".") {
        i += 1
    }
    if (cons > 1 && vf == "") {
        if (!plus) {
            i := orig + 1
            cons := 1
            out := WyCons[tk[orig]]
        }
    }
    return {out: out, used: i - orig, visa: fin.Has("H")}
}

WylieToTibetan(s) {
    s := RegExReplace(s, "^\s+", "")
    s := WyNormalize(s)
    tk := WySplit(s)
    out := ""
    i := 1
    n := tk.Length
    while (i <= n) {
        t := tk[i]
        if (t == "[") {
            j := i + 1
            while (j <= n && tk[j] != "]") {
                out .= tk[j]
                j += 1
            }
            if (j > n) {
                break
            }
            i := j + 1
            continue
        }
        if (WyOther.Has(t)) {
            out .= WyOther[t]
            i += 1
            if (t == " ") {
                while (i <= n && tk[i] == " ") {
                    i += 1
                }
            }
            continue
        }
        if (WyVow.Has(t) || WyCons.Has(t)) {
            visa := false
            while (i <= n && (WyVow.Has(tk[i]) || WyCons.Has(tk[i])) && !visa) {
                r := WyStack(tk, i)
                out .= r.out
                i += r.used
                visa := r.visa
            }
            continue
        }
        if (t == Chr(0xFEFF) || t == Chr(0x200B)) {
            i += 1
            continue
        }
        if (t == "`r`n" || t == "`n" || t == "`r") {
            out .= t
            i += 1
            while (i <= n && tk[i] == " ") {
                i += 1
            }
            continue
        }
        out .= t
        i += 1
    }
    return out
}

; ------------------------------------------------------------------ BEREINIGEN
; opts: Objekt mit nfc, spaces, quotes, invis, dots (0/1)
CleanText(s, o) {
    if (o.invis) {
        for cp in [0x200B, 0xFEFF, 0x00AD, 0x2060] {
            s := StrReplace(s, Chr(cp), "")
        }
    }
    if (o.quotes) {
        for cp in [0x02BC, 0x02B9, 0x2018, 0x02BE, 0x0060, 0x00B4] {
            s := StrReplace(s, Chr(cp), "’")
        }
    }
    if (o.dots) {
        s := RegExReplace(s, "(?<!\.)\.\.(?!\.)", ".")
    }
    if (o.hyeol) {
        s := RegExReplace(s, "(?<=\p{L})-[ \t]*\r?\n[ \t]*(?=\p{L})", "")
    }
    if (o.hyall) {
        s := RegExReplace(s, "(?<=\p{L})-(?=\p{L})", "")
    }
    if (o.spaces) {
        s := RegExReplace(s, "[ \t\x{00A0}]+(?=\r?\n|$)", "")
        s := RegExReplace(s, "(?<=\S)[ \x{00A0}]{2,}(?=\S)", " ")
    }
    if (o.nfc) {
        s := NormStr(s, 1)
    }
    return s
}

; ------------------------------------------------------------------ TIBETISCH -> WYLIE
TbJoin(arr, sep) {
    r := ""
    for x in arr {
        r .= (A_Index > 1 ? sep : "") x
    }
    return r
}

TbStackOne(s, n, i) {
    orig := i
    st := {top: "", stack: [], caret: false, vowels: [], finals: [], ff: Map(), visarga: false, cons: "", single: "", used: 0, prefix: false, suffix: false, suff2: false, dot: false}
    t := SubStr(s, i, 1)
    i += 1
    st.top := TbTop.Has(t) ? TbTop[t] : ""
    if (st.top != "") {
        st.stack.Push(st.top)
    }
    while (i <= n) {
        t := SubStr(s, i, 1)
        if (TbSubj.Has(t)) {
            st.stack.Push(TbSubj[t])
            i += 1
        } else if (TbVow.Has(t)) {
            st.vowels.Push(TbVow[t])
            i += 1
        } else if (TbFinW.Has(t)) {
            o := TbFinW[t]
            klass := TbFinC[t]
            i += 1
            if (o == "^") {
                st.caret := true
            } else {
                if (o == "H") {
                    st.visarga := true
                }
                st.finals.Push(o)
                if (!st.ff.Has(klass)) {
                    st.ff[klass] := o
                }
            }
        } else {
            break
        }
    }
    if (st.top == "a" && st.stack.Length == 1 && st.vowels.Length > 0) {
        st.stack.RemoveAt(1)
    }
    if (st.vowels.Length > 1 && st.vowels[1] == "A" && TbVowL.Has(st.vowels[2])) {
        l := TbVowL[st.vowels[2]]
        st.vowels.RemoveAt(1)
        st.vowels.RemoveAt(1)
        st.vowels.InsertAt(1, l)
    }
    if (st.caret && st.stack.Length == 1 && TbCaret.Has(st.top)) {
        l := TbCaret[st.top]
        st.top := l
        st.stack.RemoveAt(1)
        st.stack.InsertAt(1, l)
        st.caret := false
    }
    st.cons := TbJoin(st.stack, "+")
    if (st.stack.Length == 1 && st.stack[1] !== "a" && !st.caret && st.vowels.Length == 0 && st.finals.Length == 0) {
        st.single := st.cons
    }
    st.used := i - orig
    return st
}

TbPut(st) {
    out := ""
    if (TbStacks.Has(st.cons)) {
        out .= TbJoin(st.stack, "")
    } else {
        out .= st.cons
    }
    if (st.caret) {
        out .= "^"
    }
    if (st.vowels.Length > 0) {
        out .= TbJoin(st.vowels, "+")
    } else if (!st.prefix && !st.suffix && !st.suff2 && (st.cons == "" || SubStr(st.cons, -1) !== "a")) {
        out .= "a"
    }
    out .= TbJoin(st.finals, "")
    if (st.dot) {
        out .= "."
    }
    return out
}

TbIsPrefix(pref, after) {
    return TbPre.Has(pref) && TbPre[pref].Has(after)
}

TbIsSuff2(suff, before) {
    return TbSuf2.Has(suff) && TbSuf2[suff].Has(before)
}

; eine Silbe; liefert {w, used}
TbTsek(s, n, i) {
    orig := i
    stacks := []
    loop {
        st := TbStackOne(s, n, i)
        stacks.Push(st)
        i += st.used
        if (st.visarga) {
            break
        }
        if (i > n || !TbTop.Has(SubStr(s, i, 1))) {
            break
        }
    }
    cnt := stacks.Length
    if (cnt > 1 && stacks[1].single != "") {
        cs := StrReplace(stacks[2].cons, "+w", "", true)
        if (TbIsPrefix(stacks[1].single, cs)) {
            stacks[1].prefix := true
        }
    }
    if (cnt > 1 && stacks[cnt].single != "" && TbSuf.Has(stacks[cnt].single)) {
        stacks[cnt].suffix := true
    }
    if (cnt > 2 && stacks[cnt].single != "" && stacks[cnt - 1].single != "" && TbSuf.Has(stacks[cnt - 1].single) && TbIsSuff2(stacks[cnt].single, stacks[cnt - 1].single)) {
        stacks[cnt].suff2 := true
        stacks[cnt - 1].suffix := true
    }
    if (cnt == 2 && stacks[1].prefix && stacks[2].suffix) {
        stacks[1].prefix := false
    }
    if (cnt == 3 && stacks[1].prefix && stacks[2].suffix && stacks[3].suff2) {
        ztr := stacks[1].single stacks[2].single stacks[3].single
        root := TbAmb.Has(ztr) ? Integer(TbAmb[ztr]) : 1
        stacks[root + 1].prefix := false
        stacks[root + 1].suffix := false
        stacks[root + 2].suff2 := false
    }
    if (cnt > 1 && stacks[1].prefix && TbStacks.Has(stacks[1].single "+" stacks[2].cons)) {
        stacks[1].dot := true
    }
    out := ""
    for st in stacks {
        out .= TbPut(st)
    }
    return {w: out, used: i - orig}
}

TbNonTibAfter(s, n, i) {
    while (i <= n && SubStr(s, i, 1) == " ") {
        i += 1
    }
    if (i > n) {
        return false
    }
    t := SubStr(s, i, 1)
    return (!TbTop.Has(t) && !TbOther.Has(t) && t != "`r" && t != "`n")
}

TibetanToWylie(s) {
    for pr in [[0x0F76, "0FB2-0F80"], [0x0F77, "0FB2-0F71-0F80"], [0x0F78, "0FB3-0F80"], [0x0F79, "0FB3-0F71-0F80"], [0x0F81, "0F71-0F80"], [0x0F75, "0F71-0F74"], [0x0F73, "0F71-0F72"]] {
        s := StrReplace(s, Chr(pr[1]), HexStr(pr[2]))
    }
    out := ""
    i := 1
    n := StrLen(s)
    while (i <= n) {
        t := SubStr(s, i, 1)
        if (TbTop.Has(t)) {
            r := TbTsek(s, n, i)
            out .= r.w
            i += r.used
            continue
        }
        if (TbOther.Has(t) && (t != " " || !TbNonTibAfter(s, n, i))) {
            out .= TbOther[t]
            i += 1
            continue
        }
        if (t == "`r" || t == "`n") {
            i += 1
            out .= t
            if (t == "`r" && i <= n && SubStr(s, i, 1) == "`n") {
                i += 1
                out .= "`n"
            }
            continue
        }
        if (t == Chr(0xFEFF) || t == Chr(0x200B)) {
            i += 1
            continue
        }
        cp := Ord(t)
        if (cp >= 0x0F00 && cp <= 0x0FFF) {
            out .= "\u" Format("{:04x}", cp)
            i += 1
            continue
        }
        out .= "["
        while (!TbTop.Has(t) && (!TbOther.Has(t) || t == " ") && t != "`r" && t != "`n") {
            if (t == "[" || t == "]") {
                out .= "\" t
            } else if (Ord(t) >= 0x0F00 && Ord(t) <= 0x0FFF) {
                out .= "\u" Format("{:04x}", Ord(t))
            } else {
                out .= t
            }
            i += 1
            if (i > n) {
                break
            }
            t := SubStr(s, i, 1)
        }
        out .= "]"
    }
    return out
}

; ======================================================= DEVANAGARI-UMWANDLUNG
LoadDevaTables() {
    global DevaMaps, RevMaps
    for prof, text in Map("IAST", DevaTableIAST, "ISO 15919", DevaTableISO) {
        m := Map()
        maxLen := 1
        for line in StrSplit(text, "`n", "`r") {
            if (line = "") {
                continue
            }
            p := StrSplit(line, "|")
            if (p.Length < 3) {
                continue
            }
            m[p[1]] := {kind: p[2], a: p[3], b: (p.Length >= 4 ? p[4] : "")}
            if (StrLen(p[1]) > maxLen) {
                maxLen := StrLen(p[1])
            }
        }
        DevaMaps[prof] := {map: m, maxLen: maxLen}
    }
    for prof, col in Map("IAST", 3, "ISO 15919", 4) {
        r := Map()
        for line in StrSplit(DevaRevTable, "`n", "`r") {
            if (line = "") {
                continue
            }
            p := StrSplit(line, "|")
            if (p.Length < 4) {
                continue
            }
            r[p[1]] := {kind: p[2], v: p[col]}
        }
        RevMaps[prof] := r
    }
}

; liefert {tok, ent} fuer das laengste passende Token ab Position i, sonst ""
MatchToken(text, i, prof) {
    L := Min(prof.maxLen, StrLen(text) - i + 1)
    while (L >= 1) {
        s := SubStr(text, i, L)
        if (prof.map.Has(s)) {
            return {tok: s, ent: prof.map[s]}
        }
        L -= 1
    }
    return ""
}

; Lateinische Transliteration (IAST / ISO 15919) -> Devanagari
; forceDot: Punkt immer als Danda behandeln (Live-Modus)
ConvertToDeva(text, profName, forceDot := false) {
    prof := DevaMaps[profName]
    out := ""
    pending := false          ; letzter Konsonant wartet auf Vokal/Virama
    i := 1
    n := StrLen(text)
    while (i <= n) {
        mt := MatchToken(text, i, prof)
        if (!IsObject(mt)) {
            c := SubStr(text, i, 1)
            ; Konsonant + Leerzeichen + Wort: Wortgrenze verbinden (kein Virama, kein Leerzeichen)
            if (pending && JoinWords && (c = " " || c = "`t")) {
                j := i
                while (j <= n && (SubStr(text, j, 1) = " " || SubStr(text, j, 1) = "`t")) {
                    j += 1
                }
                m2 := MatchToken(text, j, prof)
                if (IsObject(m2) && (m2.ent.kind = "C" || m2.ent.kind = "V")) {
                    i := j
                    continue
                }
            }
            if (pending) {
                out .= VIRAMA
                pending := false
            }
            if (SubStr(text, i, 2) = "||") {
                out .= Chr(0x0965)
                i += 2
                continue
            }
            if (c = "." && (DandaDot || forceDot)) {
                j := i
                while (SubStr(text, j, 1) = ".") {
                    j += 1
                }
                run := j - i
                if (run = 1) {
                    out .= Chr(0x0964)
                } else if (run = 2) {
                    out .= Chr(0x0965)
                } else {
                    out .= SubStr(text, i, run)
                }
                i := j
                continue
            }
            d := InStr("0123456789", c)
            if (d) {
                out .= Chr(0x0966 + d - 1)
            } else if (c = "|") {
                out .= Chr(0x0964)
            } else if (c = "’" || c = "'") {
                out .= Chr(0x093D)
            } else {
                out .= c
            }
            i += 1
            continue
        }
        i += StrLen(mt.tok)
        ent := mt.ent
        if (ent.kind = "C") {
            if (pending) {
                out .= VIRAMA
            }
            out .= ent.a
            pending := true
        } else if (ent.kind = "V") {
            if (pending) {
                out .= ent.b
                pending := false
            } else {
                out .= ent.a
            }
        } else {
            pending := false
            out .= ent.a
        }
    }
    if (pending) {
        out .= VIRAMA
    }
    return out
}

; Devanagari -> IAST / ISO 15919
ConvertFromDeva(text, profName) {
    m := RevMaps[profName]
    out := ""
    pendA := false            ; letzter Konsonant: inhaerentes a noch nicht ausgegeben
    i := 1
    n := StrLen(text)
    while (i <= n) {
        two := SubStr(text, i, 2)
        if (StrLen(two) = 2 && m.Has(two)) {
            key := two
            i += 2
        } else {
            key := SubStr(text, i, 1)
            i += 1
        }
        kind := "O"
        v := key
        if (key = Chr(0x094D)) {
            kind := "X"
        } else if (key = Chr(0x093C)) {
            kind := "N"
        } else if (key = Chr(0x200C) || key = Chr(0x200D)) {
            kind := "Z"
        } else if (key = Chr(0x0964)) {
            kind := "D"
            v := DandaDot ? "." : "|"
        } else if (key = Chr(0x0965)) {
            kind := "D"
            v := DandaDot ? ".." : "||"
        } else if (m.Has(key)) {
            kind := m[key].kind
            v := m[key].v
        }
        if (kind = "M") {
            out .= v
            pendA := false
        } else if (kind = "X") {
            pendA := false
        } else if (kind = "Z" || kind = "N") {
            continue
        } else {
            if (pendA) {
                out .= "a"
                pendA := false
            }
            out .= v
            if (kind = "C") {
                pendA := true
            }
        }
    }
    if (pendA) {
        out .= "a"
    }
    return out
}

; Markierten Text kopieren, umwandeln, ersetzen. dir: "toDeva" oder "toLatin"
ConvertSelection(dir) {
    KeyWait("Ctrl", "T1")
    KeyWait("Alt", "T1")
    KeyWait("Shift", "T1")
    saved := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if (!ClipWait(1)) {
        A_Clipboard := saved
        TrayTip(T("Nichts markiert."), APP)
        return
    }
    if (dir = "toDeva") {
        res := ConvertAny(A_Clipboard, DevaProfile, DevaName)
    } else {
        res := ConvertAny(A_Clipboard, DevaName, DevaProfile)
    }
    A_Clipboard := res
    ClipWait(1)
    Send("^v")
    Sleep(250)
    A_Clipboard := saved
}

SetDevaProfile(prof, *) {
    global DevaProfile
    DevaProfile := prof
    try {
        IniWrite(prof, IniFile, "General", "DevaProfile")
    }
    BuildTray()
}

ToggleOpt(which, *) {
    global DandaDot, JoinWords
    if (which = "dot") {
        DandaDot := !DandaDot
    } else {
        JoinWords := !JoinWords
    }
    SaveOpts()
    SyncCv()
    BuildTray()
}

SaveOpts() {
    try {
        IniWrite(DandaDot ? "1" : "0", IniFile, "General", "DandaDot")
        IniWrite(JoinWords ? "1" : "0", IniFile, "General", "JoinWords")
    }
}

SyncCv() {
    if (IsObject(CvGui) && IsObject(CvDot)) {
        CvDot.Value := DandaDot ? 1 : 0
        CvJoin.Value := JoinWords ? 1 : 0
        CvUpdate()
    }
}

CvFromId() => SysIds[CvFrom.Value]
CvToId() => SysIds[CvTo.Value]

CvLabels() {
    a := []
    for id in SysIds {
        a.Push(SysLabel(id))
    }
    return a
}

ShowConverter(*) {
    global CvGui, CvIn, CvOut, CvFrom, CvTo, CvDot, CvJoin, CvStyle, CvStyleTxt
    if (IsObject(CvGui)) {
        CvGui.Show()
        return
    }
    CvGui := Gui(, APP " – " T("Umwandlung"))
    CvGui.SetFont("s11", "Segoe UI")
    CvGui.Add("Text", , T("Eingabe hier schreiben oder einfügen:"))
    CvIn := CvGui.Add("Edit", "r6 w620")
    CvGui.Add("Text", "xm", T("Von:"))
    CvFrom := CvGui.Add("DropDownList", "x+8 w190", CvLabels())
    CvGui.Add("Text", "x+14", T("Nach:"))
    CvTo := CvGui.Add("DropDownList", "x+8 w190", CvLabels())
    swp := CvGui.Add("Button", "x+14 w110", "↔ " T("Tauschen"))
    fi := IniRead(IniFile, "General", "CvFrom", DevaProfile)
    ti := IniRead(IniFile, "General", "CvTo", DevaName)
    CvFrom.Choose(SysIndex(fi))
    CvTo.Choose(SysIndex(ti))
    if (IsTibSys(CvFromId()) != IsTibSys(CvToId()) || (!IsTibSys(CvFromId()) && CvFromId() == CvToId() && false)) {
        CvTo.Choose(SysIndex(DevaName))
        CvFrom.Choose(SysIndex(DevaProfile))
    }
    CvStyleTxt := CvGui.Add("Text", "xm", T("Tibetische Schrift:"))
    CvStyle := CvGui.Add("DropDownList", "x+8 w260 Choose" TibStyle, ["Uchen (dbu can)", "Ume (dbu med)", "Khyuyig ('khyug yig)"])
    CvDot := CvGui.Add("Checkbox", "xm", T("Punkt (.) = Daṇḍa"))
    CvDot.Value := DandaDot ? 1 : 0
    CvJoin := CvGui.Add("Checkbox", "xm", JoinLbl() " (tat sukham asti. → तत्सुखमस्ति।)")
    CvJoin.Value := JoinWords ? 1 : 0
    CvGui.Add("Text", "xm", T("Ergebnis:"))
    CvOut := CvGui.Add("Edit", "xm r6 w620 ReadOnly")
    CvGui.Add("Button", "xm w200", T("Ergebnis kopieren")).OnEvent("Click", CvCopy)
    CvGui.Add("Button", "x+10 w120", T("Schließen")).OnEvent("Click", CvClose)
    CvIn.OnEvent("Change", CvUpdate)
    CvFrom.OnEvent("Change", CvSysChanged.Bind("from"))
    CvTo.OnEvent("Change", CvSysChanged.Bind("to"))
    CvStyle.OnEvent("Change", CvStyleChanged)
    swp.OnEvent("Click", CvSwap)
    CvDot.OnEvent("Click", CvOptChanged)
    CvJoin.OnEvent("Click", CvOptChanged)
    CvGui.OnEvent("Close", CvClose)
    CvGui.OnEvent("Escape", CvClose)
    CvAfterChange()
    CvGui.Show()
}

CvUpdate(*) {
    if (!IsObject(CvOut)) {
        return
    }
    src := CvFromId()
    dst := CvToId()
    res := ConvertAny(CvIn.Value, src, dst)
    if (res == "" && CvIn.Value != "" && src != dst) {
        res := T("Diese Kombination ist nicht möglich. Tibetisch geht nur mit Wylie.")
    }
    CvOut.Value := res
}

; Wylie und Tibetisch gehoeren zusammen: die jeweils andere Seite wird automatisch gesetzt
CvSysChanged(which, *) {
    f := CvFromId()
    tt := CvToId()
    if (which = "from") {
        if (f == "Wylie") {
            CvTo.Choose(SysIndex(TibId))
        } else if (f == TibId) {
            CvTo.Choose(SysIndex("Wylie"))
        } else if (IsTibSys(tt)) {
            CvTo.Choose(SysIndex(f == DevaName ? DevaProfile : DevaName))
        }
    } else {
        if (tt == "Wylie") {
            CvFrom.Choose(SysIndex(TibId))
        } else if (tt == TibId) {
            CvFrom.Choose(SysIndex("Wylie"))
        } else if (IsTibSys(f)) {
            CvFrom.Choose(SysIndex(tt == DevaName ? DevaProfile : DevaName))
        }
    }
    CvAfterChange()
}

; vertauscht Von und Nach; das bisherige Ergebnis wird zur neuen Eingabe
CvSwap(*) {
    f := CvFromId()
    tt := CvToId()
    old := CvOut.Value
    CvFrom.Choose(SysIndex(tt))
    CvTo.Choose(SysIndex(f))
    CvIn.Value := old
    CvAfterChange()
}

CvAfterChange() {
    global DevaProfile
    f := CvFromId()
    t := CvToId()
    try {
        IniWrite(f, IniFile, "General", "CvFrom")
        IniWrite(t, IniFile, "General", "CvTo")
    }
    ; das zuletzt gewaehlte Latein-System gilt auch fuer die Tastenkuerzel Strg+Alt+Umschalt+D/I
    for sel in [f, t] {
        if (LatIsScheme(sel)) {
            DevaProfile := sel
            try {
                IniWrite(sel, IniFile, "General", "DevaProfile")
            }
            break
        }
    }
    tib := IsTibSys(f) || IsTibSys(t)
    CvStyleTxt.Visible := tib
    CvStyle.Visible := tib
    CvDot.Visible := !tib
    CvJoin.Visible := !tib
    CvApplyFonts()
    CvUpdate()
    BuildTray()
}

CvStyleChanged(*) {
    global TibStyle
    TibStyle := CvStyle.Value
    try {
        IniWrite(TibStyle, IniFile, "General", "TibStyle")
    }
    CvApplyFonts()
}

CvOptChanged(*) {
    global DandaDot, JoinWords
    DandaDot := (CvDot.Value = 1)
    JoinWords := (CvJoin.Value = 1)
    SaveOpts()
    CvUpdate()
    BuildTray()
}

CvCopy(*) {
    if (CvToId() == TibId && CvOut.Value != "") {
        ; Tibetisch: zusaetzlich Schriftart und Groesse mitgeben (Word u. a. uebernehmen sie), reiner Text bleibt erhalten
        ClipSetRich(CvOut.Value, FontFam(TibFonts[TibStyle]), TibSizes[TibStyle])
    } else {
        A_Clipboard := CvOut.Value
    }
    TrayTip(T("Ergebnis in der Zwischenablage."), APP)
}

; Zwischenablage: Unicode-Text + HTML-Format mit Schriftart (CF_HTML)
ClipSetRich(text, fam, pt) {
    esc := StrReplace(StrReplace(StrReplace(text, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
    esc := StrReplace(StrReplace(esc, "`r`n", "<br>"), "`n", "<br>")
    st := "font-family:'" fam "';mso-bidi-font-family:'" fam "';mso-fareast-font-family:'" fam "';font-size:" pt "pt"
    pre := "<html><body>`r`n<!--StartFragment-->"
    esc := "<span style=" Chr(34) st Chr(34) ">" esc "</span>"
    post := "<!--EndFragment-->`r`n</body></html>"
    hdrLen := 105
    sH := hdrLen
    sF := hdrLen + StrPut(pre, "UTF-8") - 1
    eF := sF + StrPut(esc, "UTF-8") - 1
    eH := eF + StrPut(post, "UTF-8") - 1
    hdr := Format("Version:0.9`r`nStartHTML:{:010}`r`nEndHTML:{:010}`r`nStartFragment:{:010}`r`nEndFragment:{:010}`r`n", sH, eH, sF, eF)
    html := hdr pre esc post
    try {
        if (!DllCall("OpenClipboard", "Ptr", 0)) {
            throw Error("clipboard")
        }
        DllCall("EmptyClipboard")
        bytes := (StrLen(text) + 1) * 2
        h1 := DllCall("GlobalAlloc", "UInt", 0x42, "UPtr", bytes, "Ptr")
        p1 := DllCall("GlobalLock", "Ptr", h1, "Ptr")
        StrPut(text, p1, "UTF-16")
        DllCall("GlobalUnlock", "Ptr", h1)
        DllCall("SetClipboardData", "UInt", 13, "Ptr", h1)
        fmt := DllCall("RegisterClipboardFormatW", "Str", "HTML Format", "UInt")
        n := StrPut(html, "UTF-8")
        h2 := DllCall("GlobalAlloc", "UInt", 0x42, "UPtr", n, "Ptr")
        p2 := DllCall("GlobalLock", "Ptr", h2, "Ptr")
        StrPut(html, p2, "UTF-8")
        DllCall("GlobalUnlock", "Ptr", h2)
        DllCall("SetClipboardData", "UInt", fmt, "Ptr", h2)
        DllCall("CloseClipboard")
    } catch {
        try {
            DllCall("CloseClipboard")
        }
        A_Clipboard := text
    }
}

CvClose(*) {
    global CvGui
    if (IsObject(CvGui)) {
        CvGui.Destroy()
    }
    CvGui := ""
}

; ================================================================ BEREINIGEN
; Markierten Text kopieren, bereinigen, ersetzen
CleanSelection() {
    KeyWait("Ctrl", "T1")
    KeyWait("Alt", "T1")
    KeyWait("Shift", "T1")
    saved := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if (!ClipWait(1)) {
        A_Clipboard := saved
        TrayTip(T("Nichts markiert."), APP)
        return
    }
    A_Clipboard := CleanText(A_Clipboard, CleanOpts)
    ClipWait(1)
    Send("^v")
    Sleep(250)
    A_Clipboard := saved
}

LoadCleanOpts() {
    for k in ["nfc", "quotes", "dots", "spaces", "invis", "hyeol", "hyall"] {
        CleanOpts.%k% := (IniRead(IniFile, "Clean", k, (k = "hyall") ? "0" : "1") = "1") ? 1 : 0
    }
}

SaveCleanOpts() {
    try {
        for k in ["nfc", "quotes", "dots", "spaces", "invis", "hyeol", "hyall"] {
            IniWrite(CleanOpts.%k%, IniFile, "Clean", k)
        }
    }
}

ShowCleaner(*) {
    global ClGui, ClIn, ClOut, ClBoxes
    if (IsObject(ClGui)) {
        ClGui.Show()
        return
    }
    ClGui := Gui(, APP " – " T("Text bereinigen"))
    ClGui.SetFont("s11", "Segoe UI")
    ClGui.Add("Text", , T("Text hier einfügen:"))
    ClIn := ClGui.Add("Edit", "r7 w700")
    ClBoxes := Map()
    labels := [["nfc", T("Unicode normalisieren (zusammengesetzte Zeichen, NFC: ā als ein Zeichen)")]
        , ["quotes", T("Apostrophe vereinheitlichen (ʼ ‘ ´ ` → ’ , das Zeichen für den Avagraha)")]
        , ["dots", T("Doppelten Punkt „..“ zu einem Punkt „.“ machen")]
        , ["spaces", T("Überflüssige Leerzeichen entfernen (doppelte, am Zeilenende)")]
        , ["invis", T("Unsichtbare Zeichen entfernen (Zero-Width-Space, BOM, weicher Bindestrich)")]
        , ["hyeol", T("Silbentrennung am Zeilenende aufheben (Trennstrich + Zeilenumbruch entfernen)")]
        , ["hyall", T("Alle Bindestriche zwischen Buchstaben entfernen (deva-datta → devadatta)")]]
    for pr in labels {
        cb := ClGui.Add("Checkbox", "xm", T(pr[2]))
        cb.Value := CleanOpts.%pr[1]%
        cb.OnEvent("Click", ClOptChanged.Bind(pr[1]))
        ClBoxes[pr[1]] := cb
    }
    ClGui.Add("Text", "xm", T("Ergebnis:"))
    ClOut := ClGui.Add("Edit", "xm r7 w700 ReadOnly")
    ClGui.Add("Button", "xm w200", T("Ergebnis kopieren")).OnEvent("Click", ClCopy)
    ClGui.Add("Button", "x+10 w120", T("Schließen")).OnEvent("Click", ClClose)
    ClIn.OnEvent("Change", ClUpdate)
    ClGui.OnEvent("Close", ClClose)
    ClGui.OnEvent("Escape", ClClose)
    ClIn.SetFont("s" FontSize, FontFam(LatinFont))
    ClOut.SetFont("s" FontSize, FontFam(LatinFont))
    ClGui.Show()
}

ClOptChanged(key, ctrl, *) {
    CleanOpts.%key% := ctrl.Value
    SaveCleanOpts()
    ClUpdate()
}

ClUpdate(*) {
    if (IsObject(ClOut)) {
        ClOut.Value := CleanText(ClIn.Value, CleanOpts)
    }
}

ClCopy(*) {
    A_Clipboard := ClOut.Value
    TrayTip(T("Ergebnis in der Zwischenablage."), APP)
}

ClClose(*) {
    global ClGui
    if (IsObject(ClGui)) {
        ClGui.Destroy()
    }
    ClGui := ""
}

; ============================================================ LIVE-MODUS
; Du tippst Transliteration (mit den Kuerzeln), im Programm erscheint sofort Devanagari.
; Prinzip: Die Buchstaben des laufenden Wortes werden gemerkt, bei jedem Tastendruck
; wird das Wort neu umgewandelt und nur die geaenderte Stelle ersetzt (meist 1-2
; Rueckschritte plus neue Zeichen).
LiveToggle(*) {
    global LiveOn
    LiveOn := !LiveOn
    LiveReset()
    if (LiveOn && !Paused) {
        ShowErrors(LiveRegister())
    } else {
        LiveUnregister()
    }
    BuildTray()
    TrayTip((LiveOn ? T("Live-Modus an: Transliteration tippen, Devanāgarī erscheint sofort.") : T("Live-Modus aus.")), APP)
}

LiveProf() => (DevaProfile == "ISO 15919" ? "ISO 15919" : "IAST")

LiveReset() {
    global LiveChunks, LiveEmitted, LivePrev, LiveSp
    LiveChunks := []
    LiveEmitted := ""
    LivePrev := ""
    LiveSp := false
}

LiveText() {
    s := ""
    for c in LiveChunks {
        s .= c
    }
    return s
}

; Ersetzt das bisher ausgegebene Wort (LiveEmitted) durch die neue Umwandlung
LiveSync() {
    global LiveEmitted
    newDev := ConvertToDeva(LiveText(), LiveProf(), true)
    old := LiveEmitted
    n := Min(StrLen(old), StrLen(newDev))
    p := 0
    while (p < n && SubStr(old, p + 1, 1) == SubStr(newDev, p + 1, 1)) {
        p += 1
    }
    del := StrLen(old) - p
    ins := SubStr(newDev, p + 1)
    if (del > 0) {
        Send("{BS " del "}")
    }
    if (ins != "") {
        SendText(ins)
    }
    LiveEmitted := newDev
}

; Ein Zeichen oder eine Zeichenfolge (eine Taste) kommt hinein
LiveKeyIn(t) {
    global LiveChunks, LiveEmitted, LivePrev, LiveSp
    Critical()
    if (RegExMatch(t, "[\r\n\t]")) {
        LiveReset()
        SendText(t)
        return
    }
    if (JoinWords && LiveChunks.Length = 0 && LiveSp && IsObject(LivePrev) && LivePrev.join) {
        mt := MatchToken(t, 1, DevaMaps[LiveProf()])
        if (IsObject(mt) && (mt.ent.kind = "C" || mt.ent.kind = "V")) {
            LiveChunks := LivePrev.chunks.Clone()
            LiveChunks.Push(" ")
            LiveChunks.Push(t)
            LiveEmitted := LivePrev.emitted " "
            LivePrev := ""
            LiveSp := false
            LiveSync()
            return
        }
    }
    LiveChunks.Push(t)
    LivePrev := ""
    LiveSp := false
    LiveSync()
}

LiveLetter(ch, shifted, *) {
    if (shifted != GetKeyState("CapsLock", "T")) {
        ch := StrUpper(ch)
    }
    LiveKeyIn(ch)
}

LiveSpaceKey(*) {
    global LiveChunks, LiveEmitted, LivePrev, LiveSp
    Critical()
    Send("{Space}")
    if (LiveChunks.Length > 0) {
        j := JoinWords && (SubStr(LiveEmitted, -1) == VIRAMA) && StrLen(LiveText()) < 200
        LivePrev := {chunks: LiveChunks, emitted: LiveEmitted, join: j}
        LiveChunks := []
        LiveEmitted := ""
        LiveSp := true
    } else {
        LivePrev := ""
        LiveSp := false
    }
}

LiveBackspaceKey(*) {
    global LiveChunks, LiveEmitted, LivePrev, LiveSp
    Critical()
    if (LiveChunks.Length > 0) {
        LiveChunks.Pop()
        LiveSync()
    } else if (LiveSp && IsObject(LivePrev)) {
        Send("{BS}")
        LiveChunks := LivePrev.chunks
        LiveEmitted := LivePrev.emitted
        LivePrev := ""
        LiveSp := false
    } else {
        Send("{BS}")
        LiveReset()
    }
}

LiveBreak(*) {
    LiveReset()
}

LiveClash(base) {
    for k, v in Active {
        if (StrLower(k) = StrLower(base)) {
            return true
        }
    }
    return false
}

; Taste, die das Zeichen ch erzeugt: {sc, shift} oder "" (haengt vom Tastaturlayout ab)
CharKey(ch) {
    r := DllCall("VkKeyScanW", "UShort", Ord(ch), "Short")
    if (r = -1) {
        return ""
    }
    vk := r & 0xFF
    st := (r >> 8) & 0xFF
    if (st != 0 && st != 1) {
        return ""
    }
    sc := DllCall("MapVirtualKeyW", "UInt", vk, "UInt", 0, "UInt")
    if (sc = 0) {
        return ""
    }
    return {sc: Format("SC{:03X}", sc), shift: st}
}

LiveAdd(name, fn) {
    global LiveHks
    if (SubStr(name, 1, 1) = "~" && LiveClash(SubStr(name, 2))) {
        return
    }
    try {
        Hotkey(name, fn, "On")
        LiveHks.Push(name)
    }
}

LiveRegister() {
    global LiveHks
    LiveUnregister()
    Loop 26 {
        ch := Chr(96 + A_Index)
        LiveAdd("$" ch, LiveLetter.Bind(ch, false))
        LiveAdd("$+" ch, LiveLetter.Bind(ch, true))
        for pre in ["~^", "~#", "~<^>!", "~<^>!+"] {
            LiveAdd(pre ch, LiveBreak)
        }
    }
    Loop 10 {
        d := String(A_Index - 1)
        LiveAdd("$" d, LiveLetter.Bind(d, false))
        for pre in ["~+", "~^", "~#", "~<^>!", "~<^>!+"] {
            LiveAdd(pre d, LiveBreak)
        }
    }
    ; Punkt und Apostroph ueber Scancode, damit sie nicht mit den ~SC-Eintraegen unten kollidieren
    special := []
    for ch in [".", "'"] {
        k := CharKey(ch)
        if (IsObject(k)) {
            LiveAdd((k.shift ? "$+" : "$") k.sc, LiveLetter.Bind(ch, false))
            special.Push(k)
        }
    }
    LiveAdd("$Space", LiveSpaceKey)
    LiveAdd("$BS", LiveBackspaceKey)
    LiveAdd("~+Space", LiveBreak)
    LiveAdd("~^BS", LiveBreak)
    for nm in ["Enter", "NumpadEnter", "Tab", "Esc", "Left", "Right", "Up", "Down", "Home", "End", "PgUp", "PgDn", "Delete", "Insert", "LButton", "RButton", "MButton", "NumpadDot", "NumpadAdd", "NumpadSub", "NumpadMult", "NumpadDiv"] {
        LiveAdd("~" nm, LiveBreak)
    }
    Loop 10 {
        nd := String(A_Index - 1)
        LiveAdd("~Numpad" nd, LiveBreak)
    }
    Loop 12 {
        LiveAdd("~F" A_Index, LiveBreak)
    }
    for sc in ["SC00C", "SC00D", "SC01A", "SC01B", "SC027", "SC028", "SC029", "SC02B", "SC033", "SC034", "SC035", "SC056"] {
        for pre in ["~", "~+", "~<^>!", "~<^>!+"] {
            skip := false
            for k in special {
                if (sc = k.sc && ((pre = "~" && !k.shift) || (pre = "~+" && k.shift))) {
                    skip := true
                }
            }
            if (skip) {
                continue
            }
            LiveAdd(pre sc, LiveBreak)
        }
    }
    return ""
}

LiveUnregister() {
    global LiveHks
    for nm in LiveHks {
        try {
            Hotkey(nm, "Off")
        }
    }
    LiveHks := []
}

; ================================================================ SCHRIFTART
TibDefaultFont(i, fonts) {
    if (i = 1) {
        return "Microsoft Himalaya"
    }
    pat := (i = 2) ? "i)u.?med|\bume\b|tikrang|dbu.?med" : "i)khyug|gyuk|kyuk|chuk"
    for f in fonts {
        if (RegExMatch(f, pat)) {
            return f
        }
    }
    return "Microsoft Himalaya"
}

LoadTibSettings() {
    global TibStyle
    TibStyle := IniRead(IniFile, "General", "TibStyle", "1")
    if (!RegExMatch(TibStyle, "^[123]$")) {
        TibStyle := 1
    }
    TibStyle := Integer(TibStyle)
    fonts := ""
    for i in [1, 2, 3] {
        f := IniRead(IniFile, "General", "TibFont" i, "")
        if (f = "") {
            if (!IsObject(fonts)) {
                fonts := InstalledFonts()
            }
            f := TibDefaultFont(i, fonts)
        }
        TibFonts[i] := f
        sz := IniRead(IniFile, "General", "TibSize" i, "")
        TibSizes[i] := RegExMatch(sz, "^\d+$") && Integer(sz) >= 6 && Integer(sz) <= 72 ? Integer(sz) : 17
    }
}

; Liste der installierten Schriftfamilien (aus der Registry)
; Schriftfamilie ohne angehaengten Stilnamen ("Qomolangma-Betsu Standard" -> "Qomolangma-Betsu")
FontFam(n) => RegExReplace(Trim(n), "i)\s+(Standard|Normal)$")

InstalledFonts() {
    seen := Map()
    seen.CaseSense := "Off"
    for root in ["HKLM", "HKCU"] {
        try {
            Loop Reg root "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" {
                n := RegExReplace(A_LoopRegName, "\s*\((TrueType|OpenType|All res|VGA res)\)\s*$")
                n := RegExReplace(n, "\s*&.*$")
                Loop 3 {
                    n := RegExReplace(n, "i)\s+(Bold|Italic|Oblique|Regular|Light|Semilight|Semibold|Black|Medium|Thin|ExtraLight|ExtraBold|Condensed|Standard|Normal)$")
                }
                if (n != "") {
                    seen[n] := true
                }
            }
        }
    }
    list := ""
    for n, v in seen {
        list .= n "`n"
    }
    list := Sort(Trim(list, "`n"), "D`n")
    return StrSplit(list, "`n")
}

FontSizeOf(txt) {
    t := Trim(txt)
    if (RegExMatch(t, "^\d+$") && t >= 8 && t <= 40) {
        return Integer(t)
    }
    return 12
}

ShowFontDlg(*) {
    global FontGui, FcLat, FcDev, FcSize, FcDevSize, FcPrevL, FcPrevD, FcTib, FcTibSz, FcPrevT
    global FcTibBtn, FcTibOpen, FcBlocks, FcBtns, FcPos, FcSig, FcMsgReg, FcScrollOn
    if (IsObject(FontGui)) {
        FontGui.Show()
        return
    }
    fonts := InstalledFonts()
    sizes := [8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 24]
    tsizes := [12, 14, 16, 17, 18, 20, 22, 24, 28, 32, 36]
    FontGui := Gui("+0x200000", APP " – " T("Schriftart"))
    FontGui.SetFont("s10", "Segoe UI")
    FcBlocks := []
    FcTib := []
    FcTibSz := []
    FcPrevT := []
    FcPos := 0
    FcSig := ""
    FcTibOpen := false
    FcScrollOn := false
    ; je Abschnitt: Ueberschrift, Schrift, Groesse, Vorschau (Positionen setzt FcLayout)
    defs := [{t: T("Schrift für Transliteration (Buchstaben mit Diakritika wie ā, ḍ, ś):"), f: LatinFont, z: FontSize, zl: sizes, pv: "śṛṅgārabhūṣaṇam ā ī ū ṛ ṝ ḷ ḹ ṃ ḥ ṅ ñ ṭ ḍ ṇ ś ṣ", n: 50, fac: 1.4}
        , {t: T("Schrift für Devanāgarī:"), f: DevaFont, z: DevaSize, zl: sizes, pv: "शृङ्गारभूषणम् आ ई ऊ ऋ ॠ ऌ ॡ अं अः ङ ञ ट ड ण श ष", n: 45, fac: 1.7}]
    for i, lbl in [T("Schrift für Tibetisch: Uchen (dbu can)"), T("Schrift für Tibetisch: Ume (dbu med)"), T("Schrift für Tibetisch: Khyuyig ('khyug yig)")] {
        defs.Push({t: lbl, f: TibFonts[i], z: TibSizes[i], zl: tsizes, pv: "རིག་པ། རྫོགས་ཆེན། དཀྱིལ་འཁོར།", n: 30, fac: 2.2})
    }
    FcBtns := []
    for k, d in defs {
        if (k = 3) {
            FcBtns.Push(FontGui.Add("Button", "w120 Default", T("Übernehmen")))
            FcBtns.Push(FontGui.Add("Button", "w120", T("Standard")))
            FcBtns.Push(FontGui.Add("Button", "w120", T("Schließen")))
            FcBtns[1].OnEvent("Click", FcApply)
            FcBtns[2].OnEvent("Click", FcDefault)
            FcBtns[3].OnEvent("Click", FcClose)
            FcTibBtn := FontGui.Add("Button", "w560", T("▼ Bonus: Tibetisch einblenden"))
            FcTibBtn.OnEvent("Click", FcToggleTib)
        }
        FontGui.SetFont("s10 bold")
        ttl := FontGui.Add("Text", "w560", d.t)
        FontGui.SetFont("s10 norm")
        cmb := FontGui.Add("ComboBox", "w380 r12", fonts)
        cmb.Text := d.f
        cmb.OnEvent("Change", FcRefresh)
        stx := FontGui.Add("Text", , T("Größe:"))
        szc := FontGui.Add("ComboBox", "w70", d.zl)
        szc.Text := String(d.z)
        szc.OnEvent("Change", FcRefresh)
        pv := FontGui.Add("Edit", "w560 r2 ReadOnly -VScroll", d.pv)
        FcBlocks.Push({title: ttl, combo: cmb, szTxt: stx, szCombo: szc, prev: pv, chars: d.n, fac: d.fac})
        if (k = 1) {
            FcLat := cmb
            FcSize := szc
            FcPrevL := pv
        } else if (k = 2) {
            FcDev := cmb
            FcDevSize := szc
            FcPrevD := pv
        } else {
            FcTib.Push(cmb)
            FcTibSz.Push(szc)
            FcPrevT.Push(pv)
        }
    }
    FontGui.OnEvent("Close", FcClose)
    FontGui.OnEvent("Escape", FcClose)
    if (!FcMsgReg) {
        FcMsgReg := true
        OnMessage(0x115, FcOnScroll)
        OnMessage(0x20A, FcOnWheel)
    }
    FcSetTibVisible(false)
    FcRefresh()
    FcLayout(true)
}

FcSetTibVisible(on) {
    for k, b in FcBlocks {
        if (k >= 3) {
            for ctl in [b.title, b.combo, b.szTxt, b.szCombo, b.prev] {
                ctl.Visible := on
            }
        }
    }
}

FcToggleTib(*) {
    global FcTibOpen
    FcTibOpen := !FcTibOpen
    FcSetTibVisible(FcTibOpen)
    FcTibBtn.Text := FcTibOpen ? T("▲ Bonus: Tibetisch ausblenden") : T("▼ Bonus: Tibetisch einblenden")
    FcLayout(true)
}

FcPrevH(b) {
    px := FontSizeOf2(b.szCombo.Text) * 1.333
    lines := Max(1, Ceil(b.chars * 0.5 * px / 540))
    return Round(lines * px * b.fac) + 12
}

; wie FontSizeOf, aber 6..72 zulaessig (Tibetisch)
FontSizeOf2(txt) {
    tx := Trim(txt)
    if (RegExMatch(tx, "^\d+$") && tx >= 6 && tx <= 72) {
        return Integer(tx)
    }
    return 12
}

FcPlace(b, y) {
    b.title.Move(12, y - FcPos, 560)
    y += 24
    b.combo.Move(12, y - FcPos, 380)
    b.szTxt.Move(402, y + 4 - FcPos)
    b.szCombo.Move(447, y - FcPos, 70)
    y += 32
    h := FcPrevH(b)
    b.prev.Move(12, y - FcPos, 560, h)
    return y + h + 14
}

; ordnet alle Elemente von oben nach unten an; bei zu wenig Bildschirmhoehe mit Scrollbalken
FcLayout(force := false) {
    global FcPos, FcSig, FcContentH, FcClientH, FcScrollOn
    sig := FcTibOpen
    for b in FcBlocks {
        sig .= "|" FcPrevH(b)
    }
    if (!force && sig = FcSig) {
        return
    }
    FcSig := sig
    y := 12
    y := FcPlace(FcBlocks[1], y)
    y := FcPlace(FcBlocks[2], y)
    for k, bt in FcBtns {
        bt.Move(12 + (k - 1) * 130, y - FcPos, 120, 28)
    }
    y += 28 + 16
    FcTibBtn.Move(12, y - FcPos, 560, 28)
    y += 28 + 14
    if (FcTibOpen) {
        y := FcPlace(FcBlocks[3], y)
        y := FcPlace(FcBlocks[4], y)
        y := FcPlace(FcBlocks[5], y)
    }
    FcContentH := y
    MonitorGetWorkArea(, &wl, &wt, &wr, &wb)
    availH := wb - wt - 90
    FcClientH := Min(FcContentH, availH)
    FcScrollOn := FcContentH > availH
    maxPos := Max(0, FcContentH - FcClientH)
    if (FcPos > maxPos) {
        d := FcPos - maxPos
        DllCall("ScrollWindow", "Ptr", FontGui.Hwnd, "Int", 0, "Int", d, "Ptr", 0, "Ptr", 0)
        FcPos := maxPos
    }
    DllCall("ShowScrollBar", "Ptr", FontGui.Hwnd, "Int", 1, "Int", FcScrollOn ? 1 : 0)
    FontGui.Show("w584 h" FcClientH)
    FcSetScroll()
    ; Fenster nicht ueber den unteren Rand hinaus
    FontGui.GetPos(&gx, &gy, &gw, &gh)
    if (gy + gh > wb) {
        FontGui.Move(, Max(wt, wb - gh))
    }
}

FcSetScroll() {
    if (!FcScrollOn) {
        return
    }
    si := Buffer(28, 0)
    NumPut("UInt", 28, si, 0)
    NumPut("UInt", 7, si, 4)
    NumPut("Int", 0, si, 8)
    NumPut("Int", FcContentH - 1, si, 12)
    NumPut("UInt", FcClientH, si, 16)
    NumPut("Int", FcPos, si, 20)
    DllCall("SetScrollInfo", "Ptr", FontGui.Hwnd, "Int", 1, "Ptr", si, "Int", 1)
}

FcScrollTo(pos) {
    global FcPos
    maxPos := Max(0, FcContentH - FcClientH)
    pos := Min(Max(pos, 0), maxPos)
    if (pos = FcPos) {
        return
    }
    DllCall("ScrollWindow", "Ptr", FontGui.Hwnd, "Int", 0, "Int", FcPos - pos, "Ptr", 0, "Ptr", 0)
    FcPos := pos
    FcSetScroll()
}

FcOnScroll(wParam, lParam, msg, hwnd) {
    if (!IsObject(FontGui) || hwnd != FontGui.Hwnd || !FcScrollOn) {
        return
    }
    code := wParam & 0xFFFF
    pos := FcPos
    if (code = 0) {
        pos -= 30
    } else if (code = 1) {
        pos += 30
    } else if (code = 2) {
        pos -= FcClientH - 30
    } else if (code = 3) {
        pos += FcClientH - 30
    } else if (code = 4 || code = 5) {
        pos := (wParam >> 16) & 0xFFFF
    } else {
        return 0
    }
    FcScrollTo(pos)
    return 0
}

FcOnWheel(wParam, lParam, msg, hwnd) {
    if (!IsObject(FontGui) || !FcScrollOn) {
        return
    }
    if (DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr") != FontGui.Hwnd) {
        return
    }
    dl := (wParam >> 16) & 0xFFFF
    if (dl > 0x7FFF) {
        dl -= 0x10000
    }
    FcScrollTo(FcPos - Round(dl / 120 * 40))
    return 0
}

FcRefresh(*) {
    FcPrevL.SetFont("s" FontSizeOf(FcSize.Text), FontFam(FcLat.Text))
    FcPrevD.SetFont("s" FontSizeOf(FcDevSize.Text), FontFam(FcDev.Text))
    for i, e in FcPrevT {
        e.SetFont("s" FontSizeOf(FcTibSz[i].Text), FontFam(FcTib[i].Text))
    }
    if (IsObject(FcTibBtn)) {
        FcLayout()
    }
}

FcApply(*) {
    global LatinFont, DevaFont, FontSize, DevaSize
    if (Trim(FcLat.Text) != "") {
        LatinFont := Trim(FcLat.Text)
    }
    if (Trim(FcDev.Text) != "") {
        DevaFont := Trim(FcDev.Text)
    }
    FontSize := FontSizeOf(FcSize.Text)
    DevaSize := FontSizeOf(FcDevSize.Text)
    for i, c in FcTib {
        if (Trim(c.Text) != "") {
            TibFonts[i] := Trim(c.Text)
        }
        TibSizes[i] := FontSizeOf(FcTibSz[i].Text)
        try {
            IniWrite(TibFonts[i], IniFile, "General", "TibFont" i)
            IniWrite(TibSizes[i], IniFile, "General", "TibSize" i)
        }
    }
    try {
        IniWrite(LatinFont, IniFile, "General", "LatinFont")
        IniWrite(DevaFont, IniFile, "General", "DevaFont")
        IniWrite(FontSize, IniFile, "General", "FontSize")
        IniWrite(DevaSize, IniFile, "General", "DevaSize")
    }
    CvApplyFonts()
    FcRefresh()
}

FcDefault(*) {
    FcLat.Text := "Segoe UI"
    FcDev.Text := "Nirmala UI"
    FcSize.Text := "12"
    FcDevSize.Text := "12"
    fonts := InstalledFonts()
    for i, c in FcTib {
        c.Text := TibDefaultFont(i, fonts)
        FcTibSz[i].Text := "17"
    }
    FcRefresh()
}

FcClose(*) {
    global FontGui
    if (IsObject(FontGui)) {
        FontGui.Destroy()
    }
    FontGui := ""
}

; Schriften des Umwandlungsfensters: Eingabe und Ergebnis je nach Richtung
CvApplyFonts() {
    if (!IsObject(CvGui)) {
        return
    }
    CvSetFont(CvIn, CvFromId(), 0)
    CvSetFont(CvOut, CvToId(), 2)
}

; Tibetische Schrift wird groesser dargestellt (Uebereinander-Stapel sind sonst schlecht lesbar)
CvSetFont(ctrl, id, extra) {
    if (id == TibId) {
        ctrl.SetFont("s" (TibSizes[TibStyle] + extra), FontFam(TibFonts[TibStyle]))
    } else if (id == DevaName) {
        ctrl.SetFont("s" (DevaSize + extra), FontFam(DevaFont))
    } else {
        ctrl.SetFont("s" (FontSize + extra), FontFam(LatinFont))
    }
}

; ================================================================ INFORMATION
InfoText(lang) {
    L := []
    if (lang = "en") {
        L.Push("Concept: Thomas Kintaert (Department of South Asian, Tibetan and Buddhist Studies, University of Vienna)")
        L.Push("Created: October 2026")
        L.Push("")
        L.Push("FUNCTIONS")
        L.Push("- Shortcuts for diacritics, defined per scheme (IAST, ISO 15919 and your own schemes); plus extra shortcuts (e.g. ç or √) that apply in addition to the chosen scheme.")
        L.Push("- Character palette (Ctrl+Alt+Shift+P): small window with your extra characters to click, handy for rarely used characters without a shortcut of their own.")
        L.Push("- Export / Import: save schemes, lists of extra shortcuts and settings as one file (.json), move them to another device or pass them on to others.")
        L.Push("- Converter: IAST, ISO 15919, Harvard-Kyoto, ITRANS, Velthuis, SLP1, layered notation, Devanāgarī.")
        L.Push("- Live mode: write Devanāgarī directly: type the IAST transliteration and Devanāgarī appears at once.")
        L.Push("- Clean up text: Unicode normalisation, apostrophes, spaces, hyphens.")
        L.Push("- Additionally (bonus, not Sanskrit): Tibetan. Wylie <-> Tibetan script in the styles Uchen, Ume and Khyuyig.")
        L.Push("")
        L.Push("PRIVACY")
        L.Push("This application runs entirely on your computer. No personal data is collected, stored or transmitted, and no internet connection is needed. Your settings, schemes and extra shortcuts are kept as text files in the data folder (see below).")
        L.Push("")
        L.Push("LICENCE")
        L.Push("Published under CC BY-NC-SA 4.0. The app may be shared and modified (attribution, non-commercial, share-alike). Details: https://creativecommons.org/licenses/by-nc-sa/4.0/")
        L.Push("")
        L.Push("TECHNICAL IMPLEMENTATION")
        L.Push("This application was developed in dialogue with artificial intelligence (Claude Sonnet 5.5). It is written in AutoHotkey v2.")
        L.Push("")
        L.Push("SYSTEMS AND SOURCES")
        L.Push("- IAST: International Alphabet of Sanskrit Transliteration (Geneva Oriental Congress, 1894).")
        L.Push("- ISO 15919: Transliteration of Devanagari and related Indic scripts into Latin characters (2001).")
        L.Push("- Harvard-Kyoto: ASCII scheme from Harvard and Kyoto.")
        L.Push("- ITRANS: Avinash Chopde.   Velthuis: Frans Velthuis (devnag).   SLP1: Sanskrit Library Phonetic Basic (Peter Scharf, Malcolm Hyman).")
        L.Push("- Layered notation: the notation (typing a character from its parts from top to bottom: -a for ā, ~n for ñ, 's for ś) is taken from the 'Sanskrit Writer' of the Sanskrit Research Institute, Auroville (https://sri.auroville.org/projects/sanskrit-writer/).")
        L.Push("- Wylie: Extended Wylie Transliteration Scheme (EWTS) of the Tibetan and Himalayan Library, after Turrell Wylie (1959).")
        L.Push("")
        L.Push("TIBETAN SCRIPT (BONUS)")
        L.Push("Uchen (dbu can), Ume (dbu med) and Khyuyig ('khyug yig) are styles of the same Unicode text: only the font changes. Windows ships Microsoft Himalaya (Uchen); for Ume and Khyuyig install a suitable font and choose it under 'Fonts...'. The font size can be set separately for each style.")
        L.Push("")
        L.Push("DATA")
        L.Push(DataDir)
    } else {
        L.Push("Konzeption: Thomas Kintaert (Institut für Südasien-, Tibet- und Buddhismuskunde [ISTB], Universität Wien)")
        L.Push("Erstellungszeitraum: Oktober 2026")
        L.Push("")
        L.Push("FUNKTIONEN")
        L.Push("- Kürzel für Diakritika, je Schema festgelegt (IAST, ISO 15919 und eigene Schemas); dazu Zusatzkürzel (z. B. ç oder √), die zusätzlich zum gewählten Schema gelten.")
        L.Push("- Zeichenpalette (Strg+Alt+Umschalt+P): kleines Fenster mit Ihren Zusatzzeichen zum Anklicken, praktisch für selten benutzte Zeichen ohne eigenes Kürzel.")
        L.Push("- Export / Import: Schemas, Zusatzkürzellisten und Einstellungen als eine Datei (.json) sichern, auf ein anderes Gerät übertragen oder an andere weitergeben.")
        L.Push("- Umwandlung: IAST, ISO 15919, Harvard-Kyoto, ITRANS, Velthuis, SLP1, Schichtschreibweise, Devanāgarī.")
        L.Push("- Live-Modus: Devanāgarī direkt schreiben: IAST-Umschrift tippen, Devanāgarī erscheint sofort.")
        L.Push("- Text bereinigen: Unicode-Normalisierung, Apostrophe, Leerzeichen, Bindestriche.")
        L.Push("- Zusätzlich (Bonus, kein Sanskrit): Tibetisch. Wylie <-> tibetische Schrift in den Stilen Uchen, Ume und Khyuyig.")
        L.Push("")
        L.Push("DATENSCHUTZ")
        L.Push("Diese Anwendung läuft vollständig lokal auf Ihrem Computer. Es werden keinerlei personenbezogene Daten erfasst, gespeichert oder übertragen, und es wird keine Internetverbindung benötigt. Ihre Einstellungen, Schemas und Zusatzkürzel liegen als Textdateien im Datenordner (siehe unten).")
        L.Push("")
        L.Push("LIZENZ")
        L.Push("Veröffentlicht unter CC BY-NC-SA 4.0. Die App darf geteilt und verändert werden (Namensnennung, nicht-kommerziell, Weitergabe unter gleichen Bedingungen). Details: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de")
        L.Push("")
        L.Push("TECHNISCHE UMSETZUNG")
        L.Push("Diese Anwendung wurde im dialogischen Prozess mit Künstlicher Intelligenz entwickelt (Claude Sonnet 5.5). Sie ist in AutoHotkey v2 geschrieben.")
        L.Push("")
        L.Push("SYSTEME UND QUELLEN")
        L.Push("- IAST: International Alphabet of Sanskrit Transliteration (Orientalistenkongress Genf, 1894).")
        L.Push("- ISO 15919: Transliteration of Devanagari and related Indic scripts into Latin characters (2001).")
        L.Push("- Harvard-Kyoto: ASCII-Schema aus Harvard und Kyoto.")
        L.Push("- ITRANS: Avinash Chopde.   Velthuis: Frans Velthuis (devnag).   SLP1: Sanskrit Library Phonetic Basic (Peter Scharf, Malcolm Hyman).")
        L.Push("- Schichtschreibweise: Die Schreibweise (ein Zeichen von oben nach unten aus seinen Teilen tippen: -a für ā, ~n für ñ, 's für ś) ist dem „Sanskrit Writer“ des Sanskrit Research Institute, Auroville, entnommen (https://sri.auroville.org/projects/sanskrit-writer/).")
        L.Push("- Wylie: Extended Wylie Transliteration Scheme (EWTS) der Tibetan and Himalayan Library, nach Turrell Wylie (1959).")
        L.Push("")
        L.Push("TIBETISCHE SCHRIFT (BONUS)")
        L.Push("Uchen (dbu can), Ume (dbu med) und Khyuyig ('khyug yig) sind Stile desselben Unicode-Textes: es ändert sich nur die Schriftart. Windows bringt Microsoft Himalaya (Uchen) mit; für Ume und Khyuyig eine passende Schrift installieren und unter 'Schriftart...' wählen. Die Schriftgröße lässt sich für jeden Stil getrennt einstellen.")
        L.Push("")
        L.Push("DATEN")
        L.Push(DataDir)
    }
    s := ""
    for i, line in L {
        if (i > 1) {
            s .= "`r`n"
        }
        s .= line
    }
    return s
}

ShowInfo(*) {
    global InfoGui
    if (IsObject(InfoGui)) {
        InfoGui.Show()
        return
    }
    InfoGui := Gui(, APP " – " T("Information"))
    InfoGui.SetFont("s10", "Segoe UI")
    InfoGui.SetFont("s18 bold")
    InfoGui.Add("Text", "w660", APP)
    InfoGui.SetFont("s11 norm")
    InfoGui.Add("Text", "xm w660", T("Version") " " AppVersion)
    InfoGui.SetFont("s10 norm")
    ied := InfoGui.Add("Edit", "xm r18 w660 ReadOnly VScroll", InfoText(Lang))
    InfoGui.Add("Button", "xm w150", T("Anleitung öffnen")).OnEvent("Click", (*) => ShowHelp(false))
    InfoGui.Add("Button", "x+10 w190", T("Datenordner öffnen")).OnEvent("Click", (*) => Run('explorer.exe "' DataDir '"'))
    iok := InfoGui.Add("Button", "x+10 w100 Default", "OK")
    iok.OnEvent("Click", InfoClose)
    InfoGui.OnEvent("Close", InfoClose)
    InfoGui.OnEvent("Escape", InfoClose)
    InfoGui.Show()
    SendMessage(0xB1, 0, 0, ied)
    iok.Focus()
}

InfoClose(*) {
    global InfoGui
    if (IsObject(InfoGui)) {
        InfoGui.Destroy()
    }
    InfoGui := ""
}

; ====================================================================== HILFE
DefaultLang() => (SubStr(A_Language, 3) = "07" ? "de" : "en")

HelpText(lang) {
    L := []
    if (lang = "en") {
        L.Push("SansTrans – guide")
        L.Push("")
        L.Push("TYPING")
        L.Push("Left Alt + letter gives a special character: Alt+a = ā, Alt+Shift+a = Ā, Alt+n = ṇ, Alt+s = ś and so on. These shortcuts are only defaults; you can choose and change them freely: right-click the ā icon in the notification area of the taskbar > 'Edit shortcuts...'. The shortcuts in use are defined in the selected scheme.")
        L.Push("")
        L.Push("THE ā ICON IN THE NOTIFICATION AREA")
        L.Push("The ā icon is at the bottom right next to the clock, in the notification area of the taskbar. If you cannot see it there, it is hidden and only appears after a click on the small arrow at the edge of the notification area. A right-click on the ā icon opens the menu, a double-click opens the shortcut editor.")
        L.Push("- Name and version: the name and version number are at the very top of the menu; a click on them opens the information window.")
        L.Push("- Sprache / Language: language of menus and windows (Deutsch, English).")
        L.Push("- Pause / Resume (also Ctrl+Alt+F12): switches the shortcuts off; your normal keyboard then works unchanged.")
        L.Push("- Choose scheme: IAST, ISO 15919 or schemes of your own ('New scheme' copies the current one, which you can then change freely). 'Reload scheme' is only needed if you changed the scheme file in a text editor.")
        L.Push("- Extra shortcuts: your own additional shortcuts (e.g. √, ç), organised in lists of extra shortcuts. Tick the lists you want; they apply together with the chosen scheme (IAST, ISO 15919 or your own). 'Edit extra shortcuts...' and 'New list of extra shortcuts...' are in the same submenu.")
        L.Push("- Character palette: Ctrl+Alt+Shift+P or the menu item 'Character palette' opens a small window with the characters of your switched-on lists of extra shortcuts. One click inserts the character where the cursor is. When editing extra shortcuts you decide per character whether it appears in the palette (default: yes). Without the tick a shortcut is required. If a character is to appear only in the palette, leave the key field empty. “keep open” leaves the window open so that you can enter several characters.")
        L.Push("- Export / Import: in the submenu “Export / Import” choose “Export...” and tick what goes into the file: schemes, lists of extra shortcuts and settings (arranged by topic, e.g. language, fonts, the app's shortcuts). At first only Own_scheme and Own_shortcuts are ticked. Tick fonts only if they are also installed on the device where the file will be used. The file can be read in with “Import...” on another device where SansTrans is also running, or by other people; there too you tick what is taken over. If a name already exists, SansTrans asks: overwrite, new name or skip. SansTrans restarts automatically after the import. Only import files from a trusted source.")
        L.Push("- Start with Windows: start automatically with Windows.")
        L.Push("")
        L.Push("CONVERTING")
        L.Push("- Select text, then Ctrl+Alt+Shift+D: transliteration > Devanāgarī. Ctrl+Alt+Shift+I: Devanāgarī > transliteration. The transliteration system for these two shortcuts is chosen in the right-click menu.")
        L.Push("- 'Converter (window)': choose a system for 'From' and for 'To', paste text, copy the result. Systems: IAST, ISO 15919, Harvard-Kyoto, ITRANS, Velthuis, SLP1, layered notation, Devanāgarī, and Wylie (Tibetan) <> Tibetan script. Wylie can only be converted into Tibetan script and the other way round. '↔ Swap' exchanges From and To and makes the result the new input.")
        L.Push("- Tibetan script (bonus): Uchen (dbu can), Ume (dbu med) and Khyuyig ('khyug yig) are styles of the same text: only the font changes (choose the fonts under 'Fonts...').")
        L.Push("- Layered notation: a character is typed from its parts, from top to bottom: ā = -a, ṭ = t., ṝ = -r., ś = 's, ṅ = .n, ñ = ~n etc. If a full stop, hyphen, tilde or apostrophe is meant literally and should not be read as part of a character, put a backslash before it: \. \- \~ \'")
        L.Push("- 'Converter options': full stop = daṇḍa; join a word-final consonant with the beginning of the next word (before a consonant or a vowel the virāma and the space disappear: tat sukham asti. > तत्सुखमस्ति।).")
        L.Push("")
        L.Push("LIVE MODE")
        L.Push("Ctrl+Alt+Shift+L or the menu item 'Live mode' in the right-click menu: Devanāgarī is written directly. You type the IAST transliteration on the keyboard (with your shortcuts), and Devanāgarī appears at once in the program. Press the same keys to switch it off. A full stop gives a daṇḍa (two give a double daṇḍa), ' or ’ gives the avagraha ऽ. While a word is being typed a virāma may show up briefly and disappears with the next letter. Mouse clicks, arrow keys, Enter and Tab start a new word. It may not work equally well in every program; if in doubt, select the text and use Ctrl+Alt+Shift+D. Live mode works with IAST (or ISO 15919 if chosen) and is always off at start-up.")
        L.Push("")
        L.Push("CLEAN UP TEXT")
        L.Push("Select text, then Ctrl+Alt+Shift+B (or 'Clean up text (window)'): unifies the Unicode representation (e.g. ā is stored as one single character instead of “a” plus a separate macron), unifies apostrophes to ’, turns '..' into '.', removes surplus spaces and invisible characters, joins words split by a hyphen at the end of a line; optionally removes all hyphens between letters. Each step can be switched on or off in the window.")
        L.Push("")
        L.Push("FONTS")
        L.Push("'Fonts...': choose font and size for transliteration and for Devanāgarī separately, each with a preview directly below (useful if diacritics look uneven). Tibetan (bonus, not Sanskrit) can be unfolded at the bottom.")
        L.Push("")
        L.Push("INFORMATION / DATA")
        L.Push("'About...' (or a click on the version line at the very top of the menu): version, sources, data folder. Data: %AppData%\SansTrans (schemes as text files, settings.ini).")
    } else {
        L.Push("SansTrans – Anleitung")
        L.Push("")
        L.Push("TIPPEN")
        L.Push("Linke Alt-Taste + Buchstabe ergibt ein Sonderzeichen: Alt+a = ā, Alt+Umschalt+a = Ā, Alt+n = ṇ, Alt+s = ś usw. Diese Kürzel sind nur Voreinstellungen; Sie können sie frei wählen und ändern: Rechtsklick auf das ā-Symbol im Infobereich der Taskleiste > 'Kürzel bearbeiten...'. Welche Kürzel gelten, steht im gewählten Schema.")
        L.Push("")
        L.Push("DAS ā-SYMBOL IM INFOBEREICH")
        L.Push("Das ā-Symbol befindet sich unten rechts neben der Uhr, im Infobereich der Taskleiste. Ist es dort nicht zu sehen, ist es ausgeblendet und erscheint erst nach einem Klick auf das kleine Pfeilsymbol am Rand des Infobereichs. Rechtsklick auf das ā-Symbol öffnet das Menü, Doppelklick den Kürzel-Editor.")
        L.Push("- Name und Version: Ganz oben im Menü stehen der Name und die Versionsnummer; ein Klick darauf öffnet das Informationsfenster.")
        L.Push("- Sprache / Language: Sprache der Menüs und Fenster (Deutsch, English).")
        L.Push("- Pausieren / Fortsetzen (auch Strg+Alt+F12): schaltet die Kürzel ab; die normale Tastatur funktioniert dann unverändert.")
        L.Push("- Schema wählen: IAST, ISO 15919 oder eigene Schemas ('Neues Schema' kopiert das aktuelle, das Sie dann frei ändern können). 'Schema neu laden' brauchen Sie nur, wenn Sie die Schema-Datei in einem Texteditor geändert haben.")
        L.Push("- Zusatzkürzel: eigene zusätzliche Kürzel (z. B. √, ç), geordnet in Zusatzkürzellisten. Sie haken die gewünschten Listen an; sie gelten gemeinsam mit dem gewählten Schema (IAST, ISO 15919 oder eigenes). 'Zusatzkürzel bearbeiten...' und 'Neue Zusatzkürzelliste...' stehen im selben Untermenü.")
        L.Push("- Zeichenpalette: Strg+Alt+Umschalt+P oder die Wahl des Menüpunkts 'Zeichenpalette' öffnet ein kleines Fenster mit den Zeichen Ihrer eingeschalteten Zusatzkürzellisten. Ein Klick fügt das Zeichen dort ein, wo der Cursor steht. Beim Bearbeiten der Zusatzkürzel legen Sie pro Zeichen fest, ob es in der Zeichenpalette erscheint (Standard: ja). Ohne Haken ist ein Kürzel nötig. Soll ein Zeichen nur in der Palette erscheinen, bleibt das Tastenfeld leer. Mit „offen lassen“ bleibt das Fenster für die Eingabe mehrerer Zeichen geöffnet.")
        L.Push("- Export / Import: Im Untermenü „Export / Import“ wählen Sie „Exportieren...“ und haken an, was in die Datei soll: Schemas, Zusatzkürzellisten und Einstellungen (nach Themen geordnet, z. B. Sprache, Schriften, Tastenkürzel der App). Angehakt sind zunächst nur Own_scheme und Own_shortcuts. Schriften nur anhaken, wenn sie auch auf dem Gerät installiert sind, auf dem die Datei verwendet wird. Die Datei lässt sich auf einem anderen Gerät, auf dem SansTrans ebenfalls läuft, oder von anderen Personen mit „Importieren...“ einlesen; auch dort haken Sie an, was übernommen wird. Gibt es einen Namen bereits, fragt SansTrans: überschreiben, neuer Name oder überspringen. Nach dem Import startet SansTrans automatisch neu. Importieren Sie nur Dateien aus vertrauenswürdiger Quelle.")
        L.Push("- Mit Windows starten: Autostart ein oder aus.")
        L.Push("")
        L.Push("UMWANDLUNG")
        L.Push("- Text markieren, dann Strg+Alt+Umschalt+D: Transliteration > Devanāgarī. Strg+Alt+Umschalt+I: Devanāgarī > Transliteration. Das Transliterationssystem dafür wählen Sie im Rechtsklickmenü.")
        L.Push("- 'Umwandlung (Fenster)': bei 'Von' und 'Nach' jeweils ein System auswählen, Text einfügen, Ergebnis kopieren. Systeme: IAST, ISO 15919, Harvard-Kyoto, ITRANS, Velthuis, SLP1, Schichtschreibweise, Devanāgarī sowie Wylie (Tibetisch) <> tibetische Schrift. Wylie lässt sich nur in tibetische Schrift umwandeln und umgekehrt. '↔ Tauschen' vertauscht Von und Nach; das Ergebnis wird zur neuen Eingabe.")
        L.Push("- Tibetische Schrift (Bonus): Uchen (dbu can), Ume (dbu med) und Khyuyig ('khyug yig) sind Stile desselben Textes: Es ändert sich nur die Schriftart (unter 'Schriftart...' wählbar).")
        L.Push("- Schichtschreibweise: Ein Zeichen wird aus seinen Teilen von oben nach unten getippt: ā = -a, ṭ = t., ṝ = -r., ś = 's, ṅ = .n, ñ = ~n usw. Soll ein Punkt, Bindestrich, eine Tilde oder ein Apostroph wörtlich stehen und nicht als Teil eines Zeichens gelesen werden, setzen Sie davor einen Backslash: \. \- \~ \'")
        L.Push("- 'Umwandlung: Optionen': Punkt = Daṇḍa; auslautende Konsonanten mit dem nächsten Anlaut verbinden (vor Konsonant oder Vokal des nächsten Wortes entfallen Virāma und Leerzeichen: tat sukham asti. > तत्सुखमस्ति।).")
        L.Push("")
        L.Push("LIVE-MODUS")
        L.Push("Strg+Alt+Umschalt+L oder Menüpunkt 'Live-Modus' im Rechtsklickmenü: Devanāgarī wird direkt geschrieben. Sie tippen die IAST-Umschrift auf der Tastatur (mit Ihren Kürzeln), und im Programm erscheint sofort Devanāgarī. Mit denselben Tasten schalten Sie den Modus wieder aus. Ein Punkt ergibt einen Daṇḍa (zwei Punkte einen Doppel-Daṇḍa), ' oder ’ den Avagraha ऽ. Beim Tippen eines Wortes kann kurz ein Virāma erscheinen, der mit dem nächsten Buchstaben wieder verschwindet. Nach Mausklick, Pfeiltasten, Enter oder Tab beginnt ein neues Wort. Nicht in jedem Programm funktioniert das gleich gut; im Zweifel Text markieren und Strg+Alt+Umschalt+D benutzen. Der Live-Modus arbeitet mit IAST (oder ISO 15919, falls gewählt) und ist beim Start immer aus.")
        L.Push("")
        L.Push("TEXT BEREINIGEN")
        L.Push("Text markieren, dann Strg+Alt+Umschalt+B (oder 'Text bereinigen (Fenster)'): vereinheitlicht die Unicode-Darstellung (z. B. wird ā als ein einziges Zeichen gespeichert statt als a plus separatem Längenstrich), vereinheitlicht Apostrophe zu ’, macht aus '..' einen Punkt, entfernt überflüssige Leerzeichen und unsichtbare Zeichen, fügt am Zeilenende getrennte Wörter zusammen; auf Wunsch entfernt es auch alle Bindestriche zwischen Buchstaben. Jeder Schritt lässt sich im Fenster ein- oder ausschalten.")
        L.Push("")
        L.Push("SCHRIFTART")
        L.Push("'Schriftart...': Schrift und Größe für Transliteration und für Devanāgarī getrennt wählen, jeweils mit Vorschau direkt darunter (hilfreich, wenn Diakritika uneinheitlich aussehen). Tibetisch (Bonus, kein Sanskrit) lässt sich unten aufklappen.")
        L.Push("")
        L.Push("INFORMATION / DATEN")
        L.Push("'Information...' (oder Klick auf die Versionszeile ganz oben im Menü): Version, Quellen, Datenordner. Daten: %AppData%\SansTrans (Schemas als Textdateien, settings.ini).")
    }
    s := ""
    for i, line in L {
        if (i > 1) {
            s .= "`r`n"
        }
        s .= line
    }
    return s
}

HelpLangNames() {
    names := []
    for p in HelpLangs {
        names.Push(p[2])
    }
    return names
}

HelpLangIndex() {
    for i, p in HelpLangs {
        if (p[1] = Lang) {
            return i
        }
    }
    return 1
}

SaveLang() {
    try {
        IniWrite(Lang, IniFile, "General", "Lang")
    }
}

; Sprachwahl beim ersten Start
ChooseLang() {
    global Lang
    Lang := DefaultLang()
    g := Gui("+AlwaysOnTop", APP)
    g.SetFont("s11", "Segoe UI")
    g.Add("Text", , "Sprache der Hilfe / Language of the help:")
    dd := g.Add("DropDownList", "w240 Choose" HelpLangIndex(), HelpLangNames())
    ok := g.Add("Button", "w100 Default", "OK")
    ok.OnEvent("Click", ChooseLangOk.Bind(g, dd))
    g.OnEvent("Close", ChooseLangOk.Bind(g, dd))
    g.Show()
    WinWaitClose("ahk_id " g.Hwnd)
}

ChooseLangOk(g, dd, *) {
    global Lang
    if (dd.Value >= 1 && dd.Value <= HelpLangs.Length) {
        Lang := HelpLangs[dd.Value][1]
    }
    SaveLang()
    g.Destroy()
}

ShowHelp(modal := false) {
    global HelpGui, HelpEd
    if (IsObject(HelpGui)) {
        HelpGui.Show()
        return
    }
    HelpGui := Gui(, APP " – " T("Anleitung"))
    HelpGui.SetFont("s10", FontFam(LatinFont))
    HelpEd := HelpGui.Add("Edit", "r24 w760 ReadOnly VScroll", HelpText(Lang))
    hok := HelpGui.Add("Button", "xm w120 Default", "OK")
    hok.OnEvent("Click", HelpClose)
    HelpGui.OnEvent("Close", HelpClose)
    HelpGui.OnEvent("Escape", HelpClose)
    HelpGui.Show()
    SendMessage(0xB1, 0, 0, HelpEd)
    hok.Focus()
    if (modal) {
        WinWaitClose("ahk_id " HelpGui.Hwnd)
    }
}

HelpClose(*) {
    global HelpGui
    if (IsObject(HelpGui)) {
        HelpGui.Destroy()
    }
    HelpGui := ""
}
