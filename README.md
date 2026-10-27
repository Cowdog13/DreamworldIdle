# Dreamworld Idle (Godot prototype)

Idle collector RPG set in the Dreamworld of the Cowdog card game. Open this folder (`idle_rpg/`) as its own
Godot project (main scene `scenes/main.tscn`). It is separate from the card game in the repo root.

## Rules as built
- Summon up to **5 Dreamshapes** with at most **10 total energy**. Each has 2-4 abilities.
- Each Dreamshape has a **30 second timeline** that loops forever. You add and remove ability blocks on it (Team tab: pick an ability, click the bar; click a block to remove it).
  A block spans the whole time from the ability starting until it has recovered: **startup + resolve + cooldown**.
  The solid part (startup + resolve) occupies the Dreamshape, so those can't overlap. The cooldown only locks that same ability, so another ability can be used while it recovers, but the same ability can't be used again until its cooldown has passed. Blocks must fit inside the 30 seconds. **Auto-fill** builds a plan for you. No direct control in battle.
- Target locks at the end of startup; the effect lands at the end of resolve. A target that dies before the effect lands is replaced by a new pick using the same rule.
- Time is real time only (1 second of battle = 1 second on the clock). There are no speed-up options.
- **Frontline / backline** per Dreamshape. Single-target attacks must hit the frontline first (backline only once the frontline is dead). Reaching Strike prefers the backline.
  Multiple valid targets: one is picked at random. "Lowest health ally" compares health percentage.
- **Armor** is soaked point for point before health. It stays until used and is capped at max health.
- **Equipment**: 1 slot per Dreamshape, one copy of each item, unlocked by first-clearing Dreamplanes and monster drops. Edits (team, rows, timelines, equipment) apply when the next battle starts.
- Battle ends when a whole side is defeated (or after 180s, counted as a loss). Waves of a Dreamplane repeat forever; a loss restarts the plane. Kills give XP to every active Dreamshape.
- Progress saves to `user://idle_save.json` and the game fast-forwards up to 2 hours of offline time on load.

## Adding content
Everything is data in `data/*.json`: `dreamshapes.json` (stats and abilities; `enemy_only` ones are monsters),
`dreamplanes.json` (waves, unlock order, first-clear item) and `equipment.json`. Effect words: `small`/`medium`/`large` (scaled by level and power), `amp` (heal boost).
Effects: `damage`, `heal`, `armor`, `heal_amp`. Targets: `enemy_random` (with optional `"hits": N`), `enemy_highest_hp`, `enemy_back_random`, `self`, `ally_lowest`, `allies_all`, `allies_same_row`.

## Tests
`godot --headless -s tests/battle_test.gd`, `tests/ui_smoke.gd`, and `tests/balance_sim.gd` (prints progression of the starting team).
