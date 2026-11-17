# Giggle Grove: 26 brainrots, 4 zones, 8 mutations, steal, rebirth

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/nuraliana/roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/nuraliana/roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Giggle Grove is a 3D brainrot collector built for make.fun's "Make the best AI Roblox brainrot game" bounty. Wander a candy-coloured island, catch one of 26 original absurd friends — Pudding Pete, Sir Loin, DJ Dumpling, The Almighty Avocado — carry it home (one at a time!), and deposit it on your base, where it earns cash every second. Every deposit rolls an 8-tier mutation lottery (70% Plain up to 0.05% Divine x35), rivals can steal from your unlocked base, a lock dome keeps it safe for a minute, and rebirth resets your cash for a permanent +0.5x income and the key to Starlight Summit, where the Legendary and Mythic friends live. Five chaos events — Candy Rain, Slime Storm, Gravity Flip, Golden Hour, Treasure Gnome — shake the island every few minutes.

- **26 characters** across 6 rarities (Common $1/s to Mythic $1,000/s), each built at runtime from primitive parts — no uploaded assets.
- **4 zones**: Sunny Meadows, Mushroom Marsh, Ember Crags, and Starlight Summit (locked until your first rebirth).
- **8 mutations** per deposit, **5 chaos events**, **steal + lock dome** (45s cooldown, drop the loot if the owner catches you within 6 studs), **rebirth** (+0.5x forever).
- **Server-authoritative**: one service per system (Collection, Economy, Mutation, Rebirth, Steal, Event, WorldBuilder, GameState), one Config with every tuning number, one data table with every character and zone. All DataStore calls wrapped in pcall.

## Run it

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

---

<sub>Entered on [make.fun](https://make.fun/?ref=ctnjhg8e&utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
