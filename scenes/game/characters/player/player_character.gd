extends CharacterBody3D
var can_run: bool = true
## How fast the player can move horizontally in meters per second.
@export var max_speed = 14.0
@export var max_air_speed = 8.0
@export var acceleration = 10.0
## The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 20.0
## The force put onto the character when the jump button is pressed. A high force
## will increase jump height.
@export var jump_force = 450.0
## Max speed for falling, should be a negative value.
@export var terminal_velocity = -10.0
@export var can_jump = true
@export var player_id : int = 1

var target_velocity = Vector3.ZERO
var close_object: Interactable
var is_jumping = false
var is_interacting = false

@onready var focus = $Focus
@onready var sign_panel = $SignPanel
@onready var sign_texture = $SignPanel/SignTexture

func _ready():
	InputManager.moved.connect(_on_input_moved)
	InputManager.jumped.connect(_on_input_jumped)
	InputManager.interacted.connect(_on_input_interacted)
	UIManager.sign_pressed.connect(_on_sign_pressed)
	
	sign_panel.visible = false


func _physics_process(delta):
	# Falling.
	if not is_on_floor(): 
		# If in the air, fall towards the floor.
		velocity.y = velocity.y - (fall_acceleration * delta)
		if velocity.y < terminal_velocity:
			velocity.y = terminal_velocity
	elif is_jumping:
		apply_force(Vector3(0.0, jump_force, 0.0), delta)
		is_jumping = false
	
	# Moving the Character
	velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
	
	move_and_slide()


func jump():
	if can_jump and is_on_floor() and not is_interacting:
		is_jumping = true


func move(direction):
	# TODO Probably doesn't need this check anymore, but velocity needs to be 
	# reset.
	if not is_interacting:
		target_velocity = Vector3.ZERO
		
		# Ground Movement Control.
		if is_on_floor():
			target_velocity.x = direction.x * max_speed
			target_velocity.z = direction.z * max_speed
		
		# Air Movement Control.
		if not is_on_floor(): 
			# TODO THIS IS LIKELY BETTER HANDLED WITH REDUCING THE EFFECT OF 
			# ACCELERATION IN THE AIR RATHER THAN LIMITING SPEED. NEEDS FURTHER 
			# INVESTIGATION BUT IS GOOD ENOUGH FOR NOW.
			target_velocity.x = direction.x * max_air_speed
			target_velocity.z = direction.z * max_air_speed


# NOTE I SET UP THIS FUNCTION SO THAT IF WE NEED EFFECTS LIKE RECOIL LATER IT 
# SHOULD BE CLEANER TO IMPLEMENT
func apply_force(force, delta):
	velocity = force * delta


func get_focus():
	return focus


@rpc("any_peer", "call_local")
func set_sign(sign_name):
	sign_texture.texture_albedo = load("res://textures/ui/sign_menu/" + sign_name + "_blank.png")


@rpc("any_peer", "call_local")
func show_sign(rot):
	self.rotation = rot
	
	sign_panel.visible = true
	$SignDisplayTimer.start()


func _on_input_moved(direction, input_id):
	if input_id == player_id:
		move(direction)


func _on_input_jumped(input_id):
	if input_id == player_id:
		jump()


func _on_input_interacted(input_id):
	if input_id == player_id and not is_interacting:
		print("STARTING INTERACTION - ", close_object, " ", player_id)
		
		if close_object and not close_object.is_interacting:
			is_interacting = true
			close_object.interaction_ended.connect(_on_interaction_ended)
			
			close_object.interact(player_id)


func _on_interaction_ended():
	print("ENDING INTERACTION - ", close_object, " ", player_id)
	
	# Reset velocity
	velocity = Vector3.ZERO
	
	close_object.interaction_ended.disconnect(_on_interaction_ended)
	await get_tree().create_timer(0.1).timeout
	is_interacting = false


# TODO Make sure that the detected object is interactable.
func _on_detection_area_body_entered(body):
	print("ENTERED AREA OF ", body.name)
	
	close_object = body


func _on_detection_area_body_exited(body):
	if body == close_object:
		print("EXITED AREA OF ", close_object)
		
		close_object = null


func _on_sign_pressed(sign_name, input_id):
	if input_id == player_id:
		print("PLAYER NOW PERFORMING SIGN " + sign_name)
		
		set_sign.rpc(sign_name)
		
		var rot = Vector3(0, get_viewport().get_camera_3d().global_rotation.y, 0)
		show_sign.rpc(rot)


func _on_cooldown_timeout():
	can_run = true


func _on_run_duration_timeout():
	max_speed -= 5
	$Cooldown.start()


func _on_sign_display_timer_timeout():
	sign_panel.visible = false
