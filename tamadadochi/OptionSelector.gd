extends Control

signal option_selected(option_type: String)

@onready var description_label := $VBoxContainer/Description
@onready var fuerza_button := $VBoxContainer/HBoxContainer3/FuerzaButton
@onready var magia_button := $VBoxContainer/HBoxContainer2/MagiaButton
@onready var defensa_button := $VBoxContainer/HBoxContainer/DefensaButton

var current_options := {}
var locked_option := ""

func _ready():
	fuerza_button.pressed.connect(_on_FuerzaButton_pressed)
	magia_button.pressed.connect(_on_MagiaButton_pressed)
	defensa_button.pressed.connect(_on_DefensaButton_pressed)

func show_options(scenario: Dictionary, locked: String):
	locked_option = locked
	description_label.text = scenario["description"]
	current_options = scenario["options"]

	var dice := " 🎲"

	fuerza_button.text = "%s [%d]%s" % [current_options["Fuerza"], GlobalVars.fuerza_level, dice]
	magia_button.text = "%s [%d]%s" % [current_options["Magia"], GlobalVars.magia_level, dice]
	defensa_button.text = "%s [%d]%s" % [current_options["Defensa"], GlobalVars.defensa_level, dice]

	fuerza_button.disabled = locked == "Fuerza"
	magia_button.disabled = locked == "Magia"
	defensa_button.disabled = locked == "Defensa"


func _on_FuerzaButton_pressed():
	emit_signal("option_selected", "Fuerza")

func _on_MagiaButton_pressed():
	emit_signal("option_selected", "Magia")

func _on_DefensaButton_pressed():
	emit_signal("option_selected", "Defensa")
