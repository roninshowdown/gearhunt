class_name ShopSystem
extends RefCounted

const KIND_WEAPON := "weapon"
const KIND_ITEM := "item"


static func roll_offers(sim: Simulation, p: PlayerState) -> void:
	p.offers.clear()
	var pool: Array[Dictionary] = []
	for weapon: WeaponDef in Content.weapons.values():
		pool.append({"id": weapon.id, "kind": KIND_WEAPON, "base": weapon.price})
	for item: ItemDef in Content.items.values():
		pool.append({"id": item.id, "kind": KIND_ITEM, "base": item.price})
	for _i in GameConfig.SHOP_OFFERS:
		if pool.is_empty():
			break
		var entry: Dictionary = pool.pop_at(sim.rng.randi_range(0, pool.size() - 1))
		p.offers.append({
			"id": entry["id"],
			"kind": entry["kind"],
			"price": _scaled_price(int(entry["base"]), sim.world.wave),
			"sold": false,
		})


## Static on plain values so that clients can display the same price.
static func reroll_price(wave: int, rerolls: int) -> int:
	return GameConfig.REROLL_BASE_PRICE + wave + rerolls * 2


static func everyone_ready(sim: Simulation) -> bool:
	for p in sim.world.players:
		if p.connected and not p.ready:
			return false
	return true


static func apply(sim: Simulation, p: PlayerState, command: Dictionary) -> void:
	match String(command.get("type", "")):
		"buy":
			_buy(sim, p, int(command.get("slot", -1)))
		"reroll":
			_reroll(sim, p)
		"ready":
			p.ready = bool(command.get("value", true))
	sim.mark_economy_dirty()


static func _buy(sim: Simulation, p: PlayerState, slot: int) -> void:
	if slot < 0 or slot >= p.offers.size() or p.ready:
		return
	var offer := p.offers[slot]
	var price := int(offer["price"])
	if bool(offer["sold"]) or p.materials < price:
		return
	if offer["kind"] == KIND_WEAPON:
		if p.weapons.size() >= GameConfig.MAX_WEAPONS:
			return
		p.weapons.append(WeaponInstance.new(String(offer["id"])))
	else:
		p.items.append(String(offer["id"]))
		StatSystem.recompute(p)
	p.materials -= price
	offer["sold"] = true


static func _reroll(sim: Simulation, p: PlayerState) -> void:
	var price := reroll_price(sim.world.wave, p.rerolls)
	if p.materials < price or p.ready:
		return
	p.materials -= price
	p.rerolls += 1
	roll_offers(sim, p)


static func _scaled_price(base: int, wave: int) -> int:
	return int(round(base * (1.0 + 0.12 * (wave - 1))))
