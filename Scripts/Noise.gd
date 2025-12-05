extends Area2D


# TODO: make noise take time to travel (expand collisionshape over time)

var playerOrNull = null


func _on_Timer_timeout():
	queue_free()
