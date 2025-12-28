extends RigidBody2D


export(PackedScene) var Gun = preload("res://Scenes/Guns/Pistol.tscn")
export(PackedScene) var Spray = preload("res://Scenes/Blobs/BlobSpray.tscn")
export(PackedScene) var PopupText = preload("res://Scenes/PopupText.tscn")
export(PackedScene) var Grenade = preload("res://Scenes/Projectiles/HandGrenade.tscn")

export(float) var hp = 3.0
export(int) var grenades = 1
export(float) var slomoAmount = 0.1
export(float) var slomoSpeed = 0.42
export(float) var squashThresh = 5


var guns = []
var currentGun
var cam
var ammoNormalX
var faceNormalPos
var popups = 0


func get_recoiled(recoil):
	#apply_impulse($CollisionPolygon2D/GunHand.position, Vector2(-recoil, 0).rotated(get_angle_to(get_global_mouse_position()) + rotation))
	apply_central_impulse(Vector2(-recoil, 0).rotated(get_angle_to(get_global_mouse_position()) + rotation))
	cam.shake(cam.defaultStrength * (currentGun.recoil / 100))


func look_for(name):
	for g in guns:
		if g.name == name:
			return guns.find(g)
	
	return -1


func pickup(gun):
	var t = PopupText.instance()
	popups += 1
	t.popupNum = popups
	get_parent().add_child(t)
	t.global_position = global_position
	
	# this if is temp
	if gun.name != "HandGrenade":
		var g = look_for(gun.name)
		if g == -1:
			if guns.size() < 6:
				guns.append(gun)
				gun.equip(false)
				gun.ammoInMag = gun.magSize  # temp bugfix
				if gun.get_parent() != $CollisionPolygon2D/GunHand:
					$CollisionPolygon2D/GunHand.add_child(gun)
				gun.world = owner
				gun.player = self
				gun.shooter = self
				gun.global_transform = $CollisionPolygon2D/GunHand.global_transform
				
				cam.get_node("RadialInventory/Circle/" + str(guns.size() - 1) + "/Sprite").texture = gun.get_node("AnimNode/Sprite").texture
				
				if gun.name[0].to_lower() in ["a", "e", "i", "o", "u"]:
					t.get_node("Label").text = "Picked up an " + gun.name + "!"
				else:
					t.get_node("Label").text = "Picked up a " + gun.name + "!"
				
				return true
			
			else:
				t.get_node("Label").text = "You can't pick up more than six guns!"
				return false
		
		else:
			guns[g].ammo += gun.ammo
			
			t.get_node("Label").text = "+" + str(gun.ammo) + " " + gun.name + " ammo!"
			return true
	else:
		grenades += 1
		t.get_node("Label").text = "Picked up a grenade!"
		return true


func switch_to(index):
	if index <= guns.size() - 1:
		currentGun.firing = false
		currentGun.equip(false)
		currentGun = guns[index]
		currentGun.equip(true)


func cycle_guns(forward=true):
	if guns.size() > 1:
		if forward:
			if currentGun == guns[-1]:
				switch_to(0)
			else:
				switch_to(guns.find(currentGun) + 1)
		else:
			if currentGun == guns[0]:
				switch_to(-1)
			else:
				switch_to(guns.find(currentGun) - 1)


func do_trick(name, score):
	get_parent().score += score
	var t = PopupText.instance()
	get_parent().add_child(t)
	t.global_transform = global_transform
	t.get_node("Label").text = name + "\n" + str(score)


func get_hit(damage=1, sprayAngle=0, thingidontneed=Vector2.ZERO, otherthingidontneed=1, yetanotherthingidontneed=1):
	do_trick("Hit", -100 * round(damage))
	
	hp -= damage
	
	var sp = Spray.instance()
	owner.add_child(sp)
	sp.global_transform = global_transform
	sp.rotation = sprayAngle
	sp.modulate = $CollisionPolygon2D/BlobBody.modulate
	
	cam.shake(42 * damage)
	cam.show_hitvignette(damage)
	
	get_parent().multiplier = 1
	get_parent().multiplierTimeLeft = get_parent().multiplierTime
	
	if hp < 1:
		Globals.totalDeaths += 1
		cam.deadScreen()


func genocide_reminder():
	if $GenocideReminderTimer.time_left != 0:
		var t = PopupText.instance()
		get_parent().add_child(t)
		t.global_transform = global_transform
		t.get_node("Label").text = "You must kill all enemies!"
		$GenocideReminderTimer.start()


func ammo_left():
	var ammoLeft = false
	for gun in guns:
		if gun.ammo + gun.ammoInMag > 0:
			ammoLeft = true
	
	return ammoLeft


func _ready():
	faceNormalPos = $CollisionPolygon2D/BlobBody/BlobFace.position
	
	cam = owner.get_node("Camera2D")
	cam.target = self
	
	Input.set_custom_mouse_cursor(load("res://Sprites/green crosshair.png"), 0, Vector2(30, 30))
	Engine.time_scale = 1
	AudioServer.global_rate_scale = 1
	get_tree().paused = false
	
	currentGun = Gun.instance()
	pickup(currentGun)
	currentGun.equip()
	
	randomize()


