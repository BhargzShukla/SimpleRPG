extends Popup

# Node references
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Root/Player")
	set_process_input(false)

# Map A and S keys to level up health/mana choices
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A:
			player.max_health += player.max_health_upgrade
			player.health = player.max_health
			hide()
			set_process_input(false)
			get_tree().paused = false
		elif event.scancode == KEY_S:
			player.max_mana += player.max_mana_upgrade
			player.mana = player.max_mana
			hide()
			set_process_input(false)
			get_tree().paused = false

func _on_Player_player_level_up():
	set_process_input(true)
	popup_centered()
	get_tree().paused = true
	
	# Play level up sound
	$LevelUpSound.play()
