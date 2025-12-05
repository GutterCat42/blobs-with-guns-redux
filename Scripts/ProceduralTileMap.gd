extends TileMap


export(int) var tileNum = 0
export(Vector2) var size = Vector2(30, 20)
export(int) var numPlatforms = 20
export(int) var numWalls = 10
export(int) var numEnemies = 20
export(int) var minWidth = 2
export(int) var maxWidth = 8

export(PackedScene) var Enemy = preload("res://Scenes/Blobs/BadBlob.tscn")
export(Array) var Guns = [preload("res://Scenes/Guns/Pistol.tscn"),
							preload("res://Scenes/Guns/Shotty.tscn"),
							preload("res://Scenes/Guns/SilencedPistol.tscn"),
							preload("res://Scenes/Guns/Sniper.tscn"),
							preload("res://Scenes/Guns/Uzi.tscn")]

var enemies = 0


func create_platform(pos=Vector2.ZERO, width=5):
	for i in range(0, width):
		set_cell(pos.x + i, pos.y, tileNum)


func create_wall(pos=Vector2.ZERO, height=5):
	for i in range(0, height):
		set_cell(pos.x, pos.y + i, tileNum)


func place_enemy(pos=Vector2.ZERO):
	var e = Enemy.instance()
	get_parent().add_child(e)
	e.translate(pos)
	e.Gun = Guns[rand_range(0, Guns.size())]
	e.get_gun()


func _ready():
	if Globals.generateOptions[0] == 0:
		get_parent().get_node("Camera2D").useReverb = false
	elif Globals.generateOptions[0] == 1:
		get_parent().get_node("Camera2D").useReverb = true
	
	tileNum = Globals.generateOptions[0]
	if tileNum == 1:
		$"../Background".show()
	get_parent().get_node("PlayerBlob").hp = Globals.generateOptions[1]
	size.x = Globals.generateOptions[2]
	size.y = Globals.generateOptions[3]
	numPlatforms = Globals.generateOptions[4]
	minWidth = Globals.generateOptions[5]
	maxWidth = Globals.generateOptions[6]
	numWalls = Globals.generateOptions[7]
	numEnemies = Globals.generateOptions[8]
	Guns = []
	for gun in Globals.generateOptions[9]:
		Guns.append(load(gun))
	
	create_platform(Vector2(-size.x, 0), size.x * 2)

	for i in range(0, numPlatforms):
		create_platform(Vector2(rand_range(-size.x / 2, size.x / 2), rand_range(0, -size.y)), rand_range(minWidth, maxWidth))
	
	
	for i in range(0, numWalls):
		create_wall(Vector2(rand_range(-size.x / 2, size.x / 2), rand_range(0, -size.y)))
	
	"""
	for x in range(-size.x / 2, size.x / 2):
		for y in range(-size.y / 2, size.y / 2):
			
			if get_cell(x, y) == INVALID_CELL:
				print ("No tile/cell at passed in coordinates!")
	"""


func _process(delta):
	if enemies < numEnemies:
		place_enemy(Vector2(rand_range(-size.x * 32, size.x * 32), rand_range(0, -size.y * 32)))
		enemies += 1
	else:
		get_parent().get_node("LevelEnd").genocideMode = true
