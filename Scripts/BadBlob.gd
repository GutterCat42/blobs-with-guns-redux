extends RigidBody2D


export(PackedScene) var Gun = preload("res://Scenes/Guns/Pistol.tscn")
export(PackedScene) var PickupScene = preload("res://Scenes/Pickup.tscn")
export(PackedScene) var Spray = preload("res://Scenes/Blobs/BlobSpray.tscn")

export(float) var aimSpeed = 5.0
export(float) var fireThresh = 10.0
export(float) var fireTimerVariation = 0.1
export(float) var hp = 2

var target = false
var ready_to_fire = true
var normTimerTime
var g
var dropping = false
var possibleThingICarHear = null


func get_hit(damage=1, sprayAngle=0):
	hp -= damage
	
	var sp = Spray.instance()
	owner.add_child(sp)
	sp.global_transform = global_transform
	sp.rotation = sprayAngle
	sp.color = $CollisionPolygon2D/Sprite.modulate
	
	if hp < 1 and not dropping:
		dropping = true
		var drop = PickupScene.instance()
		drop.item = Gun
		drop.itemName = g.name
		drop.tex = get_node(str(g.get_path()) + "/Sprite").texture
		owner.add_child(drop)
		drop.global_transform = global_transform
		
		queue_free()


func _ready():
	g = Gun.instance()
	$CollisionPolygon2D/GunHand.add_child(g)
	g.world = owner
	g.shooter = self
	g.global_transform = $CollisionPolygon2D/GunHand.global_transform
	g.equip()
	g.infiniteReloads = true
	
	normTimerTime = $Timer.wait_time


func _physics_process(_delta):
	if target:
		if g.get_angle_to(target.position) > 0:
			g.rotate(deg2rad(aimSpeed))
		else:
			g.rotate(deg2rad(-aimSpeed))
		
		$CollisionPolygon2D.scale.x = 1 - 2 * int(target.position.x < position.x)
		$CollisionPolygon2D/GunHand.scale.x = 1 - 2 * int(target.position.x < position.x)
		g.scale.y = 1 - 2 * int(target.position.x < position.x)
		
		# and $CollisionPolygon2D/GunHand/RayCast2D.is_colliding() and $CollisionPolygon2D/GunHand/RayCast2D.get_collider() == target 
		if abs(g.get_angle_to(target.position)) < deg2rad(fireThresh) and ready_to_fire:
			g.firing = true
			
			if $Timer.wait_time == normTimerTime:
				if not g.fullAuto:
					ready_to_fire = false
				$Timer.start()
				#$Timer.wait_time = normTimerTime + rand_range(-fireTimerVariation, fireTimerVariation)
		
		if g.ammoInMag == 0:
			g.reload()
	
	else:
		if is_instance_valid(possibleThingICarHear):
			if possibleThingICarHear.get_parent().playing:
				target = possibleThingICarHear.get_parent().get_parent()
		else:
			possibleThingICarHear = null


func _on_Timer_timeout():
	if g.fullAuto:
		$AutoTimer.start()
	else:
		ready_to_fire = true
	
	g.ready = true
	g.firing = false


func _on_AutoTimer_timeout():
	ready_to_fire = true


func _on_HearingRadius_area_entered(area):
	if area.is_in_group("GunNoise"):
		possibleThingICarHear = area
