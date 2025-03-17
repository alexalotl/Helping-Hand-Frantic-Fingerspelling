extends Control

signal text_finished()
signal sign_pressed(sign_name, ui_id: int)
signal level_selected(level: PackedScene)
signal host_pressed()
signal join_pressed(ip: String)
signal next_level_pressed()
signal restart_level_pressed()

enum State {
	GAME,
	MENU,
}

var current_state = State.GAME

@onready var game_ui = $Canvas/GameUI
@onready var menu_ui = $Canvas/MenuUI
@onready var scorebox = $Canvas/GameUI/Score
@onready var timer = $Canvas/GameUI/Timer
@onready var task_container = $Canvas/GameUI/Tasks/MarginContainer/GridContainer
@onready var textbox = $Canvas/GameUI/TextArea/TextContainer/TextBox
@onready var signmenu = $Canvas/GameUI/SignMenu
@onready var endmenu = $Canvas/GameUI/EndMenu
@onready var levelmenu = $Canvas/MenuUI/LevelSelectMenu
@onready var readylabel = $Canvas/GameUI/Ready/ReadyContainer/ReadyLabel


func change_state(next_state):
	match next_state:
		"game":
			print("SETTING STATE TO GAME")
			menu_ui.visible = false
			game_ui.visible = true
			game_ui.start()
			current_state = State.GAME
			
		"menu":
			print("SETTING STATE TO MENU")
			menu_ui.visible = true
			game_ui.visible = false
			menu_ui.start()
			current_state = State.MENU


func set_ready(num):
	readylabel.text = "Ready " + str(num) + "/2"


func show_ready():
	readylabel.visible = true


func hide_ready():
	readylabel.visible = false


func set_player_count(count):
	levelmenu.set_player_count(count)


func show_end_panel(stars: int, score: int):
	clear_task_panels()
	clear_signs()
	textbox.clear_text()
	set_ready(0)
	
	endmenu.set_stars(stars)
	endmenu.set_score(score)
	endmenu.show_panel()


func set_star_point_boundaries(star1boundary: int, star2boundary: int, star3boundary: int):
	endmenu.set_star_point_boundaries(star1boundary, star2boundary, star3boundary)


func clear_end_panel():
	endmenu.show_panel()
	
func queue_text(next_text):
	textbox.queue_text(next_text)


func add_signs(signs: Array[String]):
	signmenu.add_signs(signs)


func set_time_left(time_left: int):
	timer.set_time_left(time_left)


func set_score(score):
	scorebox.set_score(score)


func create_task_panel(task):
	var task_panel = TaskPanel.new_task_panel(task)
	task_container.add_child(task_panel)


func clear_task_panels():
	for task_panel in task_container.get_children():
		task_panel.queue_free()


func clear_signs():
	signmenu.clear_signs()


func _on_text_written(next_text):
	queue_text(next_text)


func _on_text_finished():
	text_finished.emit()


func _on_sign_pressed(sign_name):
	sign_pressed.emit(sign_name, multiplayer.get_unique_id())


func _on_main_menu_play_pressed():
	menu_ui.change_state("level_select")


func _on_level_selected(level: PackedScene):
	level_selected.emit(level)


func _on_join_pressed(ip):
	join_pressed.emit(ip)


func _on_host_pressed():
	host_pressed.emit()


func _on_next_level_pressed():
	next_level_pressed.emit()


func _on_restart_level_pressed():
	restart_level_pressed.emit()
