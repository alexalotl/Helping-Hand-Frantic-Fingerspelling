class_name GameManager
extends Node

@export var time_limit = 180
@export var star1_score: int
@export var star2_score: int
@export var star3_score: int
@export var score: int = 0 :
	set(_score):
		score = _score
		update_score()
		if multiplayer.get_unique_id() == 1:
			set_hints(score)
@export var time_left : int :
	set(t):
		time_left = t
		UIManager.set_time_left(t)
@export var signs: Array[String]
@export var intro_text: Array[String]
@export var ready_players: int = 0 :
	set(num):
		ready_players = num
		UIManager.set_ready(num)
@export var intercoms: Array[IntercomInteractable]
@export var hint0 : Array[String]
@export var hint1 : Array[String]
@export var hint2 : Array[String]
@export var hint3 : Array[String]

var task_generators: Array[FocusInteractable]
var tasks: Array[Task]
var is_ready = false

@onready var level_timer = $LevelTimer
@onready var spawn_timer = Timer.new()


func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
	level_timer.wait_time = time_limit
	
	update_score()
	
	UIManager.add_signs(signs)
	UIManager.set_star_point_boundaries(star1_score, star2_score, star3_score)
	UIManager.show_ready()
	
	InputManager.ready_pressed.connect(_on_ready_pressed)
	
	for line in intro_text:
		UIManager.queue_text(line)
	
	if multiplayer.get_unique_id() == 1:
		level_timer.paused = true
		level_timer.start()

func _process(delta):
	time_left = level_timer.time_left


@rpc("authority", "call_local")
func set_hints(current_score):
	for intercom in intercoms:
		if current_score >= star3_score:
			intercom.set_text.rpc(hint3)
		elif current_score >= star2_score:
			intercom.set_text.rpc(hint2)
		elif current_score >= star1_score:
			intercom.set_text.rpc(hint1)
		else:
			intercom.set_text.rpc(hint0)
			


@rpc("authority", "call_local")
func create_task():
	var gen = task_generators.pick_random()
	var task: Task = gen.create_task()
	
	task.succeeded.connect(_on_task_succeeded)
	task.failed.connect(_on_task_failed)
	$Tasks.add_child(task, true)
	tasks.append(task)


# TODO Clean up this code, it can certainly be made much nicer
@rpc("authority", "call_local")
func evaluate_task(input, task_type, player, step):
	for task in tasks:
		if task_type == task.task_type:
			if step == 1 and task.current_step == 0:
				if player == task.step1player:
					task.current_step += 1
					return
			elif step == 2 and task.current_step == 1:
				if player == task.step2player:
					if input == task.data:
						task.current_step += 1
						return


@rpc("authority", "call_local")
func get_task_data(task_type, player):
	for task in tasks:
		if task_type == task.task_type:
			if task.current_step == 0 and player == task.step1player:
				return task.data
	return null


@rpc("authority", "call_local")
func add_generator(gen: FocusInteractable):
	task_generators.append(gen)


@rpc("authority", "call_local")
func add_score(points):
	score += points


@rpc("authority", "call_local")
func reset_score():
	score = 0


func update_score():
	UIManager.set_score(score)


@rpc("authority", "call_local")
func end_level(stars, score):
	InputManager.change_state("ui")
	UIManager.show_end_panel(stars, score)
	get_tree().paused = true


@rpc("authority", "call_local")
func clear_task(task):
	tasks.erase(task)


@rpc("authority", "call_local")
func start_level():
	if multiplayer.get_unique_id() == 1:
		set_hints(0)
		
		level_timer.paused = false
		
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.wait_time = 1
		spawn_timer.one_shot = true
		spawn_timer.autostart = true
		
		add_child(spawn_timer)
	UIManager.hide_ready()
	

@rpc("any_peer", "call_local")
func ready_player():
	ready_players += 1
	if ready_players == 2:
		start_level.rpc()

@rpc("authority", "call_local")
func _on_spawn_timer_timeout():
	if task_generators.size() > 0 and tasks.size() < 5:
		create_task()
	spawn_timer.stop()
	spawn_timer.wait_time = randi_range(2, 4)
	spawn_timer.start()


@rpc("authority", "call_local")
func _on_task_succeeded(task: Task):
	add_score(task.points)
	clear_task(task)


@rpc("authority", "call_local")
func _on_task_failed(task: Task):
	add_score(task.points_for_failing)
	clear_task(task)


@rpc("authority", "call_local")
func _on_level_timer_timeout():
	print("TIME'S UP!")
	var stars = 0
	if score >= star3_score:
		stars = 3
	elif score >= star2_score:
		stars = 2
	elif score >= star1_score:
		stars = 1
		
	end_level.rpc(stars, score)
	
	
func _on_ready_pressed():
	if not is_ready:
		InputManager.ready_pressed.disconnect(_on_ready_pressed)
		is_ready = true
		ready_player.rpc_id(1)
