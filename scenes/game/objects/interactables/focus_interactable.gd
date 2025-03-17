class_name FocusInteractable
extends Interactable

@export var step1player: int
@export var step2player: int
@export var cam: Camera3D


func interact(_player_id):
	set_focus_camera.rpc_id(_player_id)
	InputManager.key_pressed.connect(_on_input_key_pressed)
	
	super(_player_id)


func interact_end():
	super()
	
	InputManager.key_pressed.disconnect(_on_input_key_pressed)
	
	quit_focus_camera.rpc_id(player_id)


func create_task() -> Task:
	var task = preload("res://scenes/game/gameplay/task.tscn").instantiate()
	task.time_limit = 120
	task.title = "Empty"
	task.step1 = "Empty"
	task.step2 = "Empty"
	task.data = "Empty"
	
	return task


@rpc("any_peer", "call_local")
func set_focus_camera():
	CameraManager.set_current_camera(cam)


@rpc("any_peer", "call_local")
func quit_focus_camera():
	CameraManager.revert_camera()


func _on_input_key_pressed(input_id, key):
	key = key.to_upper()
	
	if input_id == player_id:
		if key == "ESCAPE":
			interact_end()
