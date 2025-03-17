class_name TaskPanel
extends Control

const my_scene: PackedScene = preload("res://scenes/game/ui/task_ui.tscn")
const p1_theme: Theme = preload("res://themes/task_ui_player_1.tres")
const p2_theme: Theme = preload("res://themes/task_ui_player_2.tres")

var task: Task

@onready var title = $MarginContainer/Panel/VBoxContainer/Title
@onready var step1 = $MarginContainer/Panel/VBoxContainer/Step1
@onready var step2 = $MarginContainer/Panel/VBoxContainer/Step2
@onready var timer_bar = $MarginContainer/Panel/VBoxContainer/ProgressBar
@onready var data = $MarginContainer/Panel/VBoxContainer/Data


static func new_task_panel(task: Task) -> TaskPanel:
	var task_panel = my_scene.instantiate()
	task_panel.task = task
	
	return task_panel


func _ready():
	if task.step1player == 1:
		$MarginContainer/Panel.theme = p1_theme
	else:
		$MarginContainer/Panel.theme = p2_theme
	task.succeeded.connect(_on_task_succeeded)
	task.failed.connect(_on_task_failed)
	task.step_completed.connect(_on_task_step_completed)
	
	title.text = task.title
	step1.text = "- " + task.step1
	step2.text = "- " + task.step2
	timer_bar.max_value = task.time_limit
	data.text = "???"


func _process(delta):
	timer_bar.value = task.time_left


func _on_task_succeeded(task):
	print("TASK COMPLETE")
	queue_free()


func _on_task_failed(task):
	queue_free()


func _on_task_step_completed(step: int):
	if step >= 1:
		if ((multiplayer.get_unique_id() == 1 and task.step1player == 1)
		or (multiplayer.get_unique_id() != 1 and task.step1player == 2)):
			data.text = task.data
