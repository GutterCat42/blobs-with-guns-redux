extends Sprite


func _ready():
	$CPUParticles2D.emitting = true
	$CPUParticles2D.rotation_degrees = rand_range(-30, 30)


func _process(delta):
	#$CPUParticles2D.amount = lerp($CPUParticles2D.amount, 0, 0.0001)
	#$CPUParticles2D.initial_velocity = lerp($CPUParticles2D.initial_velocity, 0, 0.0001)
	$CPUParticles2D.initial_velocity -= 0.4
