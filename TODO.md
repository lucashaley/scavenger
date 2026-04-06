# To do

- [x] Figure out about the bounce, `bounce_off` is weird
- [x] Isn't giving the right scale for pickup
- [x] Light isn't lining up with center of scaled ship
- [x] Create scaled version of door
- [x] BoostThrust to use `collate_sprites`
- [x] Rotating the turret doesn't work
- [x] Make scaled version of thrusters
- [x] Fix weird south door thing
- [x] Check out override bounce in boost_thrust.rb
- [x] Turret direction when entering a room
- [x] Make the DataTerminal have different directions
- [ ] Make breach start
- [ ] Make breach finish
- [x] Smaller ships' thrusters don't line up
- [x] Fix mine damage amount
- [x] Remove main level from mine when exploding
- [ ] Weight item population for different scaled rooms
- [ ] Create overlays
- [x] Move crates to dressings list
- [x] Shadows are calculated from ship bottom left corner, not middle
- [x] Buffers aren't working
- [x] Tidy up power ups into parent class
- [x] Create UI for EMP charge
- [x] Move DataTerminal light control to method
- [ ] Player render ordering?
- [x] Fix mine causing repeat damage (across animation)
- [x] Create repairer
- [ ] Audio for collecting data
- [ ] Create lights for repairer
- [ ] Add kickback to hunterblob collision
- [x] Add shutdown to game scene
- [ ] Make 40p medium version
- [x] DataTerminal turn off audio when empty
- [ ] Create new audio for Repairer
- [ ] Create spawner
- [x] Add room switch fader
- [x] Create new audio for Repairer
- [x] Move overlay above lights
- [ ] Clean up button code
- [ ] Make more things Roomable?
- [x] Scale the pushback on HunterBlob collisions
- [ ] New UI: shouldn't be able to roll from direction to rotation
- [x] Make both directions of door have the same lock status
- [ ] Add more things to args.state
- [x] Stop music from menu screen to game
- [ ] Fade music out from menu screen to game
- [ ] Move agents etc state to state.rooms
- [ ] UI for ship damage
- [x] Keycard or memory slot door unlock?
- [ ] Finish scaling objects
- [x] create unlock terminal
- [x] button to return to main menu after completion
- [x] Blinking health overlays based on damage
- [x] Ensure unlock terminal spawns when all doors locked (prevent softlock)
- [x] Purge dead agents in Room#purge_deads
- [x] Game complete screen stats (datablocks, corrupted, time)
- [x] Replace game complete PNG with dynamic labels

## Critical Bugs

- [ ] Wall.rb mutates class constant `SPRITE_DETAILS.name` — works safely but needs architectural refactor (e.g. separate WallCorner class)
- [x] Empable error messages all say `handle_emp_low` — copy-paste bug, should say `handle_emp_medium` and `handle_emp_high` respectively (`app/mixins/empable.rb:16-21`)
- [x] Deadable `@dead = false` at module level instead of instance level — should be initialized in an `initialize_deadable` method (`app/mixins/deadable.rb:3`)
- [x] Door collision boolean logic broken — extracted to `facing_matches_door?` method
- [x] Spawner self-referencing default parameters (`scale: scale`) — changed to `nil`
- [x] `renders_over_player` includes dead agents — added `reject(&:is_dead?)`
- [x] Spatial grid not cleared on room deactivate — added `reset_grid` call

## Room & Tile Layout

- [ ] Use SpatialGridService during entity placement in `find_empty_position` instead of linear scan through `@no_populate_buffer`
- [x] Cache render arrays (`renders_under_player`, `renders_over_player`, `collidables`) instead of rebuilding every frame
- [ ] Clear spatial grid on room `deactivate` (currently only rebuilt on `activate`)
- [x] Remove duplicate `DOOR_BITS` constant (identical to `DOORS`) in room.rb
- [ ] Fix decoration placement to respect viewscreen bounds (currently uses `rand(720)` which can place outside 40–680 area)
- [ ] Resolve door scale vs room scale mismatch — destination door gets random scale but room uses current door's scale
- [ ] Fix `populate_data_terminal` always running (`rand(1) == 0` is always true)
- [x] Extract shared `populate_mines`/`populate_repulsors`/`populate_attractors` pattern into parameterized method
- [x] Standardize hash access from `find_empty_position` (`.x`/`.y` vs `[:x]`/`[:y]`)
- [x] Ensure starting room has at least 1 unlocked door
- [x] Ensure the unlock terminal is accessible from starting room

