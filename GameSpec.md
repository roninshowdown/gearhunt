# GearHunt – GameSpec

**Stand:** 4. November 2026  
**Status:** Laufender Game-Design-Arbeitsstand aus der gemeinsamen Themen-Q&A.

Diese Datei sichert die bislang bestätigte Spieldefinition. Sie beschreibt das gewünschte Spiel und ist kein Nachweis, dass die beschriebenen Systeme bereits implementiert sind. Bestätigte Entscheidungen, unbestätigte Vorschläge und offene Fragen sind getrennt. Bei späteren Designrunden wird dieser Stand gezielt fortgeschrieben.

## 1. Bestätigte Spieldefinition

### 1.1 Grundidee und Darstellung

GearHunt ist ein Fantasy-Roguelike mit reiner 2D-Top-down-Darstellung und einer potenziell unbegrenzten Folge prozedural generierter Stages. Der Schwerpunkt liegt auf Online- und lokalem PvE-Koop; das Spiel ist auch alleine spielbar.

Es gibt keine Sprunghöhe, erhöhten Spielebenen oder allgemeine Ausweichrolle. Besondere Bewegungs- und Ausweichfähigkeiten gehören zur jeweiligen Klassenauswahl und belegen gegebenenfalls einen der aktiven Fähigkeitsslots.

### 1.2 Stages und Erkundung

- Ein Run beginnt in Stage 1.
- Frühe Stages sind klein, übersichtlich und mit einfachen Gegnern besetzt. Spätere Stages können größer und komplexer werden.
- Offene Gebiete, verbundene Räume, Korridore und Mischformen sind abhängig vom Stage-Typ möglich.
- Hindernisse, Mauern, Engstellen, Camps, Patrouillen, Rare Camps und Shops können Bestandteil einer Stage sein.
- Grundriss und Inhalte werden prozedural erzeugt. Dieselbe Stage-Nummer kann in verschiedenen Runs anders aussehen.
- Das Biom wechselt alle fünf Stages. Wald, Dschungel, Lava und Eis sind Beispiele; der endgültige Biomkatalog ist noch offen.
- Die Gruppe darf vor und nach dem Bosskampf beliebig lange in einer Stage bleiben, erkunden und nachspawnende Gegner bekämpfen.

**Boss und Portal:**

- Jede Stage besitzt einen auffindbaren, von Beginn an bekämpfbaren Boss.
- Es müssen keine zusätzlichen Camps oder Fortschrittsziele abgeschlossen werden, um den Boss bekämpfen zu dürfen.
- Der Tod des Bosses schaltet das Portal zur nächsten Stage frei.
- Der Boss-Sieg ermöglicht den Fortschritt, erzwingt ihn jedoch nicht.
- Alle aktiven Spieler müssen dem gemeinsamen Portalwechsel zustimmen.
- Reisen führen ausschließlich vorwärts. Nach dem gemeinsamen Wechsel wird die vorherige Stage nicht erneut betreten.

**Respawns:**

- Die generierte Map legt normale Camp- und Spawnorte sowie Patrouillen fest.
- Normale Gegner können an diesen Orten erneut erscheinen.
- Rare Camps können nach einer eigenen Wartezeit erneut erscheinen.
- Der Stage-Boss bleibt nach seinem Sieg besiegt.
- Konkrete Wartezeiten, Sicherheitsabstände und Regeln gegen Spawns unmittelbar bei Spielern sind noch offen.

### 1.3 Schwierigkeit und Scaling

Die Gegnerstärke besitzt ein mit der Stage-Nummer wachsendes Grundniveau und einen begrenzten Fortschrittsanstieg innerhalb der jeweiligen Stage.

- Jede neue Stage besitzt ein höheres Gegnergrundniveau.
- Kills und Camp-Abschlüsse können innerhalb einer Stage einen begrenzten Schwierigkeitsanstieg auslösen.
- Nach Erreichen dieser Grenze bleiben neu erscheinende Gegner auf einem vergleichbaren Maximalniveau der Stage.
- Gruppengröße, Gegnertyp und Begegnungstyp werden beim Scaling berücksichtigt.
- Gute Ausrüstung und starke Builds lösen keine zusätzliche Gegenanpassung aus. Ihr Stärkevorteil bleibt erhalten.
- Level-, Ausrüstungs- oder Talentgewinne werden daher nicht automatisch durch eine Verstärkung der Gegner ausgeglichen.
- Grundrisse, Gegnerzusammenstellungen und Begegnungen sorgen für unterschiedliche Belastung und Abwechslung.
- Daraus wird kein Wellen- oder Rundenmodus abgeleitet.

