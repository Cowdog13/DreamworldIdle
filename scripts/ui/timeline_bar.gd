class_name TimelineBar
extends Control
## Draws a Dreamshape's 30 second timeline. Each ability has its own lane. A block is the whole
## time from the ability starting until it has recovered: the solid part is startup + resolve,
## the faded tail is cooldown. When editable, hover shows where a brush ability would go (green =
## fits, red = blocked); click to place it, or click an existing block to remove it.

signal slot_clicked(ability_index: int, start: float)
signal block_clicked(block_index: int)

const RULER_H := 16.0
const LANE_H := 22.0
const LANE_COLORS := [Color("5fae5f"), Color("d9a441"), Color("5a9bd5"), Color("c46a9a")]

var abilities: Array = []
var plan: Array = []
var playhead := -1.0
var brush := -1
var editable := false
var hover_time := -1.0


func setup(ability_list: Array, lane_h: float = LANE_H) -> void:
	abilities = ability_list
	custom_minimum_size = Vector2(300, RULER_H + abilities.size() * lane_h)
	mouse_filter = Control.MOUSE_FILTER_STOP if editable else Control.MOUSE_FILTER_IGNORE


func _lane_h() -> float:
	return (size.y - RULER_H) / maxf(abilities.size(), 1)


func _x(t: float) -> float:
	return t / Schedule.CYCLE * size.x


func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color("1d2130"))
	var lh := _lane_h()
	for i in abilities.size():
		if i % 2 == 1:
			draw_rect(Rect2(0, RULER_H + i * lh, size.x, lh), Color(1, 1, 1, 0.04))
	for t in range(0, 31, 5):
		var x := _x(t)
		draw_line(Vector2(x, RULER_H - 4), Vector2(x, size.y), Color(1, 1, 1, 0.18))
		draw_string(font, Vector2(x + 2, 11), "%ds" % t, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.6))
	for b in plan:
		_draw_block(font, b.a, b.start, lh, 1.0)
	if editable and brush >= 0 and hover_time >= 0.0:
		var ok := Schedule.can_place(abilities, plan, brush, hover_time)
		_draw_block(font, brush, hover_time, lh, 0.55, Color("4caf6a") if ok else Color("c0504d"))
	if playhead >= 0.0:
		var px := _x(playhead)
		draw_line(Vector2(px, RULER_H - 4), Vector2(px, size.y), Color("ffffff"), 2.0)


func _draw_block(font: Font, ability_index: int, start: float, lh: float, alpha: float, override: Color = Color(0, 0, 0, 0)) -> void:
	var a: Dictionary = abilities[ability_index]
	var col: Color = override if override.a > 0.0 else LANE_COLORS[ability_index % LANE_COLORS.size()]
	var y := RULER_H + ability_index * lh + 2
	var active_w := _x(Schedule.active_time(a))
	var total_w := _x(Schedule.total_time(a))
	var x := _x(start)
	draw_rect(Rect2(x, y, total_w, lh - 4), Color(col, 0.28 * alpha))
	draw_rect(Rect2(x, y, maxf(active_w, 2.0), lh - 4), Color(col, 0.95 * alpha))
	draw_rect(Rect2(x, y, total_w, lh - 4), Color(col, alpha), false, 1.0)
	draw_string(font, Vector2(x + 3, y + lh - 9), a.name, HORIZONTAL_ALIGNMENT_LEFT, total_w - 4, 11, Color(1, 1, 1, alpha))


func _time_at(px: float) -> float:
	return clampf(roundf(px / size.x * Schedule.CYCLE / Schedule.SNAP) * Schedule.SNAP, 0.0, Schedule.CYCLE)


func _gui_input(event: InputEvent) -> void:
	if not editable:
		return
	if event is InputEventMouseMotion:
		hover_time = _time_at(event.position.x)
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var t: float = event.position.x / size.x * Schedule.CYCLE
		var lane := int((event.position.y - RULER_H) / _lane_h())
		for i in plan.size():
			var b: Dictionary = plan[i]
			if b.a == lane and t >= b.start and t <= b.start + Schedule.total_time(abilities[b.a]):
				block_clicked.emit(i)
				return
		if brush >= 0:
			slot_clicked.emit(brush, _time_at(event.position.x))


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		hover_time = -1.0
		queue_redraw()
