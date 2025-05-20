extends Node2D

# Creature stats
var creature_stats = {
	"Fuerza": 0,
	"Magia": 0,
	"Defensa": 0
}

# Stat cycling order
var stat_order = ["Fuerza", "Magia", "Defensa"]
var current_stat_index = 0
var turn_count = 1  # Start from Turn 1

# Button references (TextureButtons)
@onready var easy_button = $Node2D/EasyButton
@onready var medium_button = $Node2D/MediumButton
@onready var hard_button = $Node2D/HardButton

# UI references
@onready var dice_result_label = $dicePanel/Label
@onready var dialog_panel = $DialogBox
@onready var dialog_label = $DialogBox/Label

# Optional labels
var rollingForLabel : Label = null
var stat_label : Label = null
# Nuevas variables
var day_count = 1
var turn_in_day = 1

func _ready():
	# Fetch rolling stat label
	if has_node("StatPanel/rollingForLabel"):
		rollingForLabel = get_node("StatPanel/rollingForLabel")
		print_debug("✅ rollingForLabel loaded successfully")
	else:
		print_debug("⚠️ rollingForLabel not found — text display will be skipped")

	# Fetch full stat summary label
	if has_node("StatPanel/statLabel"):
		stat_label = get_node("StatPanel/statLabel")
		print_debug("✅ statLabel loaded successfully")
	else:
		print_debug("⚠️ statLabel not found — stat summary will be skipped")

	update_stat_display()
	setup_button_signals()


func update_stat_display():
	if rollingForLabel:
		var current_stat = stat_order[current_stat_index]
		rollingForLabel.text = "Día %d - Turno %d - Tirada por: %s" % [day_count, turn_in_day, current_stat]

	if stat_label:
		var translated = {
			"Fuerza": "Fuerza",
			"Magia": "Magia",
			"Defensa": "Defensa"
		}
		var summary = ""
		for stat in stat_order:
			var exp = creature_stats[stat]
			var lvl = get_level_from_exp(exp)
			summary += "%s: Nivel %d (%d XP)\n" % [translated[stat], lvl, exp]
		stat_label.text = summary.strip_edges()

	update_button_textures()


# Connect buttons safely
func setup_button_signals():
	if easy_button.pressed.is_connected(_on_roll_button_pressed):
		easy_button.pressed.disconnect(_on_roll_button_pressed)
	if medium_button.pressed.is_connected(_on_roll_button_pressed):
		medium_button.pressed.disconnect(_on_roll_button_pressed)
	if hard_button.pressed.is_connected(_on_roll_button_pressed):
		hard_button.pressed.disconnect(_on_roll_button_pressed)

	easy_button.pressed.connect(_on_roll_button_pressed.bind("Easy"))
	medium_button.pressed.connect(_on_roll_button_pressed.bind("Medium"))
	hard_button.pressed.connect(_on_roll_button_pressed.bind("Hard"))

# Change textures based on current stat
func update_button_textures():
	var stat = stat_order[current_stat_index]
	var base_path = "res://assets/img/test/"
	var texture_1 : Texture
	var texture_2 : Texture
	var texture_3 : Texture

	match stat:
		"Fuerza":
			texture_1 = load(base_path + "str_1.png")
			texture_2 = load(base_path + "str_2.png")
			texture_3 = load(base_path + "str_3.png")
		"Magia":
			texture_1 = load(base_path + "mag_1.png")
			texture_2 = load(base_path + "mag_2.png")
			texture_3 = load(base_path + "mag_3.png")
		"Defensa":
			texture_1 = load(base_path + "def_1.png")
			texture_2 = load(base_path + "def_2.png")
			texture_3 = load(base_path + "def_3.png")
		_:
			return

	easy_button.texture_normal = texture_1
	medium_button.texture_normal = texture_2
	hard_button.texture_normal = texture_3

# Handle stat roll and turn advance
func _on_roll_button_pressed(difficulty: String):
	set_buttons_enabled(false)  # 🔒 desactiva botones

	var roll = randi_range(1, 20)
	var stat = stat_order[current_stat_index]
	var exp_gained = 0
	var success = false
	var threshold = 0

	match difficulty:
		"Easy":
			threshold = 5
			exp_gained = 5
		"Medium":
			threshold = 11
			exp_gained = 10
		"Hard":
			threshold = 16
			exp_gained = 20

	if roll >= threshold:
		success = true
		creature_stats[stat] += exp_gained

	dice_result_label.text = "🎲 Tirada: %d" % roll
	dice_result_label.visible = true

	if success:
		dialog_label.text = "¡%s +%d puntos de experiencia (%s)!" % [stat, exp_gained, difficulty]
	else:
		dialog_label.text = "Fallaste la tirada de %s (Tirada: %d < %d). No ganaste experiencia." % [difficulty, roll, threshold]

	dialog_panel.visible = true

	await get_tree().create_timer(2.0).timeout

	dice_result_label.visible = false
	dialog_panel.visible = false

	current_stat_index = (current_stat_index + 1) % stat_order.size()

	# Avanzar turno y día
	turn_in_day += 1
	if turn_in_day > 3:
		turn_in_day = 1
		day_count += 1

		# Verificar fin de semana
		if day_count > 7:
			GlobalStats.fuerza_level = get_level_from_exp(creature_stats["Fuerza"])
			GlobalStats.magia_level = get_level_from_exp(creature_stats["Magia"])
			GlobalStats.defensa_level = get_level_from_exp(creature_stats["Defensa"])


			get_tree().change_scene_to_file("res://combat.tscn")
			return

	update_stat_display()
	set_buttons_enabled(true)  # 🔓 reactiva botones



func get_level_from_exp(exp: int) -> int:
	var level_thresholds = {
		1: 30,
		2: 45,
		3: 60,
		4: 75,
		5: 90,
		6: 105,
		7: 120,
		8: 135,
		9: 150,
		10: 165
	}
	
	var level = 0
	for lvl in level_thresholds.keys():
		if exp >= level_thresholds[lvl]:
			level = lvl
	return level


func set_buttons_enabled(enabled: bool):
	easy_button.disabled = !enabled
	medium_button.disabled = !enabled
	hard_button.disabled = !enabled
