extends SceneTree
## Prints how a team progresses.   godot --headless -s tests/balance_sim.gd

func _init() -> void:
	var g := IdleGame.new_game()
	g.set_active("shurm", true)
	g.rng.seed = 7
	var tally := {}
	var t := 0.0
	while t < 1800.0:
		var w := g.wave
		var had := g.battle != null
		g.advance(0.1)
		t += 0.1
		if had and g.battle == null:
			var k := "w%d %s" % [w, g.last_result]
			tally[k] = tally.get(k, 0) + 1
	print(tally)
	print("levels ", {"shurm": g.owned.shurm.level, "defender": g.owned.defender.level, "cannonier": g.owned.cannonier.level}, " cleared ", g.cleared)
	quit()