## Code Quality

- [x] Remove debug `puts` calls — removed ~172 calls across 22 files; 6 intentional puts remain (startup banner, kill log, override warning, error handler)
- [x] Extract magic numbers to named constants — added shared constants to `HuskGame::Constants` (PROGRESS_BAR_WIDTH, HAZARD_BOUNCE, EMP thresholds, etc.) and class-level constants to Mine, HunterBlob, Connector, Door, Husk
- [x] Migrate global variables (`$SPRITE_SCALES`, `$ui_viewscreen`, etc.) to `HuskGame::Constants` — already done, no game-specific globals remain
- [x] Extract Door entry boolean logic to `can_enter_door?` method — early-return guard clauses replace nested if/else
- [x] Standardize attribute visibility — converted `attr_accessor` to `attr_reader` across Ship, Door, Room, Husk, Mine, Connector, Breach; removed unused `rooms`/`room_dimensions` from Husk

## Duplication

- [x] Extract `BOUNCE_SCALES` to a single shared constant — moved to `HuskGame::Constants::BOUNCE_SCALES`
- [x] Extract `sprite_details` boilerplate into `HuskSprite` base class method — added `sprite_data 'name'` class macro
- [x] Extract bounds-checking into a shared mixin — created `HuskEngine::Boundable` mixin
- [x] Create shared `facing_opposite?` helper — added `HuskEngine::Faceable.facing_opposite?` class method
- [x] Unify Attractor/Repulsor `perform_effect` — moved to `Effectable` mixin with `@effect_direction` (1=attract, -1=repulse)
- [x] Remove redundant mixin includes — removed redundant `Bounceable` from Pickup, Connector, Dressing, Door, Wall, Attractor, Repulsor

## Architecture

- [x] Extract Room population logic into `RoomPopulator` class — Room reduced from 649 to 267 lines
- [ ] Refactor RoomScene fragments — FragmentUi is 270 lines, FragmentShip is 17; unclear responsibilities and overlapping concerns
- [x] Standardize constructor signatures — Attractor/Repulsor converted from positional to keyword args
- [x] Rename `init_faceable` to `initialize_faceable` — updated mixin and Wall caller
- [x] Standardize state access patterns — converted all `$services[key]` to `$game.services[key]` and `.named(key)` to `[key]` across 7 files
- [x] Fix Attractor calling `center_sprites` twice in initializer — fixed during keyword args conversion
- [x] Document mixin dependency chain — added dependency/requirement/init-order comments to Collideable, Bounceable, and Empable

## Performance

- [ ] Use SpatialGridService in `find_empty_position` instead of brute-force random placement — low priority: only runs once per room transition, buffer list is small (~20-40 items), and `find_intersect_rect` is a fast DRGTK built-in. The real bottleneck in dense rooms is the random retry loop failing to find open space, which a spatial grid doesn't help with.
- [x] HunterBlob calculates distance to ship every tick even when out of range — use squared distance for early-out check
- [x] Fragment UI searches buttons every tick — cached emp button reference in `ui.emp_button`

## Incomplete Features

- [ ] KeyCard — stub class, not implemented
- [ ] FragmentShip — nearly empty (18 lines), ship tick logic not in fragment
- [ ] Breach start/finish — partially implemented
- [ ] Repairer — missing audio and light sprites
- [ ] Tests — empty test file
- [ ] Game over screen — recreate with dynamic labels like game complete screen

## Game Balance

- [ ] Difficulty plateaus at chaos 4+ (no further scaling)
- [ ] Consider more agent variety or scaling beyond 2 per room
- [ ] EMP mechanic underused — 1 storage max, unclear recharge
- [ ] Room scale doesn't affect entity density proportionally
