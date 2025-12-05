extends RigidBody2D


export(float) var hp = 1


func turn_lamp_off(name="LampShade"):
	var lamp = get_parent().get_node_or_null(name)
	if lamp:
		lamp.turn_off()
	else:
		if name == "LightBulb":
			return false
		else:
			turn_lamp_off("LightBulb")

func get_hit(damage=1, a=1, b=2, c=3, d=4):
	hp -= damage
	if hp <= 0:
		turn_lamp_off()
		queue_free()
