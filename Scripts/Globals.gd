extends Node


export(String) var savePath = "user://blob-u2e.save"
export(String) var newSavePath = "user://blob-redux.save"
export(String) var optionsSavePath = "user://blob-option.save"
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

var musicVolume = 0.0
var effectsVolume = -4.0
var reduceFlash = false
var reduceShake = false


func save_progress(path=newSavePath):
	var f = File.new()
	f.open_encrypted_with_pass(path, File.WRITE, OS.get_unique_id())
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
	
	f = File.new()
	f.open(optionsSavePath, File.WRITE)
	f.store_var(musicVolume)
	f.store_var(effectsVolume)
	f.store_var(reduceFlash)
	f.store_var(reduceShake)
	f.close()


func load_settings(path=newSavePath):
	var f = File.new()
	if f.file_exists(path):
		f.open_encrypted_with_pass(path, File.READ, OS.get_unique_id())
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
	
	f = File.new()
	if f.file_exists(optionsSavePath):
		f.open(optionsSavePath, File.READ)
		musicVolume = f.get_var()
		effectsVolume = f.get_var()
		reduceFlash = f.get_var()
		reduceShake = f.get_var()
		f.close()


func _ready():
	var nf = File.new()
	if not nf.file_exists(newSavePath):
		load_settings(savePath)
		save_progress(newSavePath)
		nf.close()
	else:
		load_settings()
	randomize()


func _process(delta):
	totalPlaytime += delta
