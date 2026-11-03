class_name GameConfig
extends RefCounted
## Global tuning constants. Balance values that belong to one piece of content
## live in res://content instead.

const VERSION := "0.1.0"
const TICK_RATE := 60
const TICK_DT := 1.0 / TICK_RATE
const SNAPSHOT_INTERVAL_TICKS := 2 ## 30 Hz state updates for clients.

const MAX_PLAYERS := 4
const MAX_LOCAL_PLAYERS := 2
const MAX_WEAPONS := 6
const TOTAL_WAVES := 10
const DEFAULT_PORT := 24680

const ARENA_HALF := Vector2(1000.0, 620.0)

const SHOP_OFFERS := 4
const REROLL_BASE_PRICE := 2
const MAX_ENEMIES := 320
const SPAWN_TELEGRAPH := 0.8
const INVULN_AFTER_HIT := 0.45
