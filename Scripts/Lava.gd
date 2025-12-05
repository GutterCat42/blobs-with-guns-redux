extends Area2D


export(float) var speed = 30.0
export(float) var damage = 1.0

var can_damage = true


func _physics_process(delta):
	global_position.y -= speed * delta
	for body in get_overlapping_bodies():
		if body.is_in_group("Hitable") and can_damage:
			body.get_hit(damage)
			can_damage = false
			$Timer.start()


func _on_Timer_timeout():
	can_damage = true
