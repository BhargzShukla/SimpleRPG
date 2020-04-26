extends Popup

var npc_name setget name_set
var dialogue setget dialogue_set
var answers setget answers_set
var npc

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A:
			set_process_input(false)
			npc.talk("A")
		elif event.scancode == KEY_S:
			set_process_input(false)
			npc.talk("S")

func name_set(new_value):
	npc_name = new_value
	$ColorRect/NPCName.text = npc_name

func dialogue_set(new_value):
	dialogue = new_value
	$ColorRect/DialogueText.text = dialogue

func answers_set(new_value):
	answers = new_value
	$ColorRect/AnswerText.text = answers

func open():
	get_tree().paused = true
	popup()
	$ColorRect/DialogueText/AnimationPlayer.playback_speed = 60.0 / dialogue.length()
	$ColorRect/DialogueText/AnimationPlayer.play("ShowDialogue")

func close():
	get_tree().paused = false
	hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	set_process_input(true)
