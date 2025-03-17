extends Node

# Player control inputs.
signal moved(direction)
signal jumped(delta)
signal interacted()
# Camera control inputs
signal cam_rotated(rot_event_x, rot_event_y)
signal zoomed_in()
signal zoomed_out()
# Interactable inputs
signal key_pressed(key)
# UI control inputs
signal sign_menu_toggled()
# Multiplayer inputs
signal host_pressed()
signal join_pressed()
signal server_restart_pressed()
signal ready_pressed()

enum State {
	PLAYER,
	UI,
	INTERACT
}

var cam_rot = Vector3.ZERO
var current_state = State.PLAYER


func _ready():
	Input.set_mouse_mode(2)


func _process(delta):
	match current_state:
		State.PLAYER:
			var direction = Vector3.ZERO
			var target_velocity = Vector3.ZERO 
			
			if Input.is_action_pressed("move_right"):
				direction.x += 1
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
			if Input.is_action_pressed("move_back"):
				direction.z += 1
			if Input.is_action_pressed("move_forward"):
				direction.z -= 1
			
			if direction != Vector3.ZERO:
				direction = direction.normalized().rotated(Vector3(0, 1, 0), get_viewport().get_camera_3d().global_rotation.y)
			
			move.rpc_id(1, direction)
			
			if Input.is_action_pressed("jump"):
				jump.rpc_id(1)


func _input(event):
	match current_state:
		State.PLAYER:
			if event is InputEventMouseMotion:
				# modify accumulated mouse rotation
				var rot_event_x = event.relative.x
				var rot_event_y = event.relative.y
				
				rotate_camera.rpc_id(1, rot_event_x, rot_event_y)
			
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					zoom_out.rpc_id(1)
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					zoom_in.rpc_id(1)
			
			if event.is_action_pressed("interact"):
				interact.rpc_id(1)
			# TODO Add a proper pause menu here.
			if event.is_action_pressed("pause"):
				quit_game.rpc()
			if event.is_action_pressed("toggle_sign_menu"):
				sign_menu_toggled.emit()
		State.INTERACT:
			# TODO Make sure that the keyboard is free when interacting with objects,
			# as currently the player cannot type the letter E in the terminal
			if event is InputEventKey:
				if event.pressed:
					var key = event.as_text()
					key_press.rpc_id(1, key)
		State.UI:
			if event.is_action_pressed("toggle_sign_menu"):
				sign_menu_toggled.emit()
	
	if event.is_action_pressed("server_restart"):
		server_restart_pressed.emit()
		
	if event.is_action_pressed("ready"):
		ready_pressed.emit()


@rpc("any_peer", "call_local")
func quit_game():
	get_tree().quit()


@rpc("any_peer", "call_local", "reliable")
func move(direction):
	moved.emit(direction, multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local", "reliable")
func jump():
	jumped.emit(multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local")
func interact():
	interacted.emit(multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local")
func rotate_camera(rot_event_x, rot_event_y):
	cam_rotated.emit(rot_event_x, rot_event_y, multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local")
func zoom_out():
	zoomed_out.emit(multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local")
func zoom_in():
	zoomed_in.emit(multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local")
func key_press(key):
	key_pressed.emit(multiplayer.get_remote_sender_id(), key)


@rpc("any_peer", "call_local")
func change_state(next_state):
	match next_state:
		"player":
			print("SETTING STATE TO PLAYER")
			Input.set_mouse_mode(2)
			current_state = State.PLAYER
		"ui":
			print("SETTING STATE TO UI")
			Input.set_mouse_mode(0)
			current_state = State.UI
		"interact":
			print("SETTING STATE TO INTERACT")
			Input.set_mouse_mode(0)
			current_state = State.INTERACT
