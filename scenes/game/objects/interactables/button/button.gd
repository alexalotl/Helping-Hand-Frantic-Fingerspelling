class_name ButtonInteractable
extends FocusInteractable

const VALID_NUMBERS = [0, 1, 2, 3, 4, 5]

@export var msg: String

var press_count = 0

@onready var label = $Label3D


func _ready():
	super()
	
	label.text = ""


func add_press():
	press_count += 1
	
	set_text.rpc_id(player_id, "PRESS COUNT: " + str(press_count))


func check_number():
	var player_num: int
	if player_id == 1:
		player_num = 1
	else:
		player_num = 2
		
	game_manager.evaluate_task(str(press_count), "number", player_num, 2)

func interact(_player_id):
	super(_player_id)
	
	set_text.rpc_id(player_id, "PRESS COUNT: " + str(press_count))


func interact_end():
	super()
	
	press_count = 0
	set_text.rpc_id(player_id, "")


@rpc("any_peer", "call_local")
func set_text(txt):
	label.text = txt


func _on_input_key_pressed(input_id, key):
	super(input_id, key)
	
	key = key.to_upper()
	if input_id == player_id:
		if key == "SPACE":
			add_press()
		elif key == "ENTER":
			check_number()
