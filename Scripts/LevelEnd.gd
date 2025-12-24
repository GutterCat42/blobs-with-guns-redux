extends Area2D


export(NodePath) var boss = null
export(bool) var genocideMode = false

var ended = false


func end():
	ended = true
	
	if get_parent().name != "ProceduralLevel":
		if Globals.levelScores.size() > 0:
			if int(get_parent().name) == Globals.unlockedLevel:
				Globals.levelScores.append(get_parent().score)
				Globals.levelTimes.append(get_parent().time)
			else:
				if get_parent().score > Globals.levelScores[int(get_parent().name) - 1]:
					Globals.levelScores[int(get_parent().name) - 1] = get_parent().score
				if get_parent().time < Globals.levelTimes[int(get_parent().name) - 1]:
					Globals.levelTimes[int(get_parent().name) - 1] = get_parent().time
		else:
			Globals.levelScores.append(get_parent().score)
			Globals.levelTimes.append(get_parent().time)
		
		
		if int(get_parent().name) == Globals.unlockedLevel and int(get_parent().name) < 10:
			Globals.unlockedLevel += 1
			Globals.lastPlayed = Globals.unlockedLevel
	
	Globals.save_progress()
	if Globals.speedrunMode:
		if get_tree().get_nodes_in_group("Enemy").size() == 0:
			Globals.totalTime += get_parent().time
			if int(get_parent().name) == 10:
				get_tree().change_scene("res://Scenes/Menu.tscn")
			else:
				get_tree().change_scene("res://Scenes/Levels/" + str(int(get_parent().name) + 1) + ".tscn")
		else:
			get_parent().get_node("PlayerBlob").genocide_reminder()
	else:
		get_parent().get_node("Camera2D").levelDone()


func _on_LevelEnd_body_entered(body):
	if body.is_in_group("Players") and boss == null:
		end()


func _process(delta):
	if get_parent().get_node_or_null("PlayerBlob") == null:
		get_tree().reload_current_scene()
	
	if not ended:
		if boss != null:
			if not is_instance_valid(get_node(boss)):
				end()
		if genocideMode:
			if get_tree().get_nodes_in_group("Enemy").size() == 0:
				end()
