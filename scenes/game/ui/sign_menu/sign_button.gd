class_name SignButton
extends TextureButton

signal sign_pressed(sign_name)

const my_scene: PackedScene = preload("res://scenes/game/ui/sign_menu/sign_button.tscn")

var sign_name: String


static func new_sign_button(sign_name: String) -> SignButton:
	var new_sign_button: SignButton = my_scene.instantiate()
	new_sign_button.sign_name = sign_name
	new_sign_button.texture_normal = load("res://textures/ui/sign_menu/" + sign_name + ".png")
	return new_sign_button


func _pressed():
	sign_pressed.emit(sign_name)