func _physics_process(_delta):
	#$CollisionPolygon2D.scale.x = 1 - 2 * int(get_global_mouse_position().x < global_position.x)
	$CollisionPolygon2D.scale.x = 1 - 2 * int(((global_position + Vector2(0, 1).rotated(rotation)).x - global_position.x)*(get_global_mouse_position().y - global_position.y) - ((global_position + Vector2(0, 1).rotated(rotation)).y - global_position.y)*(get_global_mouse_position().x - global_position.x) > 0)
	
	if not currentGun.infiniteReloads:
		cam.get_node("AmmoDisplay/AmmoLabel").text = str(currentGun.ammoInMag) + "|" + str(currentGun.ammo)
	else:
		cam.get_node("AmmoDisplay/AmmoLabel").text = str(currentGun.ammoInMag)
	
	cam.get_node("AmmoDisplay/AmmoLabel/ScoreLabel").text = get_parent().get_pretty_score()
	
	currentGun.look_at(get_global_mouse_position())
	
	if not cam.get_node("RadialInventory").visible:
		if Input.is_action_pressed("fire"):
			currentGun.firing = true
			if currentGun.reloading and not currentGun.get_node("AnimationPlayer").is_playing():
				currentGun.reloading = false
	
	if Input.is_action_just_released("fire"):
		currentGun.ready = true
		currentGun.firing = false
	
	if Input.is_action_just_pressed("reload") and not currentGun.reloading and currentGun.ammoInMag != currentGun.magSize:
		currentGun.reload()
	
	if Input.is_action_just_pressed("nextGun") or Input.is_action_just_released("scrollUp"):
		cycle_guns()
	elif Input.is_action_just_pressed("prevGun") or Input.is_action_just_released("scrollDown"):
		cycle_guns(false)
	
	if Input.is_action_just_pressed("inventory"):
		cam.get_node("RadialInventory").show()
	if Input.is_action_just_released("inventory"):
		cam.get_node("RadialInventory").hide()
	
	if Input.is_action_pressed("aim"):
		cam.sniperMode = true
		cam.sniperZoomRatio = currentGun.zoomRatio
	else:
		cam.sniperMode = false
	
	if Input.is_action_just_pressed("grenade"):
		if grenades > 0:
			var hg = Grenade.instance()
			get_parent().add_child(hg)
			hg.global_transform = global_transform
			hg.apply_central_impulse(Vector2(300, 0).rotated(get_angle_to(get_global_mouse_position()) + rotation))
			grenades -= 1
	
	if Input.is_action_just_pressed("drop"):
		if guns.size() > 1:
			var t = PopupText.instance()
			get_parent().add_child(t)
			t.global_transform = global_transform
			if currentGun.name[0].to_lower() in ["a", "e", "i", "o", "u"]:
				t.get_node("Label").text = "Dropped an " + currentGun.name + "!"
			else:
				t.get_node("Label").text = "Dropped a " + currentGun.name + "!"
			
			var ind = guns.find(currentGun)
			cycle_guns()
			guns.remove(ind)
			for i in range(0, 6):
				cam.get_node("RadialInventory/Circle/" + str(i) + "/Sprite").texture = null
			for g in guns:
				cam.get_node("RadialInventory/Circle/" + str(guns.find(g)) + "/Sprite").texture = g.get_node("AnimNode/Sprite").texture
			
			# make pickup
		else:
			var t = PopupText.instance()
			get_parent().add_child(t)
			t.global_transform = global_transform
			t.get_node("Label").text = "You can't drop your only gun!"
	
	if cam.get_node("RadialInventory").visible or Input.is_action_pressed("aim"):
		cam.get_node("RadialInventory/GrenadesLabel").text = "1 grenade" if grenades == 1 else str(grenades) + " grenades"
		cam.get_node("RadialInventory/GrenadesLabel").rect_position.x = -(cam.get_node("RadialInventory/GrenadesLabel").rect_size.x * cam.get_node("RadialInventory/GrenadesLabel").rect_scale.x / 2)
		Engine.time_scale = lerp(Engine.time_scale, slomoAmount, slomoSpeed)
		AudioServer.global_rate_scale = lerp(AudioServer.global_rate_scale, 2 - slomoAmount, slomoSpeed)
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1, slomoSpeed)
		AudioServer.global_rate_scale = lerp(AudioServer.global_rate_scale, 1, slomoSpeed)
	
	if not ammo_left() and $AmmoOutTimer.time_left == 0:
		$AmmoOutTimer.start()


func _input(event):
	if event is InputEventKey:
		if [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6].has(event.scancode) and event.is_pressed():
			switch_to(event.scancode - 49)


func _on_BulletTimeArea_area_entered(area):
	return
	# work on cool bullet time effects later
	if area.is_in_group("Bullets"):
		if area.shot_from != self:
			Engine.time_scale = 0.1


func _on_BulletTimeArea_area_exited(area):
	return
	# do bullet time later
	if area.is_in_group("Bullets"):
		#Engine.time_scale = 1
		if area.shot_from != self:
			do_trick("Dodge", 100)


func _on_PlayerBlob_body_entered(body):
	if body.is_in_group("CanSquash") and body.global_position.y < global_position.y - squashThresh and body.linear_velocity.length() > 100:
		get_hit(2, deg2rad(-90), Vector2.ZERO)


func _on_AmmoOutTimer_timeout():
	if not ammo_left():
		cam.deadScreen()
