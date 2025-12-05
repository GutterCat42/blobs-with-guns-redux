extends Control


export(String) var levelPath = "res://Scenes/Levels/Level"

var selectedLevel = 1


func set_button_text():
	if selectedLevel != Globals.unlockedLevel and Globals.levelScores.size() > 0:
		$VBoxContainer/ScoreLabel.text = "Best score: " + str(Globals.levelScores[selectedLevel - 1])
	else:
		$VBoxContainer/ScoreLabel.text = "Not completed"
	
	$VBoxContainer/HBoxContainer/PlayButton.text = "PLAY LEVEL " + str(selectedLevel)


func _ready():
	$Sprite.position.x = get_viewport().size.x / 2
	$Gun.position = $Sprite.position
	
	$VBoxContainer.rect_position.x = get_viewport().size.x / 2 - $VBoxContainer.rect_size.x * $VBoxContainer.rect_scale.x / 2
	$VBoxContainer.rect_position.y = get_viewport().size.y - $VBoxContainer.rect_size.y * $VBoxContainer.rect_scale.y
	
	selectedLevel = Globals.lastPlayed
	set_button_text()
	
	#Input.set_custom_mouse_cursor(load("res://Sprites/green crosshair dummy.png"))


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


func _on_PlayButton_pressed():
	Globals.lastPlayed = selectedLevel
	Globals.save_progress()
	get_tree().change_scene(levelPath + str(selectedLevel) + ".tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
