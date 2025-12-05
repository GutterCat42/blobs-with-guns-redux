extends Control


func _ready():
	$Sprite.rotation_degrees = -rect_rotation


func _on_TextureButton_pressed():
	get_owner().switch_to(int(name))
