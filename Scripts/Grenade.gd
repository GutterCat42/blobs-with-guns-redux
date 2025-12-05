extends RigidBody2D


export(PackedScene) var Explosion = preload("res://Scenes/Explosion.tscn")

export(float) var force = 200.0

var shot_from


func shoot(neg=false):
	if neg:
		apply_central_impulse(Vector2(-force, 0).rotated(rotation))
	else:
		apply_central_impulse(Vector2(force, 0).rotated(rotation))


func explode():
	var e = Explosion.instance()
	e.global_transform = global_transform
	get_parent().add_child(e)
	queue_free()


func _on_Grenade_body_entered(body):
	if body != shot_from:
		explode()


func _on_ArmTimer_timeout():
	collision_mask = 1
