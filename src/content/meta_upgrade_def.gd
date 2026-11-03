class_name MetaUpgradeDef
extends ContentDef
## Permanent upgrade bought between runs with soul dust.

@export var stat: String = Stats.MAX_HP
@export var per_rank: float = 2.0
@export var max_rank: int = 5
@export var base_cost: int = 30
@export var cost_step: int = 30


func cost_for_rank(rank: int) -> int:
	return base_cost + cost_step * rank
