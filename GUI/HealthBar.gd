extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_player_stats_changed(var player):
	$Bar.rect_size.x = 72 * player.health / player.max_health
	$Value.text = str(int(player.health)) + "/" + str(int(player.max_health))
