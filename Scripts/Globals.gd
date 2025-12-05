extends Node


export(String) var savePath = "user://blob-u2e.save"
var unlockedLevel = 1
var levelScores = []
var levelTimes = []
var bestTime = null
var lastPlayed = 1
var totalTrickScore = 0
var totalKilled = 0
var totalDeaths = 0
var totalPlaytime = 0

var speedrunMode = false
var generateOptions = []
var totalTime = null


func save_progress():
	var f = File.new()
	f.open_encrypted_with_pass(savePath, File.WRITE, OS.get_unique_id())
	f.store_var(unlockedLevel)
	f.store_var(levelScores)
	f.store_var(levelTimes)
	f.store_var(bestTime)
	f.store_var(lastPlayed)
	f.store_var(totalTrickScore)
	f.store_var(totalKilled)
	f.store_var(totalDeaths)
	f.store_var(totalPlaytime)
	f.close()


func load_settings():
	var f = File.new()
	if f.file_exists(savePath):
		f.open_encrypted_with_pass(savePath, File.READ, OS.get_unique_id())
		unlockedLevel = f.get_var()
		levelScores = f.get_var()
		levelTimes = f.get_var()
		bestTime = f.get_var()
		lastPlayed = f.get_var()
		totalTrickScore = f.get_var()
		totalKilled = f.get_var()
		totalDeaths = f.get_var()
		totalPlaytime = f.get_var()
		f.close()


func _ready():
	load_settings()
	randomize()


func _process(delta):
	totalPlaytime += delta
