extends RigidBody2D

export(PackedScene) var Explosion = preload("res://Scenes/Explosion.tscn")
export(PackedScene) var Noise = preload("res://Scenes/Noise.tscn")
export(float) var fuse = 3.0


func _ready():
	$ExplosionTimer.wait_time = fuse
	$ExplosionTimer.start()


func explode():
	var e = Explosion.instance()
	get_parent().add_child(e)
	e.global_transform = global_transform
	queue_free()


func _on_ExplosionTimer_timeout():
	explode()


func _on_HandGrenade_body_entered(body):
	if body.is_in_group("Walls"):
		var n = Noise.instance()
		get_parent().add_child(n)
		n.global_transform = global_transform
		n.playerOrNull = self
