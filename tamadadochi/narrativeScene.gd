extends Control

@onready var narrative_label: Label = $VBoxContainer/MarginContainer/NarrativeLabel
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer





var texts = [
	"La caída fue inevitable, nuestro amo supremo fue derrotado por el Héroe de la nación.",
	"Su cuerpo, despedazado por completo, se dividió para dar vida nueva...",
	"La naturaleza funcionaba incluso aquí, en una mazmorra húmeda y oscura. Y la vida siempre se abre camino.",
	"El caos era común para un esbirro como yo...",
	"Pero la muerte del amo implicaba una nueva oportunidad para nosotros.",
	"Quizás nuestro líder se había ido, pero su descendencia nos daría una nueva esperanza.",
	"Y ahora... estoy criando a mi jefe. Bueno, un cachorro de él al menos.",
	"Primero lo primero: darle un nombre."
]

var current_index := 0
var typewriter_speed := 0.03
var typing := false

func _ready():
	audio.play()
	$TextureButton.pressed.connect(_on_Button_pressed)
	$name_box/Button.pressed.connect(_on_name_confirmed)
	show_text(texts[current_index])

func show_text(text: String):
	narrative_label.text = ""
	typing = true
	var char_index := 0
	await get_tree().create_timer(typewriter_speed).timeout
	while char_index < text.length():
		narrative_label.text += text[char_index]
		char_index += 1
		await get_tree().create_timer(typewriter_speed).timeout
	typing = false

func _on_Button_pressed():
	if typing: return
	current_index += 1
	if current_index < texts.size():
		show_text(texts[current_index])
	elif current_index == texts.size():
		# Last line reached, show name input
		$name_box.visible = true
		$TextureButton.disabled = true  # optional, hide or disable button
		
		
func _on_name_confirmed():
	var entered_name = $name_box/LineEdit.text.strip_edges()
	if entered_name.is_empty():
		narrative_label.text = "Debe tener un nombre..."
		return
	# Save name to autoload, singleton, or pass to next scene
	GlobalVars.boss_name = entered_name  # for example
	get_tree().change_scene_to_file("res://main.tscn")
