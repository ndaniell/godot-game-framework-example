# Godot Game Framework (GGF) Improvement & Feature Backlog

## Current implementation snapshot (what exists today)

- **Bootstrap/service locator**: single autoload `GGF` instantiates managers in a fixed order and provides `get_manager(&"...")` plus typed helpers like `GGF.ui()`, `GGF.network()`.
  - Source: `third_party/godot-game-framework/addons/godot_game_framework/GGF.gd`
- **Managers included (core set)**: `LogManager`, `EventManager`, `NotificationManager`, `SettingsManager`, `AudioManager`, `TimeManager`, `ResourceManager`, `PoolManager`, `SceneManager`, `SaveManager`, `NetworkManager`, `InputManager`, `GameManager`, `UIManager`.
  - (Also validated by the framework's CLI test entrypoint required-manager list.)
- **Game flow/state machine**: `GameManager` loads a `GameStateMachineConfig` resource (default states at `addons/.../resources/data/game_states.tres`) and supports per-state **data-driven actions** like `change_scene` and UI actions, plus `state_property_overrides` for host projects.
  - Source: `.../core/managers/GameManager.gd`, `.../core/types/GameStateMachineConfig.gd`, example override in `src/ExampleGGF.gd`
- **Networking**: `NetworkManager` wraps ENet host/join/disconnect, emits signals, and mirrors lifecycle events to EventManager; includes a generic `session_event` RPC broadcast mechanism.
  - Source: `.../core/managers/NetworkManager.gd`
- **UI**: `UIManager` loads an optional `UIConfig` and instantiates a UI root (`UIRoot.tscn`) with layer containers; can pre-register UI scenes and provides menu/dialog stack helpers.
  - Source: `.../core/managers/UIManager.gd`, `.../resources/ui/*`
- **Diagnostics**: built-in diagnostics overlay + simple time-series graph for FPS; toggle via F3.
  - Source: `.../resources/ui/DiagnosticsOverlay.gd`, `.../resources/ui/MetricsGraph.gd`
- **Settings**: `SettingsManager` applies graphics/audio/gameplay settings, loads defaults from `res://ggf_settings_config.tres` if present, persists JSON to `user://settings.save`, and exposes a framework settings dialog UI.
  - Source: `.../core/managers/SettingsManager.gd`, `.../resources/ui/SettingsDialog.gd`
- **Persistence**: `SaveManager` stores JSON save slots with `{version:"1.0", timestamp, metadata, game_data}`; default collection is mostly placeholder and meant to be overridden.
  - Source: `.../core/managers/SaveManager.gd`
- **Testing harness**: addon-local test framework with a CLI `SceneTree` entrypoint and a `TestRunner`.
  - Source: `.../tests/TestEntryPoint.gd`, `.../tests/README.md`

## Improvement / feature ideas (prioritized)

### High impact / relatively low effort (good near-term wins)

- **Richer readiness/dependency model for managers**
  - **Why**: `GGF` creates managers in order, but managers may still need "ready" guarantees beyond `_ready()` timing (you already solved this partially with `GGF.ggf_ready` tied to `UIManager.ui_ready`).
  - **Idea**: standardize a `ready` signal + `is_ready()` contract for all managers, plus a helper `await GGF.await_ready(&"UIManager")` to reduce ad-hoc `await process_frame` usage.

- **Event system ergonomics** (`EventManager`)
  - **Add**: `subscribe_once()`, `unsubscribe_all_for_owner(owner: Node)`, optional listener priority ordering, and wildcard/namespace subscriptions (e.g. `network.*`).
  - **Add**: debug inspector: list registered events + listener counts + most recent history entries (history already exists).

- **Notification styling + theming hooks** (`NotificationManager` / UI)
  - **Why**: default toast script has no type styling and `_set_notification_style()` is a placeholder.
  - **Idea**: ship a default theme mapping for `INFO/SUCCESS/WARNING/ERROR` (colors/icons) using the existing `ggf_theme_default.tres`.

- **Save system safety & quality** (`SaveManager`)
  - **Add**: atomic write (write temp, fsync/flush, rename), optional compression, and stronger error codes.
  - **Add**: explicit schema versioning + migration hook (`migrate_save(version_from, data)`), since `version` is present but unused.

- **Scene transitions that actually fade/slide** (`SceneManager`)
  - **Why**: transitions currently just wait timers; no visual fade.
  - **Idea**: provide a small built-in transition layer in `UIManager` overlay (CanvasLayer) to animate a full-screen ColorRect.

- **Input remapping completeness** (`InputManager`)
  - **Why**: persistence exists, but restoring default mappings is left to host projects (`_restore_default_action` is a stub).
  - **Idea**: optionally capture defaults at first run (snapshot InputMap) and use that for reset; add a built-in "Controls" UI panel.

- **Diagnostics overlay expansion**
  - **Add**: memory (RSS/texture memory where possible), draw calls, node count, physics FPS, network peer count/traffic, and log tail from `LogManager` ring buffer.
  - **Why**: you already have a graph and toggles; extending it yields big value quickly.

### Medium effort, high leverage (framework differentiation)

- **Data-driven state machine upgrades** (`GameManager` + `GameStateMachineConfig`)
  - **State stacks**: push/pop states (menus, pause overlays) rather than single `current_state`.
  - **Async transitions**: allow `change_scene` with loading progress and "enter only after loaded."
  - **State-scoped events**: emit `state_entered(state)` / `state_exited(state)` via EventManager for decoupled gameplay/UI logic.
  - **Editor tooling**: small editor UI to edit `GameStateMachineConfig` with validation and a visual transitions graph.

- **Networking: session layer + replication helpers** (`NetworkManager`)
  - **Add**: a first-class "lobby/session" concept: host assigns player slots, names, ready states; simple authoritative session state replication.
  - **Add**: message schema validation for `session_event` (allowlisted event names + required keys) to avoid fragile stringly-typed RPC.
  - **Add**: reconnect flow and "late join" snapshot handling.

- **Resource + scene loading pipeline** (`ResourceManager` / `SceneManager`)
  - **Add**: async loading with progress callbacks, cancellation, and dependency prefetch (threaded loader status is available).
  - **Improve**: cache eviction policy (true LRU with touch timestamps) and expose cache stats in diagnostics.

- **Unified configuration strategy**
  - **Why**: UI and settings already have override resources (`ggf_ui_config.tres`, `ggf_settings_config.tres`).
  - **Idea**: a single "GGF project config" resource that can reference sub-configs, easing setup and documentation.

### Larger / longer-horizon features

- **Modular manager composition**
  - **Why**: currently `GGF` always instantiates all managers; some games may want a minimal subset.
  - **Idea**: allow `GGF` to load a "manager manifest" resource (enable/disable managers, custom manager classes, ordering constraints).

- **Multiplayer gameplay helpers**
  - **Add**: basic client-side prediction + interpolation helpers for common movement patterns, with opt-in authoritative correction.
  - **Add**: debug network overlay (RTT, packet loss estimates, bandwidth).

- **Save/Settings profiles and cloud sync hooks**
  - Multiple profiles, per-profile settings, cloud save integration points (Steam, itch, etc.), and encryption hooks for tamper resistance.

- **In-editor templates / project wizard**
  - Generate `ggf_*_config.tres`, scaffolding scenes (UIRoot), and example managers; reduce "blank project" setup friction.

## Concrete, repo-specific opportunities (based on the example project)

- The example uses `state_property_overrides` in `src/ExampleGGF.gd` to drive menu/lobby/playing transitions. A natural next feature is **state-stack support** so menus/lobbies can layer over gameplay without forcing scene swaps.
- The repo already supports **headless test runs** via `tests/TestEntryPoint.gd`; expanding this into **CI integration tests** (state transitions, network join/leave, UI readiness) would increase confidence as features grow.

## Suggested next steps (if you want to pick a direction)

- Pick 3–5 "near-term wins" above and treat them as a vNext milestone.
- Use the diagnostics overlay as the "integration surface" for quality improvements: once it can display events/logs/network stats, it becomes a forcing function for better APIs and observability.

## Document metadata

- **Created**: 2026-01-31
- **Framework version analyzed**: Based on current state of `third_party/godot-game-framework/` submodule
- **Analysis scope**: All 14 core managers, state machine, networking layer, UI system, settings/persistence, diagnostics, and testing infrastructure
