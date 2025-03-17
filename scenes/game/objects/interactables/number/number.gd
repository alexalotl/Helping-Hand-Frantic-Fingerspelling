class_name NumberInteractable
extends FocusInteractable

@export var number_list: Array[int]

var random_number: int

@onready var label = $Label3D
@onready var exclamation = $Exclamation


func _ready():
	super()
	
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
	game_manager.add_generator(self)
	
	random_number = number_list.pick_random()
	
	label.text = ""


# TODO Don't run this in process, just update via game manager
func _process(delta):
	var num = game_manager.get_task_data("number", step1player)
	if num:
		set_exclamation.rpc(true)
	else:
		set_exclamation.rpc(false)


func interact(_player_id):
	super(_player_id)
	
	var num = game_manager.get_task_data("number", step1player)
	if num:
		set_text.rpc_id(player_id, str(num))
	else:
		set_text.rpc_id(player_id, "NOTHING TO DISPLAY")
	
	var player_num: int
	if player_id == 1:
		player_num = 1
	else:
		player_num = 2
	
	game_manager.evaluate_task(null, "number", player_num, 1)


func interact_end():
	super()
	set_text.rpc_id(player_id, "")


func create_task() -> Task:
	var task = preload("res://scenes/game/gameplay/task.tscn").instantiate()
	task.step1player = step1player
	task.step2player = step2player
	task.task_type = "number"
	task.time_limit = 80
	task.title = "Number"
	task.step1 = "Get the number from the yellow display"
	task.step2 = "Input the number with the blue button"
	task.data = str(number_list.pick_random())
	
	return task


@rpc("authority", "call_local")
func set_exclamation(is_ready: bool):
	exclamation.visible = is_ready


@rpc("any_peer", "call_local")
func set_text(txt):
	label.text = txt
