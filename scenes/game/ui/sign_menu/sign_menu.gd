extends Control

signal sign_pressed(sign_name)

var signs: Array[String]

@onready var container = $MarginContainer
@onready var grid_container = $MarginContainer/Panel/MarginContainer/ScrollContainer/GridContainer


func _ready():
	InputManager.sign_menu_toggled.connect(_on_menu_toggled)
	
	container.set_visible(false)
	
	for sign in signs:
		add_sign(sign)


func toggle_menu():
	if container.is_visible() == false:
		mouse_filter
		container.set_visible(true)
		InputManager.change_state("ui")
	else:
		container.set_visible(false)
		InputManager.change_state("player")


func add_sign(sign_name):
	var sign_button := SignButton.new_sign_button(sign_name)
	sign_button.sign_pressed.connect(_on_sign_button_pressed)
	grid_container.add_child(sign_button)


func add_signs(signs: Array[String]):
	for sign in signs:
		add_sign(sign)


func clear_signs():
	for sign_button in grid_container.get_children():
		sign_button.queue_free()


func _on_sign_button_pressed(sign_name):
	sign_pressed.emit(sign_name)


func _on_menu_toggled():
	toggle_menu()
