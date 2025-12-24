extends Control


export(String) var levelPath = "res://Scenes/Levels/"

var selectedLevel = 1
var mid


func get_time(time):
	var seconds = int(time) % 60
	var minutes = int(float(time) / 60) % 60
	var hours = (float(time) / 60) / 60
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func get_milli_time(time):
	var seconds = int(time) % 60
	var millis = int(time * 100) % 100
	var minutes = int(float(time) / 60) % 60
	
	return "%02d:%02d.%02d" % [minutes, seconds, millis]


func greatestCommonFactor(a, b):
	return a if b == 0.0 else greatestCommonFactor(b, a % b)


func get_kdr(kills, deaths):
	var gcf = greatestCommonFactor(kills, deaths)
	if gcf != 0:
		return str(kills / gcf) + ":" + str(deaths / gcf)
	else:
		return "..."


func go_to_level_num(targetLevel):
	if get_tree().change_scene(levelPath + str(targetLevel) + ".tscn") != OK: print("Error when switching to level " + str(targetLevel) + "!")


func set_stats():
	$StatsLabel.text = "STATS:\n\nTotal playtime: " + get_time(Globals.totalPlaytime) + "\nTotal trick score: " + str(Globals.totalTrickScore) + "\nTotal kills: " + str(Globals.totalKilled) + "\nTotal deaths: " + str(Globals.totalDeaths) + "\nKill-death ratio: " + get_kdr(Globals.totalKilled, Globals.totalDeaths)
	
	if Globals.totalDeaths > 0:
		$StatsLabel.text +=  "\n(Approximately " + str(round(Globals.totalKilled / Globals.totalDeaths)) + "x more kills than deaths)"
	
	if Globals.speedrunRecord != 0:
		$StatsLabel.text += "\n\nSpeedrun Record: " + get_time(Globals.speedrunRecord)
	
	$StatsLabel.rect_position = mid - $StatsLabel.rect_size * $StatsLabel.rect_scale / 2


func set_button_text():
	if selectedLevel != Globals.unlockedLevel and Globals.levelScores.size() > 0:
		$LevelOptions/ScoreLabel.text = "Best score: " + str(Globals.levelScores[selectedLevel - 1])
		$LevelOptions/TimeLabel.text = "Best time: " + str(stepify(Globals.levelTimes[selectedLevel - 1], 0.01))
	else:
		$LevelOptions/ScoreLabel.text = ""
		$LevelOptions/TimeLabel.text = ""
	
	$LevelOptions/LevelSelect/ConfirmPlayButton.text = "PLAY LEVEL " + str(selectedLevel)
	
	$LevelOptions.rect_position = mid - $LevelOptions.rect_size * $LevelOptions.rect_scale / 2
	
	if Globals.bestTime == null:
		$MenuStack/SpeedrunButton.text = "START GENOCIDE SPEEDRUN"
	else:
		$MenuStack/SpeedrunButton.text = "START GENOCIDE SPEEDRUN (best time: " + str(get_milli_time(Globals.bestTime)) + ")"
	
	_on_Menu_resized()


func _ready():
	if Globals.bestTime != null:
		if Globals.totalTime != null:
			if Globals.totalTime < Globals.bestTime:
				Globals.bestTime = Globals.totalTime
				Globals.save_progress()
	else:
		Globals.bestTime = Globals.totalTime
		Globals.save_progress()
	
	Globals.load_settings()
	selectedLevel = Globals.lastPlayed
	Globals.speedrunMode = false
	set_button_text()
	$GenerateOptions/ThemeSelect.add_item("Outdoors")
	$GenerateOptions/ThemeSelect.add_item("Facility")
	$GenerateOptions/ThemeSelect.selected = 1
	
	Engine.time_scale = 1
	AudioServer.global_rate_scale = 1
	AudioServer.set_bus_effect_enabled(2, 0, false)
	AudioServer.get_bus_effect(0, 0).cutoff_hz = 10000
	get_tree().paused = false
	
	Input.set_custom_mouse_cursor(null)


func _process(_delta):
	set_stats()
	_on_Menu_resized()
	if $GenerateOptions.visible and $GenerateOptions/PistolSelect.pressed and $GenerateOptions/UziSelect.pressed and $GenerateOptions/ShottySelect.pressed and $GenerateOptions/SilencedPistolSelect.pressed and $GenerateOptions/SniperSelect.pressed and $GenerateOptions/AssaultRifleSelect.pressed and $GenerateOptions/GrenadeLauncherSelect.pressed:
		$DropHint.visible = true
	else:
		$DropHint.visible = false


