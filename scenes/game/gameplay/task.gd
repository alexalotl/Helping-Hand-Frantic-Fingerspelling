class_name Task
extends Node

signal succeeded(task: Task)
signal failed(task: Task)
signal step_completed(step: int)

@export var current_step = 0 :
	set(step):
		current_step = step
		if multiplayer.get_unique_id() == 1:
			step_complete.rpc(current_step)
			if current_step == 2:
				success.rpc()
@export var time_left = 0
@export var time_limit: int
@export var step1player: int
@export var step2player: int
@export var points_per_time_remaining: int = 20
@export var points_for_failing: int = -20
@export var task_type: String
@export var title: String
@export var step1: String
@export var step2: String
@export var data: String

var points : int :
	get:
		return int(30 + points_per_time_remaining * (timer.time_left / timer.wait_time))

@onready var timer: Timer = $Timer


func _ready():
	timer.wait_time = time_limit
	
	UIManager.create_task_panel(self)
	
	timer.start()


func _process(delta):
	if multiplayer.get_unique_id() == 1:
		time_left = timer.time_left


@rpc("authority", "call_local")
func success():
	succeeded.emit(self)
	queue_free()


@rpc("authority", "call_local")
func fail():
	failed.emit(self)
	queue_free()


@rpc("authority", "call_local")
func step_complete(step: int):
	step_completed.emit(step)


func _on_timer_timeout():
	if multiplayer.get_unique_id() == 1:
		fail.rpc()
