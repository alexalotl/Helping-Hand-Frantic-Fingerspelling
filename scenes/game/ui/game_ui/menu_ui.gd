extends MarginContainer

enum State {
	MAIN,
	LEVELSELECT,
}

var current_state = State.MAIN

@onready var main_menu = $MainMenu
@onready var level_select_menu = $LevelSelectMenu


func _ready():
	start()


func change_state(next_state):
	match next_state:
		"level_select":
			main_menu.visible = false
			level_select_menu.visible = true
			current_state = State.LEVELSELECT
		"main":
			main_menu.visible = true
			level_select_menu.visible = false
			current_state = State.MAIN


func start():
	main_menu.visible = true
	level_select_menu.visible = false
