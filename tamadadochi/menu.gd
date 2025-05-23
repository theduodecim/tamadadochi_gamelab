extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Start.grab_focus()
	$MarginContainer.visible = false


func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn") # Replace with function body. aca hay que checkear la escena


func _on_exit_pressed():
	get_tree().quit() # Replace with function body.


func _on_credits_pressed():
	$MarginContainer.visible = !$MarginContainer.visible
