extends Node2D


var score = 0
var multiplier = 1
var multiplierTime = 4
var multiplierTimeLeft = multiplierTime
var time = 0


func add_kill(trickScore):
	score += trickScore
	multiplier += 1
	multiplierTimeLeft = multiplierTime
	Globals.totalTrickScore += trickScore


func get_pretty_score():
	if multiplier > 1:
		if multiplierTimeLeft >= multiplierTime * 0.75:
			return str(score) + "\n--- x" + str(multiplier) + " ---"
		elif multiplierTimeLeft >= multiplierTime * 0.5:
			return str(score) + "\n-- x" + str(multiplier) + " --"
		elif multiplierTimeLeft >= multiplierTime * 0.25:
			return str(score) + "\n- x" + str(multiplier) + " -"
		else:
			return str(score) + "\nx" + str(multiplier)
	else:
		return str(score)


func get_time(time):
	var seconds = int(time) % 60
	var millis = int(time * 100) % 100
	var minutes = (int(time) / 60) % 60
	
	return "%02d:%02d.%02d" % [minutes, seconds, millis]


func _process(delta):
	time += delta / Engine.time_scale
	
	if multiplier > 1:
		multiplierTimeLeft -= delta
	
	if multiplierTimeLeft <= 0:
		multiplier -= 1
		multiplierTimeLeft = multiplierTime
	
	if Globals.speedrunMode:
		$Camera2D/FixedHUD/SpeedrunTimer.text = "LEVEL: " + get_time(time) + "\nTOTAL: " + get_time(Globals.totalTime + time)