func _on_Menu_resized():
	mid = get_viewport().size / 2
	
	$Background.position = mid
	$Background.scale = get_viewport().size / $Background.texture.get_size()
	$TitleLabel.rect_position.x = mid.x - $TitleLabel.rect_size.x * $TitleLabel.rect_scale.x / 2
	$VersionLabel.rect_position = Vector2(0, get_viewport().size.y - $VersionLabel.rect_size.y * $VersionLabel.rect_scale.y)
	$MenuStack.rect_position = Vector2(mid.x - $MenuStack.rect_size.x * $MenuStack.rect_scale.x / 2, mid.y - $MenuStack.rect_size.y / 2)
	
	$LevelOptions.rect_position = Vector2(mid.x - $LevelOptions.rect_size.x * $LevelOptions.rect_scale.x / 2, mid.y)
	
	$MainButton.rect_position = Vector2(mid.x - $MainButton.rect_size.x * $MainButton.rect_scale.x / 2, get_viewport().size.y - $MainButton.rect_size.y * $MainButton.rect_scale.y * 1.5)
	
	$GenerateOptions.rect_position = mid - $GenerateOptions.rect_size * $GenerateOptions.rect_scale / 2
	$ConfirmGenerateButton.rect_position = Vector2(mid.x - $ConfirmGenerateButton.rect_size.x * $ConfirmGenerateButton.rect_scale.x / 2, $GenerateOptions.rect_position.y + $GenerateOptions.rect_size.y * $GenerateOptions.rect_scale.y)
	
	$CreditsLabel.rect_position = mid - $CreditsLabel.rect_size * $CreditsLabel.rect_scale / 2
	$CreditsLabel.rect_position.y += 50
	$StatsLabel.rect_position = mid - $StatsLabel.rect_size * $StatsLabel.rect_scale / 2
	
	$DropHint.rect_position = Vector2(mid.x + 150, mid.y + 200)


func _on_PlayButton_pressed():
	$MenuStack.hide()
	$LevelOptions.show()
	$MainButton.show()


func _on_LevelDownButton_pressed():
	if selectedLevel == 1:
		selectedLevel = Globals.unlockedLevel
	else:
		selectedLevel -= 1
	
	set_button_text()


func _on_LevelUpButton_pressed():
	if selectedLevel == Globals.unlockedLevel:
		selectedLevel = 1
	else:
		selectedLevel += 1
	
	set_button_text()


func _on_ConfirmPlayButton_pressed():
	Globals.lastPlayed = selectedLevel
	Globals.save_progress()
	go_to_level_num(selectedLevel)


func _on_SpeedrunButton_pressed():
	Globals.speedrunMode = true
	Globals.totalTime = 0
	go_to_level_num(1)


func _on_CreditsButton_pressed():
	$CreditsLabel.show()
	$MenuStack.hide()
	$MainButton.show()
	$VersionLabel.hide()


func _on_ExitButton_pressed():
	Globals.save_progress()
	get_tree().quit()


func _on_MainButton_pressed():
	$MenuStack.show()
	$LevelOptions.hide()
	$MainButton.hide()
	$GenerateOptions.hide()
	$ConfirmGenerateButton.hide()
	$CreditsLabel.hide()
	$StatsLabel.hide()
	$VersionLabel.show()


func _on_GenerateButton_pressed():
	$GenerateOptions.show()
	$MenuStack.hide()
	$MainButton.show()
	$ConfirmGenerateButton.show()


func _on_ConfirmGenerateButton_pressed():
	var allowedGuns = []
	if $GenerateOptions/PistolSelect.pressed:
		allowedGuns.append("res://Scenes/Guns/Pistol.tscn")
	if $GenerateOptions/UziSelect.pressed:
		allowedGuns.append("res://Scenes/Guns/Uzi.tscn")
	if $GenerateOptions/ShottySelect.pressed:
		allowedGuns.append("res://Scenes/Guns/Shotty.tscn")
	if $GenerateOptions/SilencedPistolSelect.pressed:
		allowedGuns.append("res://Scenes/Guns/SilencedPistol.tscn")
	if $GenerateOptions/SniperSelect.pressed:
		allowedGuns.append("res://Scenes/Guns/Sniper.tscn")
	if $GenerateOptions/AssaultRifleSelect.pressed:
		allowedGuns.append("res://Scenes/Guns/AssaultRifle.tscn")
	if $GenerateOptions/GrenadeLauncherSelect.pressed:
		allowedGuns.append("res://Scenes/Guns/GrenadeLauncher.tscn")
	
	Globals.generateOptions = [$GenerateOptions/ThemeSelect.selected, $GenerateOptions/HPSelect.value,
							   $GenerateOptions/WidthSelect.value, $GenerateOptions/HeightSelect.value,
							   $GenerateOptions/PlatformsSelect.value, $GenerateOptions/MinWidthSelect.value, $GenerateOptions/MaxWidthSelect.value,
							   $GenerateOptions/WallsSelect.value, $GenerateOptions/EnemiesSelect.value,
							   allowedGuns]
	
	if get_tree().change_scene("res://Scenes/Levels/ProceduralLevel.tscn") != OK: print("Error when changing to procedural level scene!")


func _on_StatsButton_pressed():
	$MenuStack.hide()
	$StatsLabel.show()
	$MainButton.show()


func _on_MenuIntro_finished():
	$MenuLoop.play()
