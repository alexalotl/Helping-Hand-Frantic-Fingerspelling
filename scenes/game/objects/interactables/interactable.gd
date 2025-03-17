class_name Interactable
extends Node3D

signal interaction_ended()

@export var game_manager: GameManager

var is_interacting = false
var player_id


func _ready():
	InputManager.interacted.connect(_on_input_interacted)


func interact(_player_id):
	player_id = _player_id
	InputManager.change_state.rpc_id(player_id, "interact")
	
	await get_tree().create_timer(0.1).timeout
	is_interacting = true


func interact_end():
	InputManager.change_state.rpc_id(player_id, "player")
	interaction_ended.emit()
	is_interacting = false


func _on_input_interacted(input_id):
	if input_id == player_id and is_interacting:
		interact_end()
