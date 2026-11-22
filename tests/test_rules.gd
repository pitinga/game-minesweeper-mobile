extends SceneTree

const Rules := preload("res://scripts/rules.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func _initialize() -> void:
	var game = Rules.new()
	game.reset()
	check(game.values.size() == 81 and game.first_reveal, "tabuleiro 9x9")
	game.toggle_flag(0)
	check(game.flags[0] and not game.reveal(0), "casa marcada não abre")
	game.toggle_flag(0)
	check(game.reveal(40), "primeira abertura válida")
	check(game.values.count(-1) == 10, "exatamente dez minas")
	check(game.values[40] == 0 and game.visible[40], "primeira casa e vizinhos seguros")
	for neighbor in game._neighbors(40):
		check(game.values[neighbor] != -1, "vizinho da primeira casa seguro")
	check(not game.reveal(40), "casa revelada não recontada")
	var grid := game.grid_rect()
	for i in range(81):
		var col := i % 9
		var row := i / 9
		for offset in [Vector2.ZERO, Vector2(8, 8), Vector2(-8, -8), Vector2(8, -8), Vector2(-8, 8)]:
			var pt := grid.position + Vector2((col + 0.5) * grid.size.x / 9.0, (row + 0.5) * grid.size.y / 9.0) + offset
			var normalized := (pt - Vector2(34, 178)) / Vector2(652, 770)
			check(game._tap_index(normalized) == i, "grade: casa %d" % i)
	check(game._tap_index(Vector2.ZERO) == -1, "margem fora da grade")
	game.reset()
	check(game.first_reveal and game.flag_count == 0, "reinício apaga campo e bandeiras")
	finish()


func finish() -> void:
	print("Campo Minado: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
