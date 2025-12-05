extends Node2D


var velocity = 0
var force = 0
var height = position.y
var target_height = position.y + 80
var index = 0
var motion_factor = 0.02

signal splash


func initialise(x_pos, id):
	height = position.y
	target_height = position.y
	velocity = 0
	position.x = x_pos
	index = id


func fluid_update(spring_constant, dampening):
	height = position.y
	var x = height - target_height
	var loss = -dampening * velocity
	force = -spring_constant * x + loss
	velocity += force
	position.y += velocity


func set_collision_width(value):
	var extents = $Area2D/CollisionShape2D.shape.get_extents()
	var new_extents = Vector2(value / 2, extents.y)
	$Area2D/CollisionShape2D.shape.set_extents(new_extents)


func _on_Area2D_body_entered(body):
	if body.is_in_group("CanSplash"):
		var speed = body.linear_velocity.y * motion_factor
		emit_signal("splash", index, speed)
