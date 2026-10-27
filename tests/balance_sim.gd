extends SceneTree
## Prints how a team progresses.   godot --headless -s tests/balance_sim.gd

func _init() -> void:
	var g := IdleGame.new_game()
	g.set_active("shurm", true)
	g.rng.seed = 7
	var tally := {}
	var t := 0.0
	var first_clear := -1.0
	while t < 3600.0:
		var w := g.wave
		var had := g.battle != null
		g.advance(0.1)
		t += 0.1
		if had and g.battle == null:
			var k := "w%d %s" % [w, g.last_result]
			tally[k] = tally.get(k, 0) + 1
		if first_clear < 0.0 and g.cleared.size() > 0:
			first_clear = t
	print(tally)
	print("first clear at %.0f min; levels S%d D%d C%d" % [first_clear / 60.0, g.owned.shurm.level, g.owned.defender.level, g.owned.cannonier.level])
	quit()
