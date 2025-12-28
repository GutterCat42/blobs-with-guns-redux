extends Area2D


export(PackedScene) var Noise = preload("res://Scenes/Noise.tscn")
export(float) var damage = 2

var kills = 0


func _ready():
	$Light2D.visible = !Globals.reduceFlash
	
	$CPUParticles2D.emitting = true
	
	var n = Noise.instance()
	get_parent().add_child(n)
	n.global_transform = global_transform
	n.playerOrNull = self
	
	$AnimationPlayer.play("Explode")


func _on_Explosion_body_entered(body):
	if body.is_in_group("Hitable"):
		kills += 1
		body.get_hit(damage, get_angle_to(body.global_position) + body.rotation, body.global_position - global_position, ["Explosive"], kills)
