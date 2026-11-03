# Hinweise für KI-Assistenten

Vor Änderungen `docs/ARCHITECTURE.md` lesen. Der Nutzer entwickelt vollständig per Vibe-Coding, Code muss also ohne Editor-Handarbeit änderbar bleiben.

Regeln:
- Spielregeln gehören nach `src/sim`. Dort keine Nodes, kein Rendering und kein `Input`.
- `src/view` und `src/ui` lesen `WorldState` nur. Änderungen laufen über `MatchController.send_command`.
- Zufall in der Simulation nur über `sim.rng`.
- Jede Eingabe eines Clients in `Simulation.apply_command` validieren.
- Neuer dauerhafter Spielzustand muss in `SnapshotCodec` übertragen werden.
- Neue Inhalte sind `.tres`-Dateien in `content/`, Dateiname gleich `id`. Texte über Schlüssel in `localization/strings.csv` (de und en).
- UI-Texte immer mit `tr()`.
- Nach jeder Änderung die Tests aus `README.md` ausführen; der Run muss 0 Fehler melden.
