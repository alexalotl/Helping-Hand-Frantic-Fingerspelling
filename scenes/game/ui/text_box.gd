extends Control

const CHAR_READ_RATE = 0.05

signal text_finished

enum State {
	READY,
	WRITING,
	FINISHED
}

@onready var text = $TextBoxContainer/TextBoxPanel/MarginContainer/HBoxContainer/Text
@onready var end = $TextBoxContainer/TextBoxPanel/MarginContainer/End
@onready var container = $TextBoxContainer
@onready var tween

var current_state = State.READY
var text_queue = []


func _ready():
	hide_text()


func _process(delta):
	match current_state:
		State.READY:
			if not text_queue.is_empty():
				display_text()
		State.WRITING:
			if Input.is_action_just_pressed("interact"):
				tween.kill()
				text.visible_ratio = 1.0
				end_text()
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("interact"):
				tween.kill()
				hide_text()
				if text_queue.is_empty():
					text_finished.emit()
				change_state(State.READY)


func queue_text(next_text):
	text_queue.push_back(next_text)


func hide_text():
	text.text = ""
	end.text = ""
	container.hide()


func clear_text():
	text_queue.clear()
	hide_text()
	change_state(State.READY)


func show_text():
	container.show()


func display_text():
	var next_text = text_queue.pop_front()
	text.text = next_text
	change_state(State.WRITING)
	text.visible_ratio = 0.0
	show_text()
	tween = get_tree().create_tween()
	tween.connect("finished", _on_finished)
	tween.tween_property(text, "visible_ratio", 1.0, CHAR_READ_RATE * len(next_text))


func end_text():
	end.text = "E"
	end.set_visible_characters(-1)
	tween = get_tree().create_tween().set_loops()
	tween.tween_callback(end.set_visible_characters.bind(0)).set_delay(0.8)
	tween.tween_callback(end.set_visible_characters.bind(-1)).set_delay(0.3)


func change_state(next_state):
	current_state = next_state


func _on_finished():
	end_text()
	change_state(State.FINISHED)
