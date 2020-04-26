extends StaticBody2D

enum QuestStatus { NOT_STARTED, STARTED, COMPLETED }
var quest_status = QuestStatus.NOT_STARTED
var dialogue_state = 0
var necklace_found = false

var dialogue_popup
var player
enum Potion { HEALTH, MANA }

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_popup = get_tree().root.get_node("Root/CanvasLayer/Dialogue")
	player = get_tree().root.get_node("Root/Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func talk(answer = ""):
	# Set Fiona's animation sprite to "talk"
	$AnimatedSprite.play("talk")
	
	# Set dialogue popup NPC to Fiona
	dialogue_popup.npc = self
	dialogue_popup.name = "Fiona"
	
	# Show current dialogue
	match quest_status:
		QuestStatus.NOT_STARTED:
			match dialogue_state:
				0:
					# Update dialogue tree state
					dialogue_state = 1
					
					# Show dialogue popup
					dialogue_popup.dialogue = "Hello adventurer! I lost my necklace. Can you find it for me?"
					dialogue_popup.answers = "[A] Yes    [S] No"
					dialogue_popup.open()
				1:
					match answer:
						"A":
							# Update dialogue tree state
							dialogue_state = 2
							
							# Show dialogue popup
							dialogue_popup.dialogue = "Thank you! I last saw it south of here..."
							dialogue_popup.answers = "[A] Bye"
							dialogue_popup.open()
						"S":
							# Update dialogue tree state
							dialogue_state = 3
							
							# Show dialogue popup
							dialogue_popup.dialogue = "Well, if you change your mind, I'll be here."
							dialogue_popup.answers = "[A] Bye"
							dialogue_popup.open()
				2:
					# Update dialogue tree state
					dialogue_state = 0
					
					# Update quest status to accepted
					quest_status = QuestStatus.STARTED
					
					# Close dialogue popup
					dialogue_popup.close()
					
					# Set Fiona's animation to idle
					$AnimatedSprite.play("idle")
				3:
					# Update dialogue state
					dialogue_state = 0
					
					# Close dialogue popup
					dialogue_popup.close()
		QuestStatus.STARTED:
			match dialogue_state:
				0:
					# Update dialogue tree state
					dialogue_state = 1
					
					# Show dialogue popup
					dialogue_popup.dialogue = "Did you find my necklace?"
					
					if necklace_found:
						dialogue_popup.answers = "[A] Yes  [S] No"
					else:
						dialogue_popup.answers = "[A] No"
					dialogue_popup.open()
				1:
					if necklace_found and answer == "A":
						# Update dialogue tree state
						dialogue_state = 2
						
						# Show dialogue popup
						dialogue_popup.dialogue = "You're my hero! Please take this potion as a sign of my gratitude!"
						dialogue_popup.answers = "[A] Thanks"
						dialogue_popup.open()
					else:
						# Update dialogue tree state
						dialogue_state = 3
						
						# Show dialogue popup
						dialogue_popup.dialogue = "Please find it!"
						dialogue_popup.answers = "[A] I will!"
						dialogue_popup.open()
				2:
					# Update dialogue tree state
					dialogue_state = 0
					quest_status = QuestStatus.COMPLETED
					
					# Close dialogue popup
					dialogue_popup.close()
					
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")
					
					# Add potion and XP to the player.
					# Added a little delay in case the level advancement panel appears.
					yield(get_tree().create_timer(0.5), "timeout")
					player.add_potion(Potion.HEALTH)
					player.add_xp(50)
				3:
					# Update dialogue tree state
					dialogue_state = 0
					
					# Close dialogue popup
					dialogue_popup.close()
					
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")
		QuestStatus.COMPLETED:
			match dialogue_state:
				0:
					# Update dialogue tree state
					dialogue_state = 1
					
					# Show dialogue popup
					dialogue_popup.dialogue = "Thanks again for your help!"
					dialogue_popup.answers = "[A] Bye"
					dialogue_popup.open()
				1:
					# Update dialogue tree state
					dialogue_state = 0
					
					# Close dialogue popup
					dialogue_popup.close()
					
					# Set Fiona's animation to "idle"
					$AnimatedSprite.play("idle")
