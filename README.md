# Godot Game Framework Example

[![GDScript style](https://github.com/ndaniell/godot-game-framework-example/actions/workflows/gdscript-style.yml/badge.svg)](https://github.com/ndaniell/godot-game-framework-example/actions/workflows/gdscript-style.yml)

Example project using [`ndaniell/godot-game-framework`](https://github.com/ndaniell/godot-game-framework) as a git submodule.

## Setup

Clone and init submodules:

```bash
git clone --recurse-submodules <this-repo>
```

If you already cloned:

```bash
git submodule update --init --recursive
```

## Dev tooling (`ggfe`)

Install Godot (optional helper; you can also install Godot yourself):

```bash
./ggfe install
```

Python dev tools:

```bash
python -m pip install -r requirements-dev.txt
```

Format / lint:

```bash
./ggfe format
./ggfe lint
```

## Running the example

- Open `project.godot` in Godot **4.5.1** (or newer 4.5.x).
- Press Play: you’ll get a menu with **Host** / **Join**.
- To test locally, run two instances:
  - Instance A: Host
  - Instance B: Join `127.0.0.1:8910`

## Notes

- The framework repo is the submodule at `third_party/godot-game-framework/`.
- The Godot addon is available at the standard location `addons/godot_game_framework/` (symlinked from the submodule).
- The project bootstrapper is `res://ggf/GGF.gd` (recommended by the framework README).
- The `GGF` autoload points at that bootstrapper (and the framework plugin will leave it alone if it already exists).
