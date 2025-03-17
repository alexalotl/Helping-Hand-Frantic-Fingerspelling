class_name PrinterInteractable
extends FocusInteractable

@export var word_list: Array[String]

var word = ""

@onready var exclamation = $Exclamation
@onready var label = $Label3D


func _ready():
	super()
	
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
	game_manager.add_generator(self)
	
	word = word_list.pick_random()
	
	label.text = ""


# TODO Don't run this in process, just update via game manager
func _process(delta):
	var word = game_manager.get_task_data("word", step1player)
	if word:
		set_exclamation.rpc(true)
	else:
		set_exclamation.rpc(false)


func interact(_player_id):
	super(_player_id)
	
	var word = game_manager.get_task_data("word", step1player)
	if word:
		set_text.rpc_id(player_id, word)
	else:
		set_text.rpc_id(player_id, "NOTHING TO DISPLAY")
	
	var player_num: int
	if player_id == 1:
		player_num = 1
	else:
		player_num = 2
	
	game_manager.evaluate_task(null, "word", player_num, 1)


func interact_end():
	super()
	
	set_text.rpc_id(player_id, "")


func create_task() -> Task:
	var task = preload("res://scenes/game/gameplay/task.tscn").instantiate()
	task.step1player = step1player
	task.step2player = step2player
	task.task_type = "word"
	task.time_limit = 120
	task.title = "Word"
	task.step1 = "Get the word from the printer"
	task.step2 = "Input the word into the terminal"
	task.data = word_list.pick_random()
	
	return task


@rpc("authority", "call_local")
func set_exclamation(is_ready: bool):
	exclamation.visible = is_ready


@rpc("any_peer", "call_local")
func set_text(txt):
	label.text = txt
