extends Node2D

export(PackedScene) var Bullet = preload("res://Scenes/Projectiles/Bullet.tscn")
export(PackedScene) var Shell = preload("res://Scenes/Projectiles/Shell.tscn")
export(PackedScene) var Mag = preload("res://Scenes/Projectiles/Mag.tscn")
export(PackedScene) var Noise = preload("res://Scenes/Noise.tscn")

export(bool) var fullAuto = false
export(float) var rps = 10.0
export(bool) var burst = false
export(int) var burstRounds = 3
export(bool) var shotty = false
export(int) var shottyBullets = 10
export(float) var shottySpread = 30
export(bool) var grenadeLauncher = false
export(float) var recoil = 100.0
export(float) var bulletSpeed = 1200.0
export(float) var bulletDamage = 1.2
export(float) var finalBulletDamage = 0.5
export(float) var bulletInaccuracy = 0.5
export(bool) var curvyInaccuracy = false
export(bool) var bulletMomentum = false
export(float) var bulletRange = 400.0
export(int) var armourPiercing = 0
export(int) var magSize = 10
export(int) var ammo = 30
export(bool) var autoReload = true
export(bool) var infiniteReloads = false
export(Vector2) var muzzleFlashRandScale = Vector2(0.5, 0.3)
export(float) var pitchVariation = 0.3
export(float) var zoomRatio = 1.0
export(bool) var silenced = false
export(bool) var animations = true
export(bool) var canShield = false

var firing
var ready = true
var can_fire = true
var world
var player
var shooter
var ammoInMag = magSize
var burstShotsLeft = 0
var lastPos
var reloading
var current


func reload():
	reloading = true
	$ReloadSound.play()
	
	if not shotty and not grenadeLauncher:
		var m = Mag.instance()
		world.add_child(m)
		m.global_transform = global_transform
		#m.apply_central_impulse(Vector2(0, -100).rotated(rotation))
	
	if grenadeLauncher:
		for i in range(magSize):
			ejectShell()
	
	$AnimationPlayer.play("Reload")
	
	if not infiniteReloads:
		ammo += ammoInMag
		ammoInMag = 0
		
		if ammo - magSize >= 0:
			ammoInMag = magSize
			ammo -= magSize
		else:
			ammoInMag = ammo
			ammo = 0
	
	else:
		ammoInMag = magSize


func equip(yesno=true):
	if yesno:
		show()
		can_fire = false
		$AnimationPlayer.play("Equip")
	else:
		current = false
		hide()


func launchBullet(rot=0):
	var b = Bullet.instance()
	world.add_child(b)
	b.global_transform = $AnimNode/Sprite/BarrelEnd.global_transform
	b.rotate(deg2rad(rot))
	if bulletMomentum:
		b.velocity = global_position - lastPos
	b.shot_from = shooter
	if not grenadeLauncher:
		b.bulletSpeed = bulletSpeed
		b.inaccuracy = bulletInaccuracy
		b.curvy = curvyInaccuracy
		b.initialDamage = bulletDamage
		b.finalDamage = finalBulletDamage
		b.bulletRange = bulletRange
		b.armourPiercing = armourPiercing
		if player != null:
			if player.get_colliding_bodies().size() == 0:
				b.tricks.append("Air")
		# the next three lines are temp
		if shotty:
			b.get_node("Sprite").texture = load("res://Sprites/shotty ball dummy.png")
			b.get_node("Sprite").scale *= 2
		b._ready()
	else:
		b.shoot()


func ejectShell():
	var s = Shell.instance()
	world.add_child(s)
	s.global_transform = $AnimNode/Sprite/ShellPoint.global_transform
	if global_scale.y > 0:
		s._ready(true)
	else:
		s._ready(false)


func fire():
	if Input.is_action_pressed("Shield") and canShield:
		return
	
	if not shotty:
		launchBullet()
	else:
		for i in range(0, shottyBullets):
			launchBullet((shottySpread / 2) - i * (shottySpread / shottyBullets))
	
	can_fire = false
	$FiringTimer.start()
	
	if not silenced:
		$AnimNode/Sprite/BarrelEnd/MuzzleFlash.show()
		$AnimNode/Sprite/BarrelEnd/MuzzleFlash.scale.x = 1 + rand_range(-muzzleFlashRandScale.x, muzzleFlashRandScale.x)
		$AnimNode/Sprite/BarrelEnd/MuzzleFlash.scale.y = 1 + rand_range(-muzzleFlashRandScale.y, muzzleFlashRandScale.y)
		$AnimNode/Sprite/BarrelEnd/MuzzleFlash/MuzzleFlashTimer.start()
		
		var n = Noise.instance()
		world.add_child(n)
		n.global_transform = global_transform
		if player:
			n.playerOrNull = player
	
	$AnimationPlayer.play("Fire")
	$FiringSound.pitch_scale = rand_range(1 - pitchVariation, 1 + pitchVariation)
	$FiringSound.play()
	
	"""
	var p = SmokeParticles.instance()
	p.global_transform = $AnimNode/Sprite/BarrelEnd.global_transform
	world.add_child(p)
	"""
	
	if player:
		player.get_recoiled(recoil)
		player.cam.shake(player.cam.defaultStrength * recoil / 100)
	
	if not grenadeLauncher:
		ejectShell()
	
	ammoInMag -= 1


func _ready():
	$FiringTimer.wait_time = 1 / rps
	#$Sprite/BarrelEnd/MuzzleFlash/MuzzleFlashTimer.wait_time = 0.5 / rps


func _physics_process(delta):
	if ammoInMag > 0:
		if firing and ready and can_fire and not reloading:
			if not fullAuto:
				fire()
				ready = false
			else:
				fire()
				
			if burst:
				burstShotsLeft = burstRounds
		
		if burstShotsLeft > 1 and can_fire and not reloading:
			fire()
			burstShotsLeft -= 1
	
	else:
		if firing and ready and can_fire and not reloading:
			if autoReload:
				reload()
			
			if not $AmmoEmptySound.playing:
				$AmmoEmptySound.play()
	
	lastPos = global_position
	
	if canShield:
		if Input.is_action_just_pressed("Shield"):
			$AnimNode/Sprite/Shield.collision_layer = 2
			$AnimNode/Sprite/Shield.collision_mask = 2
		elif Input.is_action_just_released("Shield"):
			$AnimNode/Sprite/Shield.collision_layer = 0
			$AnimNode/Sprite/Shield.collision_mask = 0


func _on_FiringTimer_timeout():
	can_fire = true


func _on_MuzzleFlashTimer_timeout():
	$AnimNode/Sprite/BarrelEnd/MuzzleFlash.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Reload":
		reloading = false
	if anim_name == "Equip":
		current = true
		can_fire = true