Die konkreten Formeln, Parameter, Grenzwerte und Zahlen sind noch nicht festgelegt. Das gemeinsame Run-Level ist von der Stage-Nummer und vom Fortschritt innerhalb einer Stage zu unterscheiden.

### 1.4 Koop und Bedienung

- Ein Run unterstützt insgesamt bis zu vier menschliche Spieler.
- Lokale und entfernte Spieler sind kombinierbar, beispielsweise zwei Spieler auf einem PC und zwei Freunde über Steam.
- Jede lokale Gruppe teilt sich auf ihrem Gerät eine gemeinsame Kamera.
- Steam-Koop und Controller-Unterstützung sind vorgesehen.
- Die Gruppe besitzt einen gemeinsamen EXP-Fortschritt und ein gemeinsames Run-Level.
- Talententscheidungen und Ausrüstung bleiben individuell.
- Der gewöhnliche Waffenangriff wird manuell gezielt und ausgelöst.
- Das Menü bietet Einstellungen, Lobby hosten und Lobby beitreten.
- Die einzelnen Einstellungen, Kameragrenzen, Beitritts- und Wiederverbindungsregeln sind noch offen.

### 1.5 Klassen, Fähigkeiten und Entwicklungswerkzeuge

Der Anfangsbestand umfasst:

| Klasse | Bestätigter Umfang |
| --- | --- |
| Krieger | Vier aktive und drei passive Fähigkeiten; konkrete Fähigkeiten noch offen |
| Jäger | Vier aktive und drei passive Fähigkeiten; konkrete Fähigkeiten noch offen |
| Magier | Vier aktive und drei passive Fähigkeiten; konkrete Fähigkeiten noch offen |
| Paladin | Vier aktive und drei passive Fähigkeiten; konkrete Fähigkeiten noch offen |

**Auswahl und Nutzung:**

- In der Lobby wählt ein Spieler seine Klasse sowie zwei aktive und eine passive Fähigkeit aus deren Angebot.
- Diese Fähigkeitsauswahl bleibt für den gesamten Run fest.
- Zusätzlich besteht ein eigener Waffen-Grundangriff. Er belegt keinen der beiden aktiven Klassenfähigkeitsslots.
- Fähigkeiten verwenden klassenspezifische Ressourcen. Deren konkrete Zuordnung, Erzeugung, Regeneration und Verbrauch sind noch offen.
- Spieler verbessern vorbereitete Fähigkeiten. Ein frei bedienbarer Action-/Condition-Baukasten ist kein Bestandteil der bestätigten Spielerbedienung.
- Neue Fähigkeitsdefinitionen müssen nicht während eines Runs generiert werden.

**Authoring und MCP:**

Die Entwickler sollen weitere Klassen, Fähigkeiten, Talente und andere Inhalte über das ActionSystem-Authoring und dessen MCP-Zugang gestalten und hinzufügen können. Diese Entwicklungswerkzeuge sind von den Fähigkeiten und Menüs zu unterscheiden, die Spielern im Run angeboten werden.

