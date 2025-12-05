extends Area2D


export(float) var bulletSpeed = 500.0
export(Vector2) var velocity = Vector2.ZERO
export(float) var inaccuracy = 2.0
export(bool) var curvy = true
export(float) var bulletRange = 420.0
export(int) var numSplats = 10
export(float) var splatSpread = 45.0
export(float) var initialDamage = 1
export(float) var finalDamage = 0.5
export(int) var armourPiercing = 0
export(float) var proximityKillThresh = 84.0
export(float) var longShotThresh = 420.0
export(bool) var makeParticleTrail = false

export(PackedScene) var Trail = preload("res://Scenes/Projectiles/BulletTrail.tscn")
export(PackedScene) var LineTrail = preload("res://Scenes/Projectiles/SmokeTrail.tscn")

var tricks = []
var shot_from
var curve
var startPos
var ricocheted = false
var initialPiercing
var t = null


func _ready():
	curve = rand_range(-inaccuracy, inaccuracy)
	
	if not curvy:
		rotation_degrees += curve
	
	startPos = global_position
	
	initialPiercing = armourPiercing
	
	var l = LineTrail.instance()
	get_parent().add_child(l)
	l.global_position = Vector2.ZERO
	l.global_scale = Vector2.ONE
	l.global_rotation_degrees = 0
	l.target = self


func _physics_process(delta):
	if (global_position - startPos).length() >= bulletRange:
		queue_free()
	
	position += velocity + Vector2(bulletSpeed, 0).rotated(rotation) * delta
	
	if curvy:
		rotation_degrees += curve * delta * 100
	
	if makeParticleTrail:
		if t == null:
			t = Trail.instance()
			get_parent().add_child(t)
		else:
			t.global_transform = global_transform
	
	$RayCast2D.cast_to = Vector2(bulletSpeed * delta, 0)
	if $RayCast2D.is_colliding():
		position = $RayCast2D.get_collision_point()
		_on_Bullet_body_entered($RayCast2D.get_collider())


func _on_Bullet_body_entered(body):
	if body.is_in_group("Walls"):
		var d = $DebrisParticles
		remove_child(d)
		get_parent().add_child(d)
		if is_instance_valid(d):
			d.global_transform = global_transform
			d.get_node("AnimationPlayer").play("go")
		queue_free()
	
	if body.is_in_group("Grenades"):
		body.explode()
		armourPiercing -= 1
	if body.is_in_group("Hitable") and body != shot_from:
		armourPiercing -= 1
		
		if (global_position - startPos).length() <= proximityKillThresh:
			tricks.append("Proximity")
		if (global_position - startPos).length() >= longShotThresh:
			tricks.append("Long shot")
		if ricocheted:
			tricks.append("Ricochet")
		
		body.get_hit(initialDamage - (initialDamage - finalDamage) * ((global_position - startPos).length() / bulletRange), rotation, body.global_position - global_position, tricks, initialDamage - armourPiercing)
	
	if armourPiercing < 0:
		queue_free()


func _on_Bullet_area_entered(area):
	if area.is_in_group("RicochetWalls") and not ricocheted:
		rotation_degrees = ((((0) - (rotation_degrees)) - ((2) * (area.rotation_degrees))) + (180))
		ricocheted = true
