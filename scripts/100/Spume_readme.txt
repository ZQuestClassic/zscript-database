--- COMBOS ---

1: Submerged - up
2: Submerged - down
3: Submerged - left
4: Submerged - right
5: Emerging - up
6: Emerging - down
7: Emerging - left
8: Emerging - right
9: Emerged - up
10: Emerged - down
11: Emerged - left
12: Emerged - right
13: Preparing to fire - up
14: Preparing to fire - down
15: Preparing to fire - left
16: Preparing to fire - right
17: Firing - up
18: Firing - down
19: Firing - left
20: Firing - right


--- ENEMIES ---

Main enemy: Spume
- Type: Other
- Weapon damage is used
- Attribute 1: Spawn on this combo type (layer 0 only)
  - See std_constants.zh for the list of combo type IDs
  - If this is 0, it will be ignored
  - If this is -1, the enemy will be placed by the game, meaning it will spawn
      on land or on an enemy flag
- Attribute 2: Spawn on this flag (layer 0 only)
  - If this is 0, it will be ignored
  - If attributes 1 and 2 are both 0, the Spume will spawn in water
- Attribute 3: Shield level
  - If Link's shield is not at least this level, projectiles will be unblockable
- Attribute 4: Projectile movement
  - 0: Fly straight at Link
  - 1: Arc through the air
- Attribute 5: Projectile sprite
  - Default: 17
- Attribute 6: Projectile transparency
  - 0: None
  - 1: Flickering
  - 2: Translucent
  - 3: Both
- Attribute 7: Charging sound
- Attribute 8: Firing sound
- Attribute 9: Emerging sound
- Attribute 10: Submerging sound
- Attribute 11: Combo number: Submerged - up
- Attribute 12: Script slot


--- CREDITS ---

Script and tiles by Saffith