Die [ActionSystem-Spec](https://github.com/jeffreyduquan/ActionSystem/issues) dient als Grundlage für das gewünschte Fähigkeitensystem. Ihre internen Bausteine Actions, Conditions und Effects können die vorbereiteten Spielinhalte beschreiben.

Sandbox-Regeln wie gegnerische menschliche Teams, feste NPC-Wellen, Bearbeitung beliebiger NPCs durch Spieler oder fünf manuelle Fähigkeitseingänge werden nicht pauschal übernommen. Welche einzelnen Verträge für GearHunt gelten, muss bei der jeweiligen Konkretisierung ausdrücklich zugeordnet werden.

### 1.6 Run-Level und Talentbäume

- Jeder Run beginnt auf Level 1.
- Ein maximales Run-Level gibt es nicht.
- Level-ups vergeben Skillpunkte, solange der vorgesehene Talentausbau noch nicht abgeschlossen ist.
- **Jede aktive Fähigkeit besitzt ihren eigenen Talentbaum.**
- Angezeigt werden die beiden Talentbäume der tatsächlich mitgenommenen aktiven Fähigkeiten.
- Talente verbessern die zugehörige Fähigkeit und vergeben keine allgemeinen Charakterwerte.
- Die Talentbäume sind endlich ausbaubar.
- Nach abgeschlossenem Talentausbau kann das Run-Level weiter steigen und noch festzulegende Grundwerte verbessern. Weitere Talentpunkte sind dann nicht vorgesehen.
- Verdiente Punkte dürfen jederzeit ausgegeben werden, auch während des Kampfes.
- Das Talentmenü pausiert die gemeinsame Welt nicht.
- Ob passive Fähigkeiten ebenfalls einen Talentbaum erhalten, ist noch offen.

**Maßgebliche Korrekturen gegenüber früheren Gesprächsideen:**

- Die frühere Obergrenze von Level 40 ist aufgehoben.
- Die frühere Idee zweier klassenweiter Talentpfade, beispielsweise Wut und Verteidigung, ist durch Talentbäume pro aktiver Fähigkeit ersetzt.
- Regeln für das Mischen solcher früheren klassenweiten Pfade werden nicht automatisch auf die neuen Fähigkeitstalentbäume übertragen.
- Der zeitweise besprochene taktische Sprung ist durch die Entscheidung für reines 2D aufgehoben.

Aufbau und Größe der Fähigkeitstalentbäume, Voraussetzungen, Punktekosten, mögliche Fähigkeitsverbesserungen und ein eventuelles Zurücksetzen der Talentwahl sind noch zu definieren.

### 1.7 Ausrüstung, Seltenheiten und Beute

**Ausrüstungsslots:**

| Slot | Verwendung |
| --- | --- |
| Helm | Ausrüstungsgegenstand für den Kopf |
| Haupthand | Waffe |
| Nebenhand | Geeignete Einhandwaffe, Schild oder andere geeignete Nebenhand |
| Rüstung | Körperausrüstung |
| Schuhe | Fußausrüstung |

- Geeignete Einhandkombinationen und Schilde sind möglich.
- Eine Zweihandwaffe belegt Haupthand und Nebenhand.
- Jede Klasse startet mit einer festgelegten Anfangswaffe.
- Danach darf jede Klasse jede Waffenfamilie ausrüsten.
- Ausrüstung besitzt ausschließlich positive Boni.
- Vorgesehene Seltenheitsfarben sind Weiß, Grün und Lila.
- Gegner können Gold, seltener Ausrüstung und Materialien wie Wolfsblut oder Spinnenaugen fallen lassen.
- Ausrüstungsbeute wird persönlich zugewiesen.
- Spieler können Ausrüstung untereinander handeln.

Die konkreten Anfangswaffen, Waffenfamilien, Regeln für geeignete Einhandkombinationen, Wechselwirkungen zwischen Waffen und Klassenfähigkeiten, Seltenheitswerte sowie Item-Skalierung sind noch offen. Ebenso offen sind Gold- und Materialverteilung, ihre Verwendung sowie Einzelheiten des Handels.

### 1.8 Tod, Run-Ende und Fortsetzen

- Bei null Leben wird eine Figur kampfunfähig.
- Mitspieler können eine kampfunfähige Figur wiederbeleben.
- Sind alle Spieler gleichzeitig kampfunfähig, endet der Run. Im Solospiel endet der Run entsprechend beim Ausfall der einzigen Figur.
- An Stage-Übergängen entsteht ein fortsetzbarer Speicherstand.

Wiederbelebungsdauer, Bedingungen, zurückgewonnene Lebenspunkte und ein mögliches Zeitlimit der Kampfunfähigkeit sind noch offen. Ebenso offen ist, wie ein Abbruch während einer bereits begonnenen Stage behandelt wird.

**Dauerhafte Progression zwischen verschiedenen Runs bleibt ausdrücklich unentschieden.** Weder dauerhafte Werteverbesserungen noch ein bestimmter Freischaltungsumfang sind damit bereits beschlossen.

## 2. Unbestätigter Vorschlag: Ausrüstungswerte

Die folgenden 20 Werte sind ein Diskussionsvorschlag und **keine bereits beschlossene Attributliste**. Formeln, Einheiten, Grenzen, Wechselwirkungen und Geltungsbereiche sind noch zu bestimmen.

| Nr. | Vorgeschlagener Wert | Bereich |
| --- | --- | --- |
| 1 | Maximales Leben | Überleben |
| 2 | Lebensregeneration | Überleben |
| 3 | Lebensraub | Überleben |
| 4 | Rüstung | Überleben |
| 5 | Ausweichchance | Überleben |
| 6 | Schadensbonus | Angriff |
| 7 | Nahkampfstärke | Angriff |
| 8 | Fernkampfstärke | Angriff |
| 9 | Magiestärke | Angriff |
| 10 | Angriffsgeschwindigkeit | Angriff |
| 11 | Krit-Chance | Angriff |
| 12 | Krit-Schaden | Angriff |
| 13 | Abklingzeitverkürzung | Fähigkeiten |
| 14 | Reichweite | Fähigkeiten und Angriffe; genaue Zuordnung offen |
| 15 | Flächengröße | Fähigkeiten |
| 16 | Wirkungsdauer | Fähigkeiten |
| 17 | Bewegungsgeschwindigkeit | Bewegung |
| 18 | Glück | Beute |
| 19 | Goldbonus | Beute |
| 20 | Aufsammelradius | Beute |

Die Auswahl orientiert sich teilweise an den [Brotato-Werten](https://brotato.wiki.spellsandguns.com/Stats) und ergänzt Vorschläge für Klassenfähigkeiten. Eine an Wellenenden ausgezahlte Ernte gehört nicht zur vorgeschlagenen Liste. Ausweichchance als möglicher Wert bedeutet keine allgemeine manuell auslösbare Ausweichrolle.

## 3. Offene Themen und Einstieg für die nächste Q&A

Die nächste Themenrunde beginnt bei den zuletzt geänderten **Talentbäumen pro aktiver Fähigkeit**.

1. **Fähigkeitsbezogene Talentbäume:** Aufbau, Größe, Voraussetzungen, zulässige Verbesserungen, Punktekosten, Rücksetzen und möglicher Ausbau passiver Fähigkeiten.
2. **Klassen konkret gestalten:** Vier aktive und drei passive Fähigkeiten pro Anfangsklasse, Ressourcen, Anfangswaffen und Klassenidentität.
3. **Ausrüstung und Werte:** Die vorgeschlagenen Werte bestätigen oder überarbeiten; Waffenkompatibilität, Seltenheiten, Item-Skalierung und die Nutzung beliebiger Waffen durch jede Klasse klären.
4. **Loot und Wirtschaft:** Shops, Gold, Materialien, Handel, Kauf und Verkauf sowie Erträge beim wiederholten Farmen normaler Gegner und Rare Camps.
5. **Stage-Generierung:** Größen und Wachstumsgrenzen, gültige Grundrisse, Wege zum Boss und Portal, Camps, Patrouillen, Shops, Spawn-Sicherheit und Respawn-Zeiten.
6. **Scaling und Endlos-Progression:** Formeln, Stage-Fortschritt und dessen Grenze, Gruppenskalierung, Gegner- und Bosswerte, EXP-Verlauf sowie Grundwertwachstum nach abgeschlossenem Talentbaum.
7. **Koop und Ausfälle:** Wiederbeleben, Wiederverbinden, spätere Beitritte, Zustimmung zum Portalwechsel bei fehlenden Teilnehmern und gemeinsame Kameragrenzen.
8. **Speichern und dauerhafte Progression:** Abbruch innerhalb einer Stage, Fortsetzung eines gespeicherten Runs und mögliche Freischaltungen oder Meta-Progression zwischen Runs.
9. **Technische Einordnung:** Die konkrete Verwendung der ActionSystem-Spec und ihrer Authoring-/MCP-Zugänge im bestehenden Godot-Projekt gesondert entscheiden. Die ActionSystem-Vorlage stammt aus einem Unreal-Projekt; Übernahme der Spielregeln und technische Integration sind getrennte Entscheidungen.

## 4. Verwendung dieses Arbeitsstands

- Bestätigte Regeln stehen in Abschnitt 1.
- Die Werte aus Abschnitt 2 bleiben Vorschläge, bis sie ausdrücklich bestätigt werden.
- Abschnitt 3 enthält weiterhin offene Entscheidungen; dort werden keine stillen Standardregeln angenommen.
- Aussagen zum vorhandenen Prototyp oder zu dessen Tests ersetzen keine Abnahme der hier beschriebenen neuen Spielsysteme.
- Künftige Q&A-Runden aktualisieren die betroffenen Abschnitte und den Stand dieser Datei.
