extends Area2D


export(float) var upRate = 2
export(float) var upDecay = 0.98
export(float) var fadeDecay = 0.99
export(float) var fadeKillThresh = 0.05
export(int) var popupNum = 1

var set_size = false


func set_collider_size():
	$CollisionShape2D.position = $Label.rect_size / 2
	$CollisionShape2D.shape.extents = Vector2($CollisionShape2D.position.y, $CollisionShape2D.position.x)
	set_size = true


func _process(delta):
	rotation_degrees = 0
	upRate *= upDecay
	global_position.y -= upRate
	if modulate.a > fadeKillThresh:
		modulate.a *= fadeDecay
	else:
		queue_free()
	
	if not set_size:
		set_collider_size()


func _on_PopupText_area_entered(area):
	if area.is_in_group("PopupText"):
		if area.popupNum > popupNum:
			$Label.text += "\n" + area.get_node("Label").text
			area.queue_free()
			set_collider_size()
