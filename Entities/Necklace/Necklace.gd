extends Area2D

var fiona

# Called when the node enters the scene tree for the first time.
func _ready():
	fiona = get_tree().root.get_node("Root/Fiona")

func _on_Necklace_body_entered(body):
	if body.name == "Player":
		$NecklaceSound.play()
		hide()
		fiona.necklace_found = true
		

func _on_NecklaceSound_finished():
	get_tree().queue_delete(self)
