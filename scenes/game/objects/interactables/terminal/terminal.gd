class_name TerminalInteractable
extends FocusInteractable

const VALID_LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@export var msg: String

var input = ""

@onready var label = $Label3D


func _ready():
	super()
	
	label.text = ""


func add_letter(letter):
	if letter in VALID_LETTERS:
		input += letter
		update_label()
		check_word()


func remove_letter():
	input = input.left(input.length() - 1)
	update_label()


func update_label():
	set_text.rpc_id(player_id, msg + input)


func check_word():
	var player_num: int
	if player_id == 1:
		player_num = 1
	else:
		player_num = 2
	
	game_manager.evaluate_task(input, "word", player_num, 2)


func interact(_player_id):
	super(_player_id)
	
	update_label()


func interact_end():
	super()
	
	set_text.rpc_id(player_id, "")


@rpc("any_peer", "call_local")
func set_text(txt):
	label.text = txt


func _on_input_key_pressed(input_id, key):
	super(input_id, key)
	
	key = key.to_upper()
	if input_id == player_id:
		if key == "BACKSPACE":
			remove_letter()
		else:
			add_letter(key)
