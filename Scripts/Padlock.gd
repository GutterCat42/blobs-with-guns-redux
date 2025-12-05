extends StaticBody2D


export(PackedScene) var Sparks = preload("res://Scenes/SmashParticles.tscn")



func get_hit(damage, rotation, offset=Vector2.ZERO, otherthingthatdoesntexist=1, othergarbo=1):
	var b = Sparks.instance()
	b.global_transform = global_transform
	b.rotation = rotation
	b.modulate = Color.gold
	b.scale = Vector2.ONE
	get_parent().add_child(b)
	
	queue_free()
