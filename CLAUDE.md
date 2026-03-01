# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Husk" is a top-down spaceship scavenger game built with **DragonRuby Game Toolkit (DRGTK)** using the **Zif** framework (bundled in `lib/zif/`). The player pilots a ship through procedurally generated rooms, collecting data from terminals, avoiding hazards, and navigating doors between rooms.

## Running the Game

The project lives in `mygame/` inside a DragonRuby installation. Run from the parent directory:

```bash
cd /path/to/scavenger
./dragonruby mygame
```

DRGTK provides hot-reloading — saving a file automatically reloads it in the running game. Use the DRGTK console (backtick key) and `app/repl.rb` for interactive testing.

## Architecture

### Framework

DRGTK uses mRuby, which is a limited version of Ruby. Make sure to only use the functionality in mRuby. Documentation can be found here: https://mruby.org/docs/api/

### Entry Point & Game Loop

`app/main.rb` defines the `tick` method called every frame by DRGTK. On tick 2 it creates `$game = HuskGame::BaseGame.new`, then calls `$game.perform_tick` each frame.

### Load Order

`app/require.rb` controls the require order. Dependencies must be loaded before dependents — add new files here in the correct position.

### Namespaces

- **`HuskGame`** — Game-specific classes (Ship, Room, Husk, BaseGame, entities, scenes)
- **`HuskEngine`** — Reusable engine mixins (Collideable, Scaleable, Faceable, etc.)
- **`Services`** — Service classes (EffectService, TickService, EmpService, SpatialGridService, SpriteDataLoader)
- **`Zif`** — Framework code in `lib/zif/` (do not modify)

### Key Globals

- `$game` — `HuskGame::BaseGame` instance (extends `Zif::Game`)
- `$services` — Service container (accessed via `$game.services[:name]` or `$game.services.named(:name)`)
- `$gtk` — DragonRuby toolkit reference
- `$SPRITE_SCALES`, `$ui_viewscreen`, etc. — Legacy globals from `HuskGame::Constants` (migration to constants module is in progress)

### Scene Flow

`SplashScene` → `MenuMainScene` → `RoomScene` (main gameplay) → `GameOverScene` / `GameCompleteScene`

Scenes are registered in `BaseGame#initialize` and managed by `Zif::Game`.

### Entity Hierarchy

All game entities extend `HuskSprite` (which extends `Zif::CompoundSprite`). Entity types:

| Base Class | Subclasses | Role |
|---|---|---|
| `Ship` | — | Player-controlled ship |
| `Connector` | DataTerminal, DataCore, Repairer, Breach | Interactive terminals |
| `Pickup` | BoostThrust, BoostEmp, ItemKeycard | Collectibles |
| `Hazard` (via mixins) | Mine, Repulsor, Attractor | Obstacles |
| `Dressing` | Crate, CrateBig | Non-interactive props |
| Decorations | Gash, Cable01 | Visual-only elements |
| Agents | HunterBlob | Enemy AI |

### Mixin System

Behavior is composed via mixins in `app/mixins/`. Each mixin has an `initialize_<name>` method that must be called in the entity's constructor:

```ruby
def initialize
  super(name)
  initialize_shadowable
  register_sprites_new
  initialize_scaleable(:large)
  initialize_collideable
  initialize_tickable
end
```

Key mixins: `Collideable` (includes Bounceable + Soundable), `Scaleable` (multi-scale sprite management), `Faceable` (NSEW directions), `Tickable`, `Bufferable` (collision buffers), `Effectable` (force fields), `Empable`, `LazySprite` (lazy-loads SPRITE_DETAILS constant).

### Sprite Data System

Sprite configurations live in `app/data/sprites/<name>.rb` as Ruby hashes defining layers, blend modes, z-indices, scales, and animations. These are loaded by `SpriteDataLoader` and cached. Each entity class exposes them via `def self.sprite_details` with lazy loading through the `LazySprite` mixin's `const_missing` hook on `SPRITE_DETAILS`.

Sprite image files live in `sprites/<name>/` and are auto-discovered and registered with `Zif::SpriteRegistry` during `register_sprites_new`.

### Room & World Structure

- **Husk** — The world container, tracks rooms and global state
- **Room** — A single screen. Procedurally populates doors, hazards, pickups, terminals, agents, dressings, and decorations using `find_empty_position` to avoid overlap via `no_populate_buffer`
- **Door** — Connects rooms; entering a door generates a new room at the target scale
- Rooms have a `scale` (`:large`, `:medium`, `:small`) that determines sprite sizes and tile counts

### RoomScene Fragments

`RoomScene` delegates to fragment modules in `app/fragments/`:
- `FragmentShip` — Ship control and physics
- `FragmentInput` — Input handling
- `FragmentUi` — HUD and UI elements

### Collision System

Entities with `Collideable` must implement `collide_action(collider, side)`. Collision is split into X and Y passes. `SpatialGridService` provides broad-phase optimization via `collidables_near(obj)`. `Bufferable` creates exclusion zones around entities for placement.

### Screen Layout

- Screen: 720×1280 (portrait)
- Viewscreen (game area): 640×640 at offset (40, 560)
- Sprite scales: large=64px, medium=40px, small=32px, tiny=16px
- Constants defined in `HuskGame::Constants` (`app/constants.rb`)
