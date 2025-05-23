extends Node

@onready var stat_label: Label = $StatPanel/statLabel
@onready var rolling_label: Label = $StatPanel/rollingForLabel
@onready var option_selector := $Panel/OptionSelector
@onready var combat_log: RichTextLabel = $CombatLogPanel/RichTextLabel

var enemy_hp := 40
var turn := 0
var used_option := ""
var retries := 1
var current_difficulty := 10

var CombatScenarios = load("res://CombatScenarios.gd").new()
var scenarios := []

func _ready():
	randomize()
	scenarios = CombatScenarios.list.duplicate()
	next_turn()

	if stat_label:
		stat_label.text = "💥 Stats :\nFuerza: %d\nMagia: %d\nDefensa: %d" % [
			GlobalStats.fuerza_level,
			GlobalStats.magia_level,
			GlobalStats.defensa_level
		]

func print_to_combat_log(message: String):
	combat_log.text += message + "\n"
	combat_log.scroll_to_line(combat_log.get_line_count())

func get_difficulty_for_turn(turn_num: int) -> int:
	match turn_num:
		1, 2:
			return randi_range(8, 12)
		3, 4:
			return randi_range(13, 16)
		5:
			return randi_range(17, 20)
		_:
			return 10

func next_turn():
	if turn >= 5 or enemy_hp <= 0:
		check_game_result()
		return

	turn += 1

	# Mostrar turno y si es el último intento
	if retries == 0:
		rolling_label.text = "⚠️ Última oportunidad - Turno %d" % turn
	else:
		rolling_label.text = "Turno %d" % turn

	current_difficulty = get_difficulty_for_turn(turn)

	var scenario = scenarios.pick_random()
	option_selector.show_options(scenario, used_option)
	option_selector.option_selected.connect(_on_option_selected, CONNECT_ONE_SHOT)

func _on_option_selected(option: String):
	var stat_bonus := 0

	match option:
		"Fuerza":
			stat_bonus = GlobalStats.fuerza_level
		"Magia":
			stat_bonus = GlobalStats.magia_level
		"Defensa":
			stat_bonus = GlobalStats.defensa_level

	var roll := randi_range(1, 20)
	var total := roll + stat_bonus
	print_to_combat_log("🎲 Tirada: %d + bonificación %d = %d (Dif %d)" % [roll, stat_bonus, total, current_difficulty])

	if total >= current_difficulty:
		print_to_combat_log("✅ Éxito: daño infligido al enemigo")
		enemy_hp -= 10
	else:
		print_to_combat_log("❌ Fallo: opción '%s' bloqueada para el próximo turno" % option)

	used_option = option
	next_turn()

func check_game_result():
	if enemy_hp <= 0:
		print_to_combat_log("🏆 ¡Victoria!")
	elif retries > 0:
		print_to_combat_log("🔁 Segundo intento disponible")
		retries -= 1
		enemy_hp = 40
		turn = 0
		used_option = ""
		rolling_label.text = ""  # Reiniciar etiqueta
		next_turn()
	else:
		print_to_combat_log("💀 Game Over")
		rolling_label.text = "☠️ Derrota final"
