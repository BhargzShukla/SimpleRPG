extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	# "Restart" the main scene
	get_tree().change_scene("res://Scenes/Main.tscn")
