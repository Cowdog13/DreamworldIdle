class_name HealthBar
extends Control
## Health with armor shown as a white segment at the leading edge of the health fill.
## The bar scales to max health, or to health + armor when that is larger.

var max_hp := 1.0
var hp := 1.0
var armor := 0.0
var fill_color := Color("4caf6a")


func _init() -> void:
	custom_minimum_size.y = 14


func set_values(new_hp: float, new_max: float, new_armor: float) -> void:
	if is_equal_approx(hp, new_hp) and is_equal_approx(max_hp, new_max) and is_equal_approx(armor, new_armor):
		return
	hp = new_hp
	max_hp = new_max
	armor = new_armor
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("11141c"))
	var total := maxf(max_hp, hp + armor)
	var hp_w := size.x * hp / total
	var armor_w := size.x * armor / total
	draw_rect(Rect2(0, 0, hp_w, size.y), fill_color)
	if armor > 0.0:
		draw_rect(Rect2(hp_w, 0, armor_w, size.y), Color.WHITE)
