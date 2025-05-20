extends Node

var stat_label : Label = null


func _ready():
	stat_label = get_node("StatPanel/statLabel")
	print("💥 Stats loaded from previous scene:")
	print("Fuerza:", GlobalStats.fuerza_level)
	print("Magia:", GlobalStats.magia_level)
	print("Defensa:", GlobalStats.defensa_level)

	# Show values in the stat label
	if stat_label:
		stat_label.text = "💥 Stats :\nFuerza: %d\nMagia: %d\nDefensa: %d" % [
			GlobalStats.fuerza_level,
			GlobalStats.magia_level,
			GlobalStats.defensa_level
		]
