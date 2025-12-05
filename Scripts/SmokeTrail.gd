extends Line2D


export(float) var length = 50.0

var target = null


func _physics_process(delta):
	if is_instance_valid(target):
		add_point(target.global_position)
	else:
		if get_point_count() > 0:
			remove_point(0)
		else:
			queue_free()
