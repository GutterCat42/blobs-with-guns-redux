extends Node2D


export var FluidSpring = preload("res://Scenes/FluidSpring.tscn")
export var k = 0.015
export var d = 0.03
export var spread = 0.0002
export var distance = 32
export var numSprings = 6
export var depth = 1000

var springs = []
var passes = 8
var length = distance * numSprings
var target_height = global_position.y
var bottom = target_height + depth


func _ready():
	for i in range(numSprings):
		var x_pos = distance * i
		var s = FluidSpring.instance()
		add_child(s)
		springs.append(s)
		s.initialise(x_pos, i)
		s.set_collision_width(distance)
		s.connect("splash", self, "splash")


func splash(index, speed):
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed


func draw_fluid_body():
	var surface_points = []
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
	
	var first = 0
	var last = surface_points.size() - 1
	
	var polygon_points = surface_points
	
	polygon_points.append(Vector2(surface_points[last].x, bottom))
	polygon_points.append(Vector2(surface_points[first].x, bottom))
	
	polygon_points = PoolVector2Array(polygon_points)
	
	$Polygon2D.set_polygon(polygon_points)


func _physics_process(delta):
	for spring in springs:
		spring.fluid_update(k, d)
	
	var left_deltas = []
	var right_deltas = []
	
	for i in range(springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	for j in range(passes):
		for i in range(springs.size()):
			if i > 0:
				left_deltas[i] = spread * (springs[i].height - springs[i - 1].height)
				springs[i - 1].velocity += left_deltas[i]
			if i < springs.size() - 1:
				right_deltas[i] = spread * (springs[i].height - springs[i + 1].height)
				springs[i + 1].velocity += right_deltas[i]
	
	draw_fluid_body()
