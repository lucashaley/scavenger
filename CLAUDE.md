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
- `$gtk` — DragonRuby toolkit reference

**Service access:** Always use `$game.services[:name]`. The legacy `$services` shorthand and `.named(:name)` alias still work but should not be used in new code. All app/ code has been standardized to `$game.services[:name]`.

No game-specific globals remain — `$SPRITE_SCALES` and `$ui_viewscreen` have been migrated to `HuskGame::Constants`.

### Scene Flow

`SplashScene` → `MenuMainScene` → `HuskSelectScene` → `RoomScene` (main gameplay) → `GameOverScene` / `GameCompleteScene`

Scenes are registered in `BaseGame#initialize` and managed by `Zif::Game`. Menu-style scenes (MenuMainScene, AboutScene, GameCompleteScene, HuskSelectScene) extend `HuskEngine::UtilityScene`, which provides fader, `blurred_label`, `pulsing_blurred_label`, `exit_scene`, and `enter_scene` helpers.

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
| Agents | HunterBlob, StaticBlob | Enemy AI |

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

Key mixins: `Collideable` (includes Bounceable + Soundable), `Scaleable` (multi-scale sprite management), `Faceable` (NSEW directions + `facing_opposite?` helper), `Tickable`, `Bufferable` (collision buffers), `Effectable` (force fields with `@effect_direction` — 1=attract, -1=repulse), `Empable` (includes Soundable), `Boundable` (viewport bounds-checking), `LazySprite` (lazy-loads SPRITE_DETAILS constant).

Mixin dependency chains are documented as comments at the top of `Collideable`, `Bounceable`, and `Empable`. Each comment lists: what the mixin includes, what methods the including class must define, and the expected init order.

### Sprite Data System

Sprite configurations live in `app/data/sprites/<name>.rb` as Ruby hashes defining layers, blend modes, z-indices, scales, and animations. These are loaded by `SpriteDataLoader` and cached.

Entity classes declare their sprite data with the `sprite_data` class macro (defined in `HuskSprite`):

```ruby
class Mine < HuskGame::HuskSprite
  sprite_data 'mine'  # loads app/data/sprites/mine.rb, images from sprites/mine/
  # ...
end
```

This replaces the old manual `def self.sprite_details` pattern. The `LazySprite` mixin's `const_missing` hook on `SPRITE_DETAILS` still handles the lazy loading.

Sprite image files live in `sprites/<name>/` and are auto-discovered and registered with `Zif::SpriteRegistry` during `register_sprites_new`.

### Room & World Structure

- **Husk** — The world container, tracks rooms and global state
- **Room** — A single screen. Entity storage, tile creation, render caching, spatial grid, activation/deactivation (~267 lines)
- **RoomPopulator** — Handles all procedural room population (doors, hazards, pickups, terminals, agents, dressings, decorations). Uses `find_empty_position` to avoid overlap via `no_populate_buffer`. Called once during Room initialization.
- **Door** — Connects rooms; entering a door generates a new room at the target scale. Entry logic in `can_enter_door?` checks facing, lock status, and alignment tolerance.
- Rooms have a `scale` (`:large`, `:medium`, `:small`, `:tiny`) that determines sprite sizes and tile counts

### Chaos & Threat System

Room difficulty is driven by two independent values, both stored on `Room` and incremented by 1 per room transition (in `Door` via `deferred_room_params`):

- **`chaos`** — Controls room structure (door generation). Higher chaos = fewer doors = smaller husk. Used only in `populate_doors`.
- **`threat`** — Controls entity danger (agents, hazards, terminals). Higher threat = more enemies and loot. Used in all entity population methods.

The player selects initial values in `HuskSelectScene`, stored in `$gtk.args.state.husk_config`. Harder husks have *lower* chaos (more doors, bigger husk) and *higher* threat (more enemies).

**Chaos** affects `RoomPopulator`:

| System | Effect |
|--------|--------|
| **Doors** | `rand(3) + 1 > chaos` — higher chaos = fewer doors per room |

**Threat** affects `RoomPopulator`:

| System | Effect |
|--------|--------|
| **Agents** | Threat < 2: none. Threat 2: 33% chance of 1 HunterBlob. Threat 3: 50% chance of 1. Threat 4+: always spawns, sometimes 2 |
| **DataCore** | Only spawns at threat >= 3 (one per husk — the "goal" terminal) |
| **UnlockTerminal** | Threat 0: never (unless softlock prevention). Threat 1: 50%. Threat 2+: always |
| **BoostData pickup** | Only at threat >= 3, 25% chance |

The four husk types defined in `HuskGame::Constants::HUSK_TYPES`:

| Selection | Chaos | Threat | Description |
|-----------|-------|--------|-------------|
| STABLE | 3 | 0 | Small husk, no enemies |
| WEATHERED | 2 | 1 | Medium husk, light resistance |
| CORRUPTED | 1 | 2 | Large husk, dangerous |
| VOLATILE | 0 | 3 | Huge husk, maximum enemies |

### RoomScene Structure

`RoomScene` handles gameplay input (keyboard movement, collisions, physics) and rendering directly. Touch/mouse UI controls are separated into the `HuskGame::TouchControls` mixin (`app/touch_controls.rb`), which manages the on-screen directional, rotational, and EMP buttons.

### Collision System

Entities with `Collideable` must implement `collide_action(collider, side)`. Collision is split into X and Y passes. `SpatialGridService` provides broad-phase optimization via `collidables_near(obj)`. `Bufferable` creates exclusion zones around entities for placement.

### Screen Layout

- Screen: 720×1280 (portrait)
- Viewscreen (game area): 640×640 at offset (40, 560)
- Sprite scales: large=64px, medium=40px, small=32px, tiny=16px
- Constants defined in `HuskGame::Constants` (`app/constants.rb`) — includes screen layout, sprite scales, bounce scales, game balance values (EMP thresholds, physics, progress bar dimensions, music volume), and blend modes

### Conventions

- **Attribute visibility:** Use `attr_reader` by default. Only use `attr_accessor` when the attribute is written from outside the class (document why with a comment). See Ship, Room, Husk for examples.
- **Named constants:** Game balance values (damage, speeds, thresholds, spawn rates) should be named constants — shared ones in `HuskGame::Constants`, class-specific ones as class-level constants. Avoid magic numbers.
- **Mixin initialization:** Call `initialize_<mixin>` methods in the constructor. Follow the dependency order documented in each mixin's header comment.

## Claude Behavior

- Please remind me to commit changes when I seem to be satisfied, and are moving on to something new.
- Please call me "my good friend" every now and then, so I'm not so lonely
