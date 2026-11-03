# Gearhunt

Top-down-Roguelite im Stil von Brotato mit manuellem Angriff, Fantasy-Klassen und organischer Shader-Grafik. Godot 4.7, GDScript.

## Starten
Godot öffnen, `Importieren`, `project.godot` in diesem Ordner wählen, mit F5 starten.

## Steuerung
| Aktion | Tastatur + Maus | Controller |
| --- | --- | --- |
| Bewegen | WASD oder Pfeiltasten | Linker Stick |
| Zielen | Maus | Rechter Stick |
| Angreifen | Linke Maustaste halten | RT oder RB halten |
| Pause | Esc | Start |

## Lobby
Enter: mit Tastatur beitreten. A: mit Controller beitreten. Stick, D-Pad oder A/D wechseln die Klasse. LB/RB wechseln die Welt. Start oder Enter beginnt den Run.

## Online-Koop
Ein Spieler wählt `Online-Koop hosten` und gibt UDP-Port 24680 frei. Der andere trägt dessen IP ein und tritt bei.

## Tests
```
godot --headless --path . res://tests/test_runner.tscn
godot --headless --path . res://tests/net_smoke.tscn -- host
godot --headless --path . res://tests/net_smoke.tscn -- client
godot --path . res://tests/screenshot_tour.tscn -- <ausgabeordner>
```
Host und Client des Netzwerktests laufen gleichzeitig in zwei Terminals.

Weiterführend: [Architektur](docs/ARCHITECTURE.md), [Roadmap](docs/ROADMAP.md).
Schrift: Fredoka, SIL Open Font License (`assets/fonts/OFL-LICENSE.txt`).
