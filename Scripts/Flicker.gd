extends Light2D


export(int) var flickerTimes = 3
export(float) var flickerDuration = 0.6
export(float) var randomness = 0.1
export(float) var offLerp = 0.05
export(float) var finalEnergy = 0.9

var time = 0
var flickers = 0


func _process(delta):
	if flickers < flickerTimes + 1:
		time += delta + rand_range(0, randomness)
		if enabled:
			if time > flickerDuration:
				enabled = false
				time = 0
		else:
			if time > flickerDuration / 2:
				enabled = true
				time = 0
				flickers += 1
				if flickers > flickerTimes:
					energy = 0
	else:
		energy = lerp(energy, finalEnergy, offLerp)
