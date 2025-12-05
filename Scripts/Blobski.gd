extends RigidBody2D


export(PackedScene) var Gun = preload("res://Scenes/Guns/Pistol.tscn")
export(PackedScene) var PickupScene = preload("res://Scenes/Pickup.tscn")
export(PackedScene) var Spray = preload("res://Scenes/Blobs/BlobSpray.tscn")
export(PackedScene) var PopupText = preload("res://Scenes/PopupText.tscn")
export(PackedScene) var Grenade = preload("res://Scenes/Projectiles/HandGrenade.tscn")
export(PackedScene) var Corpse = preload("res://Scenes/Blobs/BlobCorpse.tscn")
export(PackedScene) var DripSplat = preload("res://Scenes/Blobs/BlobDripSplat.tscn")

export(float) var aimSpeed = 5.0
export(float) var fireThresh = 10.0
export(float) var hp = 1
export(int) var baseScore = 100
export(float) var reactionTime = 1
export(float) var shootyTimerTime = 0.5
export(float) var timerVariation = 0.2
export(bool) var onGuard = false
export(float) var squashThresh = 7
var dropping = false
var g
var targeting = null
var target = null
var ready_to_fire = true
var normal_scale


func get_hit(damage=1, sprayAngle=0, offset=Vector2.ZERO, tricks=[], multikill=1):
	hp -= damage
	
	var sp = Spray.instance()
	get_parent().add_child(sp)
	sp.global_transform = global_transform
	sp.rotation = sprayAngle
	sp.modulate = $CollisionPolygon2D/Sprite.modulate
	if damage < 2:
		sp.emitting = false
	
	if hp <= 0 and not dropping:
		dropping = true
		var drop = PickupScene.instance()
		drop.item = Gun
		drop.tex = get_node(str(g.get_path()) + "/AnimNode/Sprite").texture
		get_parent().add_child(drop)
		drop.global_transform = global_transform
		
		if round(rand_range(1, 5)) == 5:
			var otherdrop = PickupScene.instance()
			otherdrop.item = Grenade
			get_parent().add_child(otherdrop)
			otherdrop.global_transform = global_transform
		
		var t = PopupText.instance()
		t.global_transform = global_transform
		get_parent().add_child(t)
		
		var c = Corpse.instance()
		get_parent().add_child(c)
		c.global_position = global_position
		if rad2deg(sprayAngle) > -90 and rad2deg(sprayAngle) < 90:
			c.scale.x *= -1
		if hp < 0:
			c.texture = load("res://Sprites/enemy dripping.png")
			c.global_position.y += 3
		
		# TODO: make this neater
		var trickname = "Kill"
		var trickscore = baseScore
		
		if multikill == 3:
			tricks.append("Double")
		elif multikill == 4:
			tricks.append("Triple")
		elif multikill == 5:
			tricks.append("Quadruple")
		elif multikill >= 6:
			tricks.append(str(multikill) + "x")
		
		if tricks.size() > 0:
			for trick in tricks:
				trickname = trickname.insert(0, trick + " ")
				if trick == "Air":
					trickscore += 2 * baseScore
				elif trick == "Proximity":
					trickscore += 3 * baseScore
				elif trick == "Ricochet":
					trickscore += 4  * baseScore
				elif trick == "Explosive":
					trickscore += 4 * baseScore
		
		trickscore += (multikill - 1) * baseScore
		
		t.get_node("Label").text = trickname + "\n+" + str(get_parent().multiplier * trickscore)
		get_parent().add_kill(baseScore)
		
		queue_free()


func get_gun():
	g = Gun.instance()
	$CollisionPolygon2D/GunHand.add_child(g)
	g.world = get_parent()
	g.shooter = self
	g.global_transform = $CollisionPolygon2D/GunHand.global_transform
	g.equip()
	g.infiniteReloads = true


func start_targeting(tgt):
	if targeting == null:
		targeting = tgt
		$ReactionTimer.start()


func _ready():
	normal_scale = $CollisionPolygon2D.scale
	
	#fix this
	if onGuard:
		targeting = get_parent().get_node("PlayerBlob")
		target = get_parent().get_node("PlayerBlob")
		$HearingRadius.scale *= 10
		$CollisionPolygon2D/GunHand/LookArea.scale *= 10
	
	$ReactionTimer.wait_time = reactionTime
	$ReactionTimer.wait_time *= rand_range(reactionTime - timerVariation, reactionTime + timerVariation)
	
	$Timer.wait_time = shootyTimerTime
	
	get_gun()


func _on_HearingRadius_area_entered(area):
	if area.is_in_group("Noise"):
		if area.playerOrNull != null:
			start_targeting(area.playerOrNull)


func _physics_process(delta):
	if target != null:
		if is_instance_valid(target):
			if $CollisionPolygon2D/GunHand.get_angle_to(target.position) > 0:
				$CollisionPolygon2D/GunHand.rotate(deg2rad(aimSpeed))
			else:
				$CollisionPolygon2D/GunHand.rotate(deg2rad(-aimSpeed))
			
			$CollisionPolygon2D.scale.x = (1 - 2 * int(target.position.x < position.x)) * normal_scale.x
			#$CollisionPolygon2D/GunHand.scale.x = 1 - 2 * int(target.position.x < position.x)
			#$CollisionPolygon2D/GunHand.scale.y = 1 - 2 * int(target.position.x < position.x)
			
			if abs(g.get_angle_to(target.position)) < deg2rad(fireThresh) and ready_to_fire:
				$AimRaycast.cast_to = target.global_position - $AimRaycast.global_position
				if $AimRaycast.is_colliding() and $AimRaycast.get_collider().is_in_group("Players"):
					if target in $CollisionPolygon2D/GunHand/LookArea.get_overlapping_bodies():
						g.firing = true
						$Timer.wait_time *= rand_range(shootyTimerTime - timerVariation, shootyTimerTime + timerVariation)
						$Timer.start()
						ready_to_fire = false
		
		else:
			target = null
	
	if g.ammoInMag == 0:
		g.reload()
	
	if $CollisionPolygon2D/GunHand/LookArea.get_overlapping_bodies().size() > 0:
		for body in $CollisionPolygon2D/GunHand/LookArea.get_overlapping_bodies():
			if body.is_in_group("Players"):
				$AimRaycast.cast_to = body.global_position - $AimRaycast.global_position
				if $AimRaycast.is_colliding():
					start_targeting(body)


func _on_Timer_timeout():
	ready_to_fire = true
	g.firing = false
	g.ready = true


func _on_ReactionTimer_timeout():
	target = targeting


func _on_HearingRadius_body_exited(body):
	if body.is_in_group("Players"):
		targeting = null
		target = null


func _on_Intro_finished():
	$Body.play()



func _on_Blobski_body_entered(body):
	if body.is_in_group("CanSquash") and body.global_position.y < global_position.y - squashThresh:
		get_hit(2, deg2rad(-90), Vector2.ZERO, ["Melee"])
