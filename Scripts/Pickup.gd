extends Area2D


export(PackedScene) var item
export(Texture) var tex


func _ready():
	$Sprite.texture = tex


func _on_Pickup_body_entered(body):
	if body.is_in_group("Players"):
		if body.pickup(item.instance()):
			queue_free()
