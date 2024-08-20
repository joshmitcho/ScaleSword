extends Node2D
class_name Main

const CROWD_CHEERING = preload("res://Sound/crowd_cheering.mp3")
const ENEMY_BASE: PackedScene = preload("res://Scenes/enemy.tscn")
const LEVELS: Array = [
	[1, 1],
	[2, 3],
	[3, 6],
	[4, 9],
	[5, 12],
	[7, 16],
	[10, 20],
	[15, 25],
	[20, 30],
	[25, 35],
	[30, 40],
	[35, 50]
]
const ENEMY_SPAWNS: Array = [
	Vector2(100, 100), Vector2(1180, 0),
	Vector2(100, 540), Vector2(1180, 540)
]

@onready var ui: UI = $UI

var last_enemy_spawned_time: int = 0
var enemy_spawn_threshold: int = 1900
var max_enemies_on_screen: int
var enemies_on_screen: int
var current_level: int
var enemies_spawned_this_level: int
var enemies_killed_this_level: int
var next_level_threshold: int
var enemy_dex: Array[int]


func _ready() -> void:
	randomize()
	Autoload.enemy_killed.connect(enemy_killed)
	Autoload.next_level.connect(next_level)
	Autoload.restart.connect(restart_game)
	set_game_level(0)
	SoundManager.play_soundscape(CROWD_CHEERING, -6)
	await SoundManager.soundscape_player.finished
	SoundManager.play_soundscape(CROWD_CHEERING, -6)


func _physics_process(_delta: float) -> void:
	if Autoload.paused:
		return
	if enemies_on_screen < max_enemies_on_screen and enemies_spawned_this_level < next_level_threshold:
		var current_time: int = Time.get_ticks_msec()
		if current_time > last_enemy_spawned_time + enemy_spawn_threshold:
			last_enemy_spawned_time = current_time
			spawn_enemy()


func spawn_enemy() -> void:
	var new_enemy: Enemy = ENEMY_BASE.instantiate()
	new_enemy.position = ENEMY_SPAWNS.pick_random()
	add_child(new_enemy)
	#var enemy_type: int = enemies_spawned_this_level / (current_level + 1)
	new_enemy.initialize(enemy_dex[enemies_spawned_this_level])
	enemies_on_screen += 1
	enemies_spawned_this_level += 1


func enemy_killed(_enemy: Enemy) -> void:
	enemies_on_screen -= 1
	enemies_killed_this_level += 1
	last_enemy_spawned_time = Time.get_ticks_msec()
	
	if enemies_killed_this_level >= next_level_threshold:
		Autoload.level_complete.emit(current_level)


func next_level() -> void:
	set_game_level(current_level + 1)


func set_game_level(level: int) -> void:
	current_level = level
	enemies_on_screen = 0
	last_enemy_spawned_time = Time.get_ticks_msec()
	max_enemies_on_screen = LEVELS[level][0]
	next_level_threshold = LEVELS[level][1]
	enemies_killed_this_level = 0
	enemies_spawned_this_level = 0
	enemy_dex = []
	for enemy_num in LEVELS[current_level][1]:
		var enemy_type: int = enemy_num / (current_level + 1)
		#print(str(current_level) + ": " + str(enemy_type))
		enemy_dex.append(min(enemy_type, 2))
	enemy_dex.shuffle()


func restart_game() -> void:
	set_game_level(0)

