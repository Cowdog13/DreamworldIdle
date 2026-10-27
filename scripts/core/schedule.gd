class_name Schedule
extends RefCounted
## Rules for a Dreamshape's 30 second ability timeline.
##
## A plan is a list of blocks {a: ability index, start: seconds}. A block covers the whole time
## from the ability starting until it has recovered (startup + resolve + cooldown). The active
## part (startup + resolve) occupies the Dreamshape, so those can't overlap each other. The
## cooldown only locks that same ability, so another ability may be used while it recovers.
## The timeline loops every CYCLE seconds, so a block must fit inside it.

const CYCLE := 30.0
const SNAP := 0.5
const EPS := 0.0001


static func active_time(a: Dictionary) -> float:
	return a.startup + a.resolve


static func total_time(a: Dictionary) -> float:
	return a.startup + a.resolve + a.cooldown


static func can_place(abilities: Array, plan: Array, ability_index: int, start: float) -> bool:
	var a: Dictionary = abilities[ability_index]
	var total := total_time(a)
	if start < -EPS or start + total > CYCLE + EPS:
		return false
	var act_end := start + active_time(a)
	for b in plan:
		var o: Dictionary = abilities[b.a]
		if start < b.start + active_time(o) - EPS and b.start < act_end - EPS:
			return false
		if b.a == ability_index and start < b.start + total_time(o) - EPS and b.start < start + total - EPS:
			return false
	return true


## Earliest valid start at or after `from`, or -1 if there is no room.
static func first_fit(abilities: Array, plan: Array, ability_index: int, from: float = 0.0) -> float:
	var s := ceilf(from / SNAP - EPS) * SNAP
	while s <= CYCLE:
		if can_place(abilities, plan, ability_index, s):
			return s
		s += SNAP
	return -1.0


## Fills the timeline by cycling through the abilities in order, each at its earliest free time.
static func auto_plan(abilities: Array) -> Array:
	var plan: Array = []
	var cursor := 0.0
	while plan.size() < 60:
		var placed := false
		for i in abilities.size():
			var s := first_fit(abilities, plan, i, cursor)
			if s < 0.0:
				continue
			plan.append({"a": i, "start": s})
			cursor = s + active_time(abilities[i])
			placed = true
		if not placed:
			break
	sort_plan(plan)
	return plan


static func sort_plan(plan: Array) -> void:
	plan.sort_custom(func(x, y): return x.start < y.start)
