extends Node2D


export(String) var camName = "Camera2D"
export(float) var parallaxFactor = 0.2

var cam
var initialPos


func _ready():
	initialPos = global_position
	cam = get_parent().get_node(camName)


func _physics_process(delta):
	global_position = cam.global_position * parallaxFactor + initialPos
