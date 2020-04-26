extends KinematicBody2D

# Player movement speed
export var speed = 75

# Last direction player was facing before stopping
var last_direction = Vector2(0, 1)

# Is the player attacking?
var attack_playing = false

# Player stats
var health = 100
var max_health = 100
var health_regeneration_rate = 1
var max_health_upgrade = 50
var mana = 100
var max_mana = 100
var mana_regeneration_rate = 2
var max_mana_upgrade = 25

signal player_stats_changed

# Attack variables
var attack_cooldown_time = 500
var next_attack_time = 0
var attack_damage = 30

# Fireball variables
var fireball_damage = 50
var fireball_cooldown_time = 500
var next_fireball_time = 0
var fireball_scene = preload("res://Entities/Fireball/Fireball.tscn")

# Inventory variables
enum Potion { HEALTH, MANA }
var health_potions = 0
var mana_potions = 0

# Potion restore values
var health_restore = 50
var mana_restore = 50

# Player level variables
var xp = 0
var xp_next_level = 100
var xp_next_level_multiplier = 2
var level = 1

signal player_level_up

func _physics_process(delta):
	# Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction * delta
	
	# Decrease player speed when attack animations are playing
	if attack_playing:
		movement = 0.3 * movement
		
	# Turn RayCast2D toward movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 8
	
# warning-ignore:return_value_discarded
	move_and_collide(movement)
	
	if not attack_playing:
		# Animates player based on direction vector
		animates_player(direction)

func _input(event):
	if event.is_action_pressed("attack"):
		# Check if player can attack
		var time_now = OS.get_ticks_msec()
		if time_now >= next_attack_time:
			# What's the target?
			var target = $RayCast2D.get_collider()
			if target != null:
				if target.name.find("Skeleton") >= 0:
					#Skeleton hit
					target.hit(attack_damage)
			
			# Play attack animation
			attack_playing = true
			var attack_animation = get_animation_direction(last_direction) + "_attack"
			$Sprite.play(attack_animation)
			# Add cooldown before next attack
			next_attack_time = time_now + attack_cooldown_time
	elif event.is_action_pressed("fireball"):
		var time_now = OS.get_ticks_msec()
		if mana >= 25 and time_now >= next_fireball_time:
			# Update mana
			mana -= 25
			emit_signal("player_stats_changed", self)
			
			# Play fireball animation
			attack_playing = true
			var fireball_animation = get_animation_direction(last_direction) + "_fireball"
			$Sprite.play(fireball_animation)
			
			# Add cooldown before next fireball
			next_fireball_time = time_now + attack_cooldown_time
	elif event.is_action_pressed("drink_health"):
		if health_potions > 0:
			health = min(health + health_restore, max_health)
			health_potions -= 1
			emit_signal("player_stats_changed", self)
	elif event.is_action_pressed("drink_mana"):
		if mana_potions > 0:
			mana = min(mana + mana_restore, max_mana)
			mana_potions -= 1
			emit_signal("player_stats_changed", self)

func animates_player(direction: Vector2):
	if direction != Vector2.ZERO:
		# Update last direction player was facing
		# Account for joystick drift
		last_direction = (0.5 * last_direction) + (0.5 * direction)
		
		# Choose walk animation based on last movement direction
		var walk_direction = get_animation_direction(last_direction) + "_walk"
		
		# Account for joystick movement in walking speed
		$Sprite.frames.set_animation_speed(walk_direction, 2 + (8 * direction.length()))
		
		#Play walk animation
		$Sprite.play(walk_direction)
	else:
		# Choose ide animation based on last movement direction
		var last_idle_direction = get_animation_direction(last_direction) + "_idle"\
		
		#Play idle animation
		$Sprite.play(last_idle_direction)
		
func get_animation_direction(direction: Vector2):
	var normalized_direction = direction.normalized()
	
	if normalized_direction.y >= 0.707:
		return "down"
	elif normalized_direction.y <= -0.707:
		return "up"
	elif normalized_direction.x >= 0.707:
		return "right"
	elif normalized_direction.x <= -0.707:
		return "left"
	return "down"

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("player_stats_changed", self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Regenerates health
	var updated_health = min(health + health_regeneration_rate * delta, max_health)
	if updated_health != health:
		health = updated_health
		emit_signal("player_stats_changed", self)
		
	# Regenerated mana
	var updated_mana = min(mana + mana_regeneration_rate * delta, max_mana)
	if updated_mana != mana:
		mana = updated_mana
		emit_signal("player_stats_changed", self)


func _on_Sprite_animation_finished():
	attack_playing = false
	
	if $Sprite.animation.ends_with("_fireball"):
		# Instantiate fireball
		var fireball = fireball_scene.instance()
		fireball.attack_damage = fireball_damage
		fireball.direction = last_direction.normalized()
		fireball.position = position + last_direction.normalized() * 4
		get_tree().root.get_node("Root").add_child(fireball)

func hit(damage):
	health -= damage
	emit_signal("player_stats_changed", self)
	if health <= 0:
		set_process(false)
		$AnimationPlayer.play("Game Over")
	else:
		$AnimationPlayer.play("Hit")

func add_potion(type):
	if type == Potion.HEALTH:
		health_potions += 1
	else:
		mana_potions += 1
	emit_signal("player_stats_changed", self)

func add_xp(value):
	xp += value
	
	# Has the player leveled up?
	if xp >= xp_next_level:
		level += 1
		xp_next_level *= xp_next_level_multiplier
		emit_signal("player_level_up")
	emit_signal("player_stats_changed", self)
