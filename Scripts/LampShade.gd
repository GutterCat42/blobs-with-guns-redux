extends RigidBody2D


export(float) var hp = 1
export(PackedScene) var Spray = preload("res://Scenes/SmashParticles.tscn")
export(Color) var hitColour = Color(0.2, 0.2, 0.2, 1)


func get_hit(damage=1, sprayAngle=0, thingidontneed=Vector2.ZERO, otherthingidontneed=1, yetanotherthingidontneed=1):
	var sp = Spray.instance()
	owner.add_child(sp)
	sp.global_transform = global_transform
	sp.rotation = sprayAngle
	sp.modulate = hitColour
	
	hp -= 1
	
	if hp <= 0:
		turn_off()
		$Sprite.modulate = hitColour


func turn_off():
	$Light2D.enabled = false
