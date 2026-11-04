# GearHunt – Design-Guidelines

**Stand:** 4. November 2026  
**Status:** Visuelle Leitlinien aus Referenzanalyse und Design-Q&A. Ergänzt [GameSpec.md](GameSpec.md), Abschnitt 1.1 und 1.9.

Diese Datei legt fest, wie GearHunt aussehen soll. Sie beschreibt das Ziel, nicht den Stand des Prototyps. Bestätigte Entscheidungen, Vorschläge und offene Punkte werden wie in der GameSpec getrennt geführt. Hex-Werte und Messwerte sind Richtwerte für Konzept, Shader und Abnahme. Sie sind keine starren Vorgaben.

---

## 0. Referenzen und Abgrenzung

GearHunt nutzt zwei Vorbilder für jeweils andere Bereiche:

| Bereich | Vorbild | Was übernommen wird |
| --- | --- | --- |
| Grafikqualität, Rendertechnik, Kamera, Lesbarkeit, HUD-Layout | **Ravenswatch** (Passtech Games) | Illustrativer Comic-Look mit Cel-Shading und Outlines, steile feste Kamera, strenge Farbhierarchie im Kampf, Telegraphs, HUD-Anordnung |
| Farbpalette, Licht, Weltgefühl, Setting | **Sacred 2: Fallen Angel** (Ascaron) | Warme Erdtöne, sattes Grün, Cyan-/Blau-Magie, helle und lebendige Tagstimmung, klassische High-Fantasy wie in Ancaria |

**Nicht übernommen wird:**

- die Märchen- und Albtraum-Welt von Ravenswatch, also Reverie, Nightmares und Märchenhelden
- die sehr dunkle Gesamtstimmung von Ravenswatch: In der Analyse der Steam-Screenshots sind rund 72 % der Pixel fast schwarz.
- der semi-realistische Texturstil und die drehbare Kamera von Sacred 2
- der Tag/Nacht-Zyklus aus beiden Spielen (siehe 4.4)

**Kurzformel:** *Ravenswatch-Technik und -Lesbarkeit, gefüllt mit der Farbe und Welt von Sacred 2.*

---

## 1. Leitprinzipien

1. **Jeder Screenshot soll wie ein kolorierter Comic-Panel wirken.** Das ist der Kompass, analog zu Ravenswatchs Ziel: „Make a screenshot look like it could have been hand-drawn.“
2. **Lesbarkeit vor Detail.** Auch bei vier Spielern und vielen Gegnern muss jederzeit erkennbar sein, wo die eigene Figur steht, was gefährlich ist und was aufsammelbar ist.
3. **Wertehierarchie vor Farbhierarchie.** Figuren, Gefahren und Interaktives heben sich zuerst über Helligkeitskontrast vom Boden ab und erst danach über Farbe.
4. **Sättigung ist ein Budget.** Die Umgebung bleibt vergleichsweise ruhig. Hohe Sättigung ist für Figuren, VFX, Telegraphs und Loot reserviert.
5. **Lebendige Welt, dunkle Momente.** Grundton ist hell, warm und einladend wie in Sacred 2. Höhlen, Lava, Bossarenen und verderbte Orte setzen bewusst dunkle Kontraste.
6. **Klare Formsprache.** Große, gut lesbare Grundformen kommen vor Kleinteiligkeit. Details sitzen in Linien und Texturen, nicht in der Geometrie.

---

## 2. Kamera und Perspektive (bestätigt)

- **Fest und steil:** Neigung etwa **55°**. Es gibt keine freie Rotation.
- **Perspektivische Kamera mit engem Sichtfeld** (Richtwert 30–40° FOV). Sie erzeugt leichte Tiefenwirkung bei wenig Verzerrung. Die 2,5D-Wirkung entsteht durch Höhe, Licht und Schatten, nicht durch Kamerabewegung.
- **Dynamischer Zoom nach Spielerabstand:** Im lokalen Koop zoomt die gemeinsame Kamera heraus, wenn Spieler auseinanderlaufen, und wieder heran, wenn sie zusammenkommen. Minimaler und maximaler Zoom sowie das Verhalten an der Grenze sind offen (vgl. GameSpec 1.4 „Kameragrenzen“).
- **Verdeckung:** Hohe Objekte wie Bäume, Mauern oder Dächer, die Figuren verdecken, werden ausgeblendet oder transparent. Figuren hinter Verdeckungen erhalten eine Silhouette in Spieler- oder Gegnerfarbe.
- Spielrelevante Fläche ist immer der Boden. Höhe ist reine Darstellung (vgl. GameSpec 1.1).

