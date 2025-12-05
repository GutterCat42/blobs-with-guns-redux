extends Node


export(bool) var on = false
export(bool) var intro = false


func _ready():
	if on:
		if intro:
			$Intro.play()
		else:
			$Body.play()


func _on_Intro_finished():
	$Intro.stop()
	$Body.play()
