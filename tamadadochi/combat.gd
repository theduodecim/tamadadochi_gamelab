extends Node

@onready var stat_label: Label = $StatPanel/statLabel
@onready var rolling_label: Label = $StatPanel/rollingForLabel
@onready var option_selector := $Panel/OptionSelector
@onready var combat_log: RichTextLabel = $CombatLogPanel/VBoxContainer/ScrollContainer/RichTextLabel
@onready var endPanel: Panel = $EndPanel
@onready var endPanelBTN: Button = $EndPanel/Button
@onready var endPanelLabel: Label = $EndPanel/Label
#audios
@onready var audio_acierto = $AudioStreamPlayer_Acierto
@onready var audio_falla = $AudioStreamPlayer_Falla
#turnindicator
@onready var turn_indicator = $TurnIndicator
@onready var str_indicator = turn_indicator.get_node("Str_indicator")
@onready var mag_indicator = turn_indicator.get_node("Mag_indicator")
@onready var def_indicator = turn_indicator.get_node("Def_indicator")

#dice
@onready var dice_subViewport = $dicePanel/Node3D/DiceSubViewport
@onready var animation_dice = $dicePanel/Node3D/DiceSubViewport/AnimationPlayer
#life
@onready var lifeCounter = $LifeControl/LifeCounter

var frame_lifeCounter = 4;
var enemy_hp := 40
var turn := 0
var used_option := ""
var retries := 1
var current_difficulty := 10

var CombatScenarios = load("res://CombatScenarios.gd").new()
var scenarios := []

func _ready():
	update_turn_indicator_levels()
	endPanelBTN.pressed.connect(endGame)
	$AudioStreamPlayer.play();
	randomize()
	scenarios = CombatScenarios.list.duplicate()
	next_turn()

	if stat_label:
		stat_label.text = "Stats :\nFuerza: %d\nMagia: %d\nDefensa: %d" % [
			GlobalVars.fuerza_level,
			GlobalVars.magia_level,
			GlobalVars.defensa_level
		]

func update_turn_indicator_levels():
	str_indicator.frame = min(GlobalVars.fuerza_level, 5)
	mag_indicator.frame = min(GlobalVars.magia_level, 5)
	def_indicator.frame = min(GlobalVars.defensa_level, 5)

func update_life_indicator():
	lifeCounter.frame = frame_lifeCounter - 1
	frame_lifeCounter -= 1
	

func print_to_combat_log(message: String):
	combat_log.text += message + "\n"
	await get_tree().process_frame  # Wait for UI update
	var scroll_container = combat_log.get_parent() as ScrollContainer
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

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
		rolling_label.text = "Última oportunidad - Turno %d" % turn
	else:
		rolling_label.text = "Turno %d" % turn

	current_difficulty = get_difficulty_for_turn(turn)

	var scenario = scenarios.pick_random()
	option_selector.show_options(scenario, used_option, current_difficulty)
	option_selector.option_selected.connect(_on_option_selected, CONNECT_ONE_SHOT)

func _on_option_selected(option: String):
	var stat_bonus := 0

	match option:
		"Fuerza":
			stat_bonus = GlobalVars.fuerza_level
		"Magia":
			stat_bonus = GlobalVars.magia_level
		"Defensa":
			stat_bonus = GlobalVars.defensa_level

	var roll := randi_range(1, 20)
	var total := roll + stat_bonus
	
	
	roll_dice_animation(roll)
	await get_tree().create_timer(3.0).timeout
	print_to_combat_log("Tirada: %d + %d = %d (Dif %d)" % [roll, stat_bonus, total, current_difficulty])

	if total >= current_difficulty:
		audio_acierto.play()
		print_to_combat_log("Éxito: daño infligido al enemigo")
		if roll == 20: 
			enemy_hp -= 20
			update_life_indicator()
			update_life_indicator()
		else:
			enemy_hp -= 10
			update_life_indicator()
	else:
		audio_falla.play()
		print_to_combat_log("Fallo: en '%s' " % option)

	used_option = option
	next_turn()

func check_game_result():
	if enemy_hp <= 0:
		print_to_combat_log("¡Victoria!")
		endPanelLabel.text = "¡Victoria!"
		endPanel.visible = true
	elif retries > 0:
		print_to_combat_log(" ¡ Ultimo intento ! ")
		lifeCounter.frame = 4
		frame_lifeCounter = 4
		retries -= 1
		enemy_hp = 40
		turn = 0
		used_option = ""
		rolling_label.text = ""  # Reiniciar etiqueta
		next_turn()
	else:
		print_to_combat_log("Game Over")
		rolling_label.text = "Derrota final"
		endPanelLabel.text = "Game Over"
		endPanel.visible = true
		
func endGame():
		get_tree().change_scene_to_file("res://menu.tscn")
	
		
		
func roll_dice_animation(value: int) -> void:
	print("🎲 Waiting before playing animation...")

	# Ensure the viewport is updating continuously
	dice_subViewport.process_mode = SubViewport.PROCESS_MODE_ALWAYS
	dice_subViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	# Wait to ensure everything is initialized
	await get_tree().process_frame
	#await get_tree().create_timer(5.0).timeout  # Wait 5 seconds

	var anim_name = "roll_%d" % value
	print("🎲 Playing dice roll animation:", anim_name)

	# Make sure we're playing at normal speed
	animation_dice.speed_scale = 1.0
	animation_dice.play(anim_name)

	# Debug to confirm time is progressing
	await get_tree().create_timer(0.5).timeout
	print("⏱️ Half a second in, current time:", animation_dice.current_animation_position)

	# Wait for the animation to finish
	await animation_dice.animation_finished
	print("✅ Animation finished!")

	emit_signal("roll_finished")		
		
		