---

## 3. Render-Stil: Cel-Shading und Outlines (bestätigt)

### 3.1 Linien

| Element | Outline | Richtwert |
| --- | --- | --- |
| Spielerfiguren | kräftig, durchgehend | dickste Linie im Bild |
| Gegner, Bosse | kräftig | etwas dünner als Spieler; Bosse so dick wie Spieler |
| Interaktives (Truhen, Portal, Shop, Loot) | mittel | klar sichtbar |
| Umgebung (Felsen, Mauern, Bäume) | dünner, teils unterbrochen | wie mit Tusche skizziert |
| Bodenflächen | keine Kontur, nur gezeichnete Strichdetails | Grasbüschel, Risse, Fugen |

- **Linienfarbe:** sehr dunkel, aber **farbig getönt statt reinem Schwarz** (z. B. `#1E1611` warmes Dunkelbraun in Tag-Biomen, `#0F1420` Nachtblau in dunklen Biomen). So bleibt das Bild trotz Comic-Linien farbig im Sinne von Sacred 2.
- Linien bleiben bei jedem Zoom optisch etwa gleich dick (bildschirmbezogen, nicht weltbezogen).

### 3.2 Shading

- **2–3 harte Lichtbänder** (Licht, Halbton, Schatten) statt weicher Verläufe.
- **Harte Schlagschatten** am Boden. Sie verankern Figuren und Objekte und tragen viel zur 2,5D-Tiefe bei.
- **Rim-Light** an Figuren in der Spieler- oder Gegnerfarbe trennt sie zusätzlich vom Untergrund.
- **Schraffur und Strichtexturen** in Schattenbereichen und auf großen Flächen, sparsam dosiert.
- **Texturen sind gemalt und flächig**, mit großen Farbfeldern und wenig Rauschen. Kein PBR-Glanz, keine Fototexturen.

### 3.3 Material

- Metall und Edelsteine dürfen einen harten Glanzpunkt bekommen, aber keine realistischen Reflexionen.
- Magie-Kristalle (siehe Palette „Magie“) leuchten selbst und sind lokale Lichtquellen.

---

## 4. Farbe und Licht

### 4.1 Grundpalette (abgeleitet aus Sacred 2)

Die Werte stammen aus einer Farbquantisierung der Steam-Screenshots von *Sacred 2 Gold* und *Sacred 2 Remaster*. Für Cel-Shading wurden sie leicht vereinfacht.

| Gruppe | Farben | Verwendung |
| --- | --- | --- |
| Erde / Wege | `#E3C177` Sand · `#C0B686` Khaki · `#8C693F` Ocker · `#754828` Braun · `#542616` Rotbraun | Wege, Felsen, Holz, Lehm, Dörfer |
| Vegetation | `#7BA866` Hellgrün · `#759360` Wiesengrün · `#62844C` Laubgrün · `#626733` Oliv · `#4A6754` Moos | Gras, Laub, Dschungel |
| Schatten / Tiefe | `#363F35` Waldschatten · `#28292A` Anthrazit · `#151D21` Nachtblau · `#271710` Tiefbraun | Schattenbänder, dunkle Biome, Linien |
| Magie / Akzent | `#3FD0F0` Kristall-Cyan · `#2A6FD8` Arkanblau | Magie-Kristalle, Runen, Portale (siehe 7 für Konflikte) |
| Licht | `#FFE3A3` Sonnenlicht · `#FFB45A` Fackellicht | Hauptlicht in Tag-Biomen, lokale Lichter |

### 4.2 Helligkeitsziele (bestätigt: Mittelweg)

