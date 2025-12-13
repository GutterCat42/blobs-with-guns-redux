extends Camera2D


export(float) var defaultStrength = 3.0
export(float) var defaultLerpWeight = 0.2
export(bool) var sniperMode = false
export(float) var sniperZoomRatio = 1.1
export(float) var zoomSpeed = 0.3
export(float) var sniperTime = 0.2
export(NodePath) var boss = null
export(bool) var useReverb = true

var target

var intensity = 0
var lerpWeight = 0

var gi
var normalZoom
var ammoNormalX


func shake(strength=defaultStrength, weight=defaultLerpWeight):
	intensity = strength
	lerpWeight = weight


func show_hitvignette(damage):
	$HitVignette.modulate.a += damage
	AudioServer.get_bus_effect(0, 0).cutoff_hz = 1
	$HitVignette/EarRingSound.play()


func switch_to(index):
	target.switch_to(index)


func levelDone():
	get_parent().get_node("Music/Intro").stop()
	get_parent().get_node("Music/Body").stop()
	get_parent().get_node("Music/End").play()
	$EndScreen.show()
	$AmmoDisplay.hide()
	$RadialInventory.hide()
	#get_tree().paused = true
	Globals.save_progress()


func deadScreen():
	$DeadScreen/DeadVingette.rect_size = get_viewport().size
	$DeadScreen.show()
	$AmmoDisplay.hide()
	$RadialInventory.hide()
	get_tree().paused = true
	Globals.save_progress()


func pause():
	$PauseMenu.show()
	$AmmoDisplay.hide()
	$RadialInventory.hide()
	get_tree().paused = true
	Globals.save_progress()


func _ready():
	normalZoom = zoom
	
	if boss != null:
		$Label.rect_position.x = -$Label.rect_size.x / 2
	
	$SpeedrunTimer.visible = Globals.speedrunMode
	
	$RadialInventory/Panel.rect_size = get_viewport().size
	$RadialInventory/Panel.rect_position = get_viewport().size / 2 - $RadialInventory/Panel.rect_size * $RadialInventory/Panel.rect_scale
	
	$HitVignette.rect_size = get_viewport().size
	
	AudioServer.set_bus_effect_enabled(2, 0, useReverb)
	AudioServer.get_bus_effect(0, 0).cutoff_hz = 10000


func _physics_process(delta):
	$FPSLabel.text = str(Engine.get_frames_per_second())
	
	if boss != null and is_instance_valid(get_node(boss)):
		$Label.text = get_node(boss).name + "\n" + str(round(get_node(boss).hp))
	
	if is_instance_valid(target):
		if not sniperMode:
			global_position = target.global_position
			$Tween.interpolate_property(self, "zoom", zoom, normalZoom, zoomSpeed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		else:
			global_position = (target.global_position + get_global_mouse_position()) / 2
			$Tween.interpolate_property(self, "zoom", zoom, normalZoom * sniperZoomRatio, zoomSpeed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
	
	if intensity > 0:
		offset = Vector2(rand_range(-intensity, intensity), rand_range(-intensity, intensity)) * 100 * delta
		intensity = lerp(intensity, 0, lerpWeight)
	
	if Input.is_action_just_pressed("pause"):
		pause()
	
	if is_instance_valid(target):
		$AmmoDisplay.rect_position = target.position - position
		$RadialInventory.rect_position = target.position - position
	
	$SpeedrunTimer.rect_position.x = -$SpeedrunTimer.rect_size.x * $SpeedrunTimer.rect_scale.x / 2
	
	if $HitVignette.modulate.a > 0:
		$HitVignette.modulate.a = lerp($HitVignette.modulate.a, 0, 0.005)
		AudioServer.get_bus_effect(0, 0).cutoff_hz = lerp(AudioServer.get_bus_effect(0, 0).cutoff_hz, 10000, 0.005)


func _on_ResumeButton_pressed():
	$PauseMenu.hide()
	$AmmoDisplay.show()
	get_tree().paused = false


func _on_RestartButton_pressed():
	get_tree().paused = false
	if Globals.speedrunMode:
		Globals.totalTime += get_parent().time
	get_tree().reload_current_scene()


func _on_MenuButton_pressed():
	get_tree().paused = false
	Globals.totalTime = null
	get_tree().change_scene("res://Scenes/Menu.tscn")


func _on_NextLevelButton_pressed():
	Globals.lastPlayed = int(get_parent().name)
	Globals.save_progress()
	get_tree().paused = false
	if boss != null:
		get_tree().change_scene("res://Scenes/Menu.tscn")
	else:
		if int(get_parent().name) == 10:
			get_tree().change_scene("res://Scenes/Menu.tscn")
		else:
			if get_parent().name == "ProceduralLevel":
				get_tree().reload_current_scene()
			else:
				get_tree().change_scene("res://Scenes/Levels/" + str(int(get_parent().name) + 1) + ".tscn")


func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			pause()
