extends CPUParticles2D


func _ready():
	$Timer.wait_time = lifetime
	emitting = true
	if is_instance_valid($OtherSpray):
		$OtherSpray.emitting = true


func _on_Timer_timeout():
	queue_free()
