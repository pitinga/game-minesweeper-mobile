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
	game.reset()
	check(game.first_reveal and game.flag_count == 0, "reinício apaga campo e bandeiras")
	finish()


func finish() -> void:
	print("Campo Minado: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
