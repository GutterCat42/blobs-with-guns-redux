extends Node


export(bool) var on = false
export(bool) var intro = false

var soundtracks = ["menu", "main theme", "stealth", "sludge", "blobski short"]


func _ready():
	if get_parent().name == "ProceduralLevel":
		$Intro.stream = load("res://Music/" + soundtracks[Globals.generateOptions[10]] + " intro.wav")
		$Body.stream = load("res://Music/" + soundtracks[Globals.generateOptions[10]] + " loop.wav")
		$End.stream = load("res://Music/" + soundtracks[Globals.generateOptions[10]] + " outro.wav")
	
	if on:
		if intro:
			$Intro.play()
		else:
			$Body.play()


func _on_Intro_finished():
	$Intro.stop()
	$Body.play()
