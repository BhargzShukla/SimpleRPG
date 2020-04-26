extends KinematicBody2D

# Node references
var player

# Self explanatory with pointless comment :D
var randomNumberGenerator = RandomNumberGenerator.new()

# Movement variables
export var speed = 25
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0

# Animation variables
var other_animation_playing = false

# Skeleton stats
var health = 100
var max_health = 100
var xp_amount = 25

signal death

# Skeleton attack
var attack_damage = 10
var attack_cooldown_time = 500
var next_attack_time = 0

# Potion scene reference
var potion_scene = preload("res://Entities/Potion/Potion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().root.get_node("Root/Player")
	randomNumberGenerator.randomize()

func _on_Timer_timeout():
	# Calculate player position relative to skeleton
	var relative_player_position = player.position - position
	
	if relative_player_position.length() <= 16:
		# If player is within 16 pixels, turn towards them
		direction = Vector2.ZERO
		last_direction = relative_player_position.normalized()
	elif relative_player_position.length() <= 100 and bounce_countdown == 0:
		# If player is within range, move towards them
		direction = relative_player_position.normalized()
	elif bounce_countdown == 0:
		# If player is too far, randomly decide whether to stand still or move
		var random_number = randomNumberGenerator.randf()
		if random_number < 0.05:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(randomNumberGenerator.randf() * 2 * PI)
	
	# Update bounce_countdown
	if bounce_countdown > 0:
		bounce_countdown -= 1

func _physics_process(delta):
	var movement = direction * speed * delta
	var collision = move_and_collide(movement)
	
	if collision != null and collision.collider.name != "Player":
		direction = direction.rotated(randomNumberGenerator.randf_range(PI/4, PI/2))
		bounce_countdown = randomNumberGenerator.randi_range(2, 5)
		
	if not other_animation_playing:
		animates_monster(direction)
	
	# Turn RayCast2D toward movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 16

func _process(_delta):
	var time_now = OS.get_ticks_msec()
	if time_now >= next_attack_time:
		# What's the target
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			# Play attack animation
			other_animation_playing = true
			var attack_animation = get_animation_direction(last_direction) + "_attack"
			$AnimatedSprite.play(attack_animation)
			
			# Add cooldown to next attack
			next_attack_time = time_now + attack_cooldown_time

func get_animation_direction(animation_direction: Vector2):
	var normalized_direction = animation_direction.normalized()
	
	if normalized_direction.y >= 0.707:
		return "down"
	elif normalized_direction.y <= -0.707:
		return "up"
	elif normalized_direction.x >= 0.707:
		return "right"
	elif normalized_direction.x <= -0.707:
		return "left"
	return "down"

func animates_monster(animation_direction: Vector2):
	if animation_direction != Vector2.ZERO:
		last_direction = animation_direction
		
		# Choose walk animation based on movement direction
		var movement_animation = get_animation_direction(last_direction) + "_walk"
		
		# Play the walk animation
		$AnimatedSprite.play(movement_animation)
	else:
		# Choose idle animation based on last movement direction
		var idle_animation = get_animation_direction(last_direction) + "_idle"
		
		# Play the idle animation
		$AnimatedSprite.play(idle_animation)

func arise():
	other_animation_playing = true
	$AnimatedSprite.play("birth")
	

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "birth":
		$AnimatedSprite.animation = "down_idle"
		$Timer.start()
	elif $AnimatedSprite.animation == "death":
		get_tree().queue_delete(self)
	other_animation_playing = false

func hit(damage):
	health -= damage
	if health > 0:
		$AnimationPlayer.play("Hit")
	else:
		$Timer.stop()
		direction = Vector2.ZERO
		set_process(false)
		other_animation_playing = true
		$AnimatedSprite.play("death")
		emit_signal("death")
		
		# Randomly generate a potion for skeleton to drop on death, 80% of the time
		if randomNumberGenerator.randf() <= 0.8:
			var potion = potion_scene.instance()
			potion.type = randomNumberGenerator.randi() % 2
			get_tree().root.get_node("Root").call_deferred("add_child", potion)
			potion.position = position
		
		# Award XP to player
		player.add_xp(xp_amount)


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation.ends_with("_attack") and $AnimatedSprite.frame == 1:
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			player.hit(attack_damage)
