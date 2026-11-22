extends "res://scripts/rules_base.gd"

const WIDTH := 9
const HEIGHT := 9
const MINES := 10
var values: Array[int] = []
var visible: Array[bool] = []
var flags: Array[bool] = []
var first_reveal := true
var revealed_count := 0
var flag_count := 0


func _init() -> void:
	title = "Campo Minado"
	subtitle = "Toque para abrir, segure para marcar"


func reset() -> void:
	super.reset()
	values.resize(WIDTH * HEIGHT)
	visible.resize(WIDTH * HEIGHT)
	flags.resize(WIDTH * HEIGHT)
	values.fill(0)
	visible.fill(false)
	flags.fill(false)
	first_reveal = true
	revealed_count = 0
	flag_count = 0


func _neighbors(index: int) -> Array[int]:
	var found: Array[int] = []
	var x := index % WIDTH
	var y := index / WIDTH
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx := x + dx
			var ny := y + dy
			if nx >= 0 and nx < WIDTH and ny >= 0 and ny < HEIGHT:
				found.append(ny * WIDTH + nx)
	return found


func _place_mines(safe_index: int) -> void:
	var forbidden := _neighbors(safe_index)
	forbidden.append(safe_index)
	var positions: Array[int] = []
	for i in range(WIDTH * HEIGHT):
		if not forbidden.has(i):
			positions.append(i)
	positions.shuffle()
	for i in range(MINES):
		values[positions[i]] = -1
	for i in range(WIDTH * HEIGHT):
		if values[i] == -1:
			continue
		var n := 0
		for neighbor in _neighbors(i):
			if values[neighbor] == -1:
				n += 1
		values[i] = n


func toggle_flag(index: int) -> bool:
	if ended or index < 0 or index >= values.size() or visible[index]:
		return false
	flags[index] = not flags[index]
	flag_count += 1 if flags[index] else -1
	return true


func reveal(index: int) -> bool:
	if ended or index < 0 or index >= values.size() or visible[index] or flags[index]:
		return false
	if first_reveal:
		_place_mines(index)
		first_reveal = false
	if values[index] == -1:
		visible[index] = true
		ended = true
		message = "Você encontrou uma mina!"
		return true
	var pending: Array[int] = [index]
	while not pending.is_empty():
		var current: int = pending.pop_back()
		if visible[current] or flags[current]:
			continue
		visible[current] = true
		revealed_count += 1
		if values[current] == 0:
			for n in _neighbors(current):
				if values[n] != -1 and not visible[n] and not pending.has(n):
					pending.append(n)
	score = revealed_count
	if revealed_count == WIDTH * HEIGHT - MINES:
		ended = true
		message = "Campo limpo!"
	return true


func _tap_index(p: Vector2) -> int:
	var x := int(floor(p.x * WIDTH))
	var y := int(floor((p.y - 0.15) / 0.72 * HEIGHT))
	if x < 0 or x >= WIDTH or y < 0 or y >= HEIGHT:
		return -1
	return y * WIDTH + x


func tap(p: Vector2) -> void:
	reveal(_tap_index(p))


func hold(p: Vector2) -> void:
	toggle_flag(_tap_index(p))


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	label(canvas, "Minas: %d  |  Marcas: %d" % [MINES, flag_count], Vector2(area.get_center().x, area.position.y + 50), 27)
	var side := minf(area.size.x - 12, area.size.y - 140)
	var grid := Rect2(area.position + Vector2((area.size.x - side) * 0.5, 110), Vector2.ONE * side)
	canvas.draw_rect(grid, Color("bdcce2"))
	for i in range(WIDTH * HEIGHT):
		var r := cell_rect(grid, i % WIDTH, i / WIDTH, WIDTH, HEIGHT, 2.4)
		canvas.draw_rect(r, Color("ffffff") if visible[i] else Color("567eb9"))
		if flags[i] and not visible[i]:
			label(canvas, "F", r.get_center(), 24, Color("fff3c5"))
		elif visible[i]:
			if values[i] == -1:
				label(canvas, "*", r.get_center(), 29, Color("d95663"))
			elif values[i] > 0:
				label(canvas, str(values[i]), r.get_center(), 23, Color("3666be"))