| Stimmung | Einsatz | Ø-Helligkeit (HSV-V, Richtwert) | Charakter |
| --- | --- | --- | --- |
| **Hell** | Tag-Biome (Wald, Dschungel, Eis, Wiesen, Dörfer) | 0,30–0,40 | warm, sonnig, farbig wie Sacred 2 |
| **Dunkel** | Höhlen, Lava, Krypten, verderbte Orte, Bossarenen | 0,15–0,22 | Dunkelheit mit starken Licht-Akzenten wie Ravenswatch |

Vergleich der Referenzen: Ravenswatch hat eine Ø-Helligkeit von 0,17, Sacred 2 Gold 0,34 und Sacred 2 Remaster 0,40. Die Werte lassen sich mit einem Screenshot-Analyseskript gegen fertige Szenen prüfen.

### 4.3 Licht

- **Ein festes Hauptlicht pro Stage** (Sonne oder Mondlicht), leicht seitlich, damit Schlagschatten schräg und gut lesbar fallen.
- **Lokale Lichtquellen** wie Fackeln, Kristalle, Lava und Zauber sind in dunklen Biomen das wichtigste Gestaltungsmittel. Sie lenken den Blick und markieren Wege.
- **Atmosphäre:** leichter, farbiger Höhendunst (Tag: warmes Gold, dunkel: Blau oder Violett). Eine sanfte Vignette ist erlaubt, Bloom nur auf Licht und VFX.
- Lichtblitze und Bildschirm-Tönung dienen nur als Feedback (Treffer, Boss-Phase), nicht als Dauerzustand.

### 4.4 Tageszeit (bestätigt)

- **Kein Tag/Nacht-Zyklus.** Tageszeit und Stimmung sind **fest pro Stage bzw. Biom** und werden mit der Stage generiert oder vom Biom vorgegeben.
- Variation über Runs entsteht durch Biom-Varianten wie „Wald – Mittag“ oder „Wald – Abenddämmerung“, nicht durch Zeitablauf innerhalb einer Stage.

---

## 5. Biome (Vorschlag, Katalog laut GameSpec offen)

| Biom | Stimmung | Dominante Farben | Akzent / Licht | Dunkle Momente |
| --- | --- | --- | --- | --- |
| Wald | hell, Mittag | Laubgrün, Ocker, Sand | Sonnenflecken, Cyan-Kristalle | Lichtungen mit Ruinen, dichtes Unterholz |
| Dschungel | hell, feucht, gesättigter | Hellgrün, Oliv, Moos | Blüten in Pink/Violett (sparsam), Wasser-Cyan | Tempelruinen, Höhleneingänge |
| Eis | hell, kühl | Weißblau, helles Grau, Arkanblau | Kristall-Cyan, kaltes Licht | Gletscherhöhlen |
| Lava | dunkel | Anthrazit, Tiefbraun, Rotbraun | Glut-Orange als Bodenlicht | durchgehend |

**Regel für Lava:** Gegnergefahr ist rot/orange codiert (siehe 7). Lava muss deshalb **heller und gelblicher** wirken (`#FFB45A`–`#FFE3A3`) als Gegner-Telegraphs. Telegraphs erhalten im Lava-Biom zusätzlich eine helle Kontur.

---

## 6. Figuren

### 6.1 Proportionen (bestätigt)

- **Leicht heroisch überzeichnet:** große Waffen, Hände und Schultern, kräftige Grundformen wie bei Ravenswatch.
- **Silhouette zuerst:** Jede Klasse und jeder Gegnertyp muss allein an der schwarzen Silhouette aus der Spielkamera erkennbar sein.
- Köpfe und Waffen sind leicht vergrößert, weil sie aus der steilen Kamera die wichtigsten Erkennungsmerkmale sind.

### 6.2 Klassenidentität (Vorschlag)

Klassenfarben dürfen weder Rot/Orange (Gegnergefahr), Grün (Heilung) noch Gelb/Gold (Loot) sein.

| Klasse | Silhouette | Klassenfarbe (Vorschlag) |
| --- | --- | --- |
| Krieger | breit, massig, große Zweihandwaffe | Stahlblau `#5B8FD9` |
| Jäger | schlank, Bogen/Kapuze, asymmetrisch | Türkis `#2FC4B2` |
| Magier | Robe, Stab, spitze Kopfform | Violett `#9B6BFF` |
| Paladin | Plattenrüstung, Schild, aufrecht | Elfenbein-Himmelblau `#DDEBFF` |

