# Typhoonette

Typhoonette is a 2D side-scrolling shooter prototype built with Godot 4.5. You pilot a fledgling storm that grows stronger by absorbing smaller debris and raindrops while avoiding larger threats that can tear it apart.

## Project Layout

- `scenes/` – Godot scenes starting with `main.tscn`, the current entry point.
- `scripts/` – GDScript code including `player_typhoon.gd` for the playable storm.
- `assets/` – Drop art, audio, and VFX here. Subfolders exist for `enemies/`, `pickups/`, `effects/`, and `environment/`.
- `ui/` – Interface scenes and resources.

## Placeholder Art

- `assets/effects/typhoon_placeholder.tres` – Radial gradient texture for the player storm.
- `assets/environment/crate_placeholder.tres` – Simple wood-tone gradient used by floating crates.

## Current Features

- Vertical scrolling level controller that keeps the ocean backdrop flowing and spawns floating crates to dodge or shatter.
- Playable `CharacterBody2D` typhoon with WASD movement, dash burst, and placeholder growth/shrink hooks.
- Breakable crates that chip away at the typhoon’s mass when you collide with them.
- Camera that follows the typhoon, simple parallax backdrop, and HUD label showing current mass.
- Input actions preconfigured in `project.godot` for immediate testing.

## Controls

| Action  | Key |
|---------|-----|
| Move    | WASD |
| Absorb (test mass gain) | J |
| Dash burst | Space |

Use **J** to simulate absorbing small objects and **Space** to trigger the dash prototype.

## Getting Started

1. Open the project in Godot 4.5 or newer (`project.godot`).
2. Press <kbd>F5</kbd> to run. The player scene will load automatically.
3. Tweak gameplay constants under the `Player` node in `main.tscn` via the Inspector.

## Next Steps

- Implement enemy and hazard scenes under `assets/enemies/` with corresponding logic.
- Replace placeholders with actual artwork, particle effects, and audio.
- Expand UI to show health, absorbed resources, and mission objectives.
- Add level progression and spawning logic for pickups and large obstacles.
