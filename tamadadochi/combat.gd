extends Node




func _ready():
	print("💥 Stats loaded from previous scene:")
	print("Fuerza:", GlobalStats.fuerza_level)
	print("Magia:", GlobalStats.magia_level)
	print("Defensa:", GlobalStats.defensa_level)
