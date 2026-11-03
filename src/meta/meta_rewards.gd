class_name MetaRewards
extends RefCounted
## Soul dust earned from a finished run.

const PER_WAVE := 6
const KILLS_PER_DUST := 12
const VICTORY_BONUS := 60


static func soul_dust(wave: int, kills: int, victory: bool) -> int:
	return wave * PER_WAVE + kills / KILLS_PER_DUST + (VICTORY_BONUS if victory else 0)
