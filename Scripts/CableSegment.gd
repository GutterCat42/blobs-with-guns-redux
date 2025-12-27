extends RigidBody2D


export(float) var hp = 1


func turn_lamp_off():
	var lamp = get_parent().get_node_or_null("LampShade")
	if lamp:
		lamp.turn_off()
	else:
		lamp = get_parent().get_node_or_null("Lightbulb")
		if lamp:
			lamp.turn_off()
		else:
			return false

func get_hit(damage=1, a=1, b=2, c=3, d=4):
	hp -= damage
	if hp <= 0:
		turn_lamp_off()
		queue_free()
