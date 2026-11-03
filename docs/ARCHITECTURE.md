# Architektur

## Grundidee
Die Simulation ist vom Rendering getrennt und läuft mit festen 60 Ticks pro Sekunde auf dem Host. Offline ist der eigene PC der Host, daher gibt es nur einen Spielablauf für Solo, Lokal-Koop und Online-Koop.

```
Geräte -> Inputs -> PlayerIntent -> MatchController -> Simulation -> WorldState
                                         |                               |
                     Clients <- Snapshots (Net)                 WorldView, Hud, Shop
```

## Schichten
| Ordner | Aufgabe | Darf nicht |
| --- | --- | --- |
| `src/sim` | Regeln und Zustand, ohne Szenenbaum und headless testbar | Nodes, Rendering, Input nutzen |
| `src/content` | Datenklassen für `.tres`-Dateien | Spiellogik enthalten |
| `src/net` | Verbindung, RPCs, Binärformat | Spielregeln enthalten |
| `src/input` | Geräte zu `PlayerIntent` | Spielzustand ändern |
| `src/view` | Darstellung und Effekte | Spielzustand ändern |
| `src/ui` | Screens und Widgets | Spielzustand direkt ändern |
| `src/meta` | Speicherstand, Belohnungen | |
| `src/app` | Autoloads und Spielablauf | |

## Autoloads
`Content` lädt alle Inhalte, `Save` den Speicherstand, `Inputs` die Geräte, `Net` das Netzwerk, `Session` die Spielerliste, `Sfx` die Sounds.

## Erweitern
| Ziel | Vorgehen |
| --- | --- |
| Neue Klasse | `.tres` in `content/characters`, Texte in `strings.csv` |
| Neuer Gegner | `.tres` in `content/enemies`, in `spawns` eines Bioms eintragen |
| Neues Gegnerverhalten | Unterklasse von `EnemyBehavior` |
| Neue Waffe | `.tres` in `content/weapons`; neues Prinzip als Unterklasse von `AttackPattern` |
| Neuer Gegenstand | `.tres` in `content/items` |
| Neuer Wert | Schlüssel in `Stats` und Auswertung in der passenden System-Klasse |
| Neues Biom | `.tres` in `content/biomes` und eigener Hintergrund-Shader |
| Dauerhaftes Upgrade | `.tres` in `content/meta` |

Eine neue `.tres` im passenden Ordner wird automatisch geladen.

## Netzwerk
Der Host ist autoritativ. Clients senden pro Tick `PlayerIntent` und bei Aktionen Befehle. Der Host sendet 30-mal pro Sekunde einen Snapshot über einen unzuverlässigen Kanal und Änderungen an Wirtschaft und Shop zuverlässig. `GameEvent`s sind rein kosmetisch und dürfen verloren gehen.

## Grafik
Alle Kreaturen nutzen `assets/shaders/creature.gdshader`; `CreatureLook` beschreibt das Aussehen. Massen laufen über `EntityBatch` (MultiMesh, ein Draw Call je Typ). Hintergründe sind eigene Shader je Biom. `postfx.gdshader` ergänzt Bloom, Vignette und Treffer-Tönung. Der Compatibility-Renderer sorgt für breite Hardware-Unterstützung, auch auf älteren PCs.
