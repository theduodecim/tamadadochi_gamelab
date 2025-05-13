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

# Show turn and stat info + full stats summary
func update_stat_display():
	# Update "Rolling for" with turn
	if rollingForLabel:
		var current_stat = stat_order[current_stat_index]
		rollingForLabel.text = "Turno %d - Tirada por: %s" % [turn_count, current_stat]

	# Full stat display (translated)
	if stat_label:
		var translated = {
			"Fuerza": "Fuerza",
			"Magia": "Magia",
			"Defensa": "Defensa"
		}
		var summary = ""
		for stat in stat_order:
			summary += "%s: %d\n" % [translated[stat], creature_stats[stat]]
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
	var roll = randi_range(1, 20)
	var stat = stat_order[current_stat_index]

	# Increase the stat
	creature_stats[stat] += roll

	# Show dice result
	dice_result_label.text = str(roll)
	dice_result_label.visible = true

	# Show dialog
	dialog_label.text = "Aumentaste tu %s por %d!" % [stat, roll]
	dialog_panel.visible = true

	# Wait a few seconds
	await get_tree().create_timer(2.0).timeout

	# Hide dice and dialog
	dice_result_label.visible = false

	# Move to next stat
	current_stat_index = (current_stat_index + 1) % stat_order.size()
	
	# Advance turn count
	turn_count += 1

	update_stat_display()