- Klassenfarbe = Rim-Light, Fähigkeits-VFX, Spielermarker und HUD-Akzent.
- Im Koop zeigt jede Figur zusätzlich einen **Spielerring am Boden** in einer Spielerfarbe, damit zwei Spieler derselben Klasse unterscheidbar bleiben.

### 6.3 Gegner und Bosse

- Gegner tragen eher gedämpfte, erdige oder kalte Farben. Ihre **Angriffe** sind rot/orange.
- Bosse sind deutlich größer als normale Gegner, bekommen eine eigene Lichtquelle oder Aura und eine Arena mit dunkler Stimmung.
- Rare-Camp-Gegner erhalten eine sichtbare Markierung wie eine Aura oder ein Abzeichen, nicht nur andere Werte.

---

## 7. Kampf-Lesbarkeit und VFX (bestätigt: feste Farbcodierung)

| Bedeutung | Farbe | Regel |
| --- | --- | --- |
| **Gegnergefahr** | Rot / Orange | Ausschließlich für Gegnerangriffe, Telegraphs und gegnerische Projektile |
| **Spieler-Effekte** | Klassenfarbe | Eigene Fähigkeiten, Projektile und Auren |
| **Heilung** | Grün | Heilung, Wiederbeleben, Regeneration |
| **Loot / Gold** | Gelb / Gold | Gold, Materialien, Beute-Hinweise |

- **Telegraphs** sind Bodenflächen mit heller Kontur und einer Füllung, die sich bis zum Einschlag auflädt, wie in Ravenswatch. Die Form entspricht exakt der Trefferzone.
- **Ebenen-Hierarchie (von oben nach unten):** Gegner-Telegraphs → eigene Figur → Mitspieler → Gegner → eigene VFX → Mitspieler-VFX (abgeschwächt) → Umgebung.
- **Mitspieler-VFX werden abgeschwächt** dargestellt (weniger Deckkraft und Bloom), damit Gefahren auch im Vier-Spieler-Chaos erkennbar bleiben.
- **Formsprache:** Gegner-Effekte eher kantig und zackig, Spieler-Effekte eher rund und fließend.
- Schadenszahlen, Krit-Feedback und Treffer-Tönung sind kurz und klar und verdecken keine Telegraphs.

---

## 8. Loot und Interaktion

- Beute auf dem Boden erhält einen **Lichtstrahl oder Schimmer in Seltenheitsfarbe** (Weiß, Grün, Lila laut GameSpec 1.7) und ein Label.
- Gold und Materialien werden gelb/gold hervorgehoben und mit einem kurzen Sammeleffekt aufgenommen.
- Interaktive Objekte wie Portal, Shop und Truhen erhalten eine Outline mittlerer Stärke und bei Nähe einen Hervorhebungsimpuls.
- Das **Portal** ist nach dem Boss-Sieg weithin sichtbar, z. B. als Lichtsäule in Kristall-Cyan.

---

## 9. UI / HUD (bestätigt)

**Layout wie Ravenswatch, Optik als Fantasy-Ornamentik:**

- **Unten:** Leiste mit Lebensbalken, Ressource, Run-Level und EXP sowie Grundangriff, den 2 aktiven Fähigkeiten und der passiven Fähigkeit mit Abklingzeiten.
- **Rechts unten:** Minimap mit Boss-, Portal-, Camp- und Shop-Symbolen.
- **Rechts oben:** Ziel- und Statushinweise, z. B. Boss besiegt oder Portalabstimmung.
- **Lokaler Koop:** Jeder lokale Spieler erhält ein eigenes kompaktes Panel in seiner Spielerfarbe. Die genaue Anordnung ist offen.
- **Optik:** Rahmen aus Gold und dunklem Holz, Hintergründe wie Pergament oder Leder, Seltenheits-Rahmen für Items. Talent- und Upgrade-Auswahl als ornamentierte Karten.
- **Lesbarkeit:** Icons mit klarer Silhouette und hohem Kontrast. Tooltips erklären Fachbegriffe wie Zustände und Statuseffekte direkt. Mehrere Ravenswatch-Reviews kritisieren fehlende Erklärungen genau an dieser Stelle.
- UI-Texte laufen über `tr()` (siehe CLAUDE.md).

---

## 10. Technische Konsequenzen (offen, gesondert zu entscheiden)

Diese Punkte widersprechen dem aktuellen Prototyp oder müssen vor der Umsetzung entschieden werden:

1. **Renderer:** Das Projekt nutzt laut `docs/ARCHITECTURE.md` bewusst den Compatibility-Renderer, um ältere PCs zu unterstützen. Cel-Shading, Outlines und lokale Lichter auf Ravenswatch-Niveau sind dort mit eigenen Shadern (z. B. Inverted-Hull-Outlines) möglich, aber eingeschränkt. Zu entscheiden ist, ob Forward+ eingesetzt wird oder ob Compatibility mit reduziertem Licht- und Schattenumfang bleibt.
2. **2D → 2,5D:** Der Prototyp basiert auf 2D-Shadern (`creature.gdshader`, Biom-Shader, `EntityBatch` mit MultiMesh). Für 3D-Figuren und 3D-Umgebung müssen Darstellung und Batching neu konzipiert werden. Die Simulation in `src/sim` bleibt unberührt.
3. **Schrift:** Aktuell ist *Fredoka* hinterlegt, eine runde und verspielte Schrift. Sie passt nicht zur Fantasy-Ornamentik. Gesucht wird eine lesbare Fantasy-Serif oder Kapitälchen-Schrift für Titel plus eine klare Schrift für Fließtext und Zahlen, jeweils mit OFL-Lizenz.
4. **Asset-Pipeline:** Woher 3D-Modelle, Animationen und gemalte Texturen kommen, ist offen (selbst erstellt, Asset-Packs oder generiert), ebenso wie sie per Vibe-Coding ohne Editor-Handarbeit eingebunden werden.

---

## 11. Offene Punkte

- **Konflikt Grün:** Heilung ist grün, und auch die Seltenheit „Grün“ ist grün. Vorschlag: Seltenheit durch Blau ersetzen (Weiß, Blau, Lila) oder Heilung klar als hellgrüne Partikel und Seltenheit nur in Lootstrahl und Rahmen verwenden.
- **Konflikt Violett:** Die Klassenfarbe Magier ist Violett, und auch die Seltenheit „Lila“ ist violett. Das ist unkritisch, solange die Seltenheit nur an Items erscheint. Bei Bedarf prüfen.
- Klassenfarben und Spielerfarben für den Koop bestätigen.
- Endgültiger Biomkatalog und Stimmungsvarianten pro Biom.
- Kamera-Zoomgrenzen und Verhalten bei zu großem Spielerabstand.
- Outline-Stärken als konkrete Pixelwerte, sobald erste Szenen existieren.

---

## 12. Quellen und Analyse

- Passtech Games: [Ravenswatch Artstation Blast](https://www.passtechgames.com/ravenswatch-news/ravenswatch-artstation-blast/) mit Statement von Art Director Valentin André-Terramorsi.
- Reviews und Previews zu Ravenswatch (Niche Gamer, CGMagazine, Techstomper, Legacy Gaming): dicke Outlines, Comic-Look, Cel-Shading sowie UI-Kritik an fehlenden Erklärungen.
- Worthplaying, *Sacred 2: Fallen Angel* Preview (2008): farbige Mittagspalette, fackelbeleuchtete Nacht, Licht und Farbe ohne Verlust an Übersicht.
- Eigene Analyse der offiziellen Steam-Screenshots (Ravenswatch: 10, Sacred 2 Gold: 11, Sacred 2 Remaster: 6) mit Helligkeit, Sättigung, Farbtonverteilung und Median-Cut-Palette.

| Messwert | Ravenswatch | Sacred 2 Gold | Sacred 2 Remaster |
| --- | --- | --- | --- |
| Ø-Helligkeit (V) | 0,17 | 0,34 | 0,40 |
| Ø-Sättigung (S) | 0,33 | 0,52 | 0,44 |
| Anteil sehr dunkler Pixel (V < 0,2) | 72 % | 32 % | 9 % |
| Anteil stark gesättigter Pixel (S > 0,6, V > 0,4) | 3 % | 17 % | 11 % |
