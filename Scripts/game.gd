extends Node2D

@export var player_scene = preload("res://Prefabs/player.tscn")

@export var background_closed_scene = preload("res://Backgrounds/background_closed.tscn")

@export var background_open_finished_scene = preload("res://Backgrounds/background_open_finished.tscn")
@export var background_open_start_finished_scene = preload("res://Backgrounds/background_open_start.tscn")
@onready var background_open = $background_open
@onready var background_open_finish_finished = preload("res://Backgrounds/background_open_finish_finished.tscn")

@onready var music = $AudioStreamPlayer2D

@export var win_particles_scene = preload("res://Prefabs/win_particles.tscn")
@onready var camera = $Camera2D
@onready var player_spawn: Marker2D = $player_spawn
@onready var pause_menu = $Camera2D/Pause_menu
@onready var death_menu = $Camera2D/death_menu
@onready var finish_menu = $Camera2D/Finish_scene
var paused : bool = false
var dead : bool = false

var level_no: int = 1

var budget: int = 0

var extradiff: int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = player_scene.instantiate()
	player.global_position = player_spawn.global_position
	add_child(player)
	move_child(player, 1)
	
	
func check_group_count():
	var remaining_ememies = get_tree().get_nodes_in_group("enemies")
	if remaining_ememies.size() == 0:
		level_beat()

func level_beat():
	var background_closed = $/root/Game/background_closed
	var background_open_finish = background_open_finished_scene.instantiate()
	var boss_defeated = GameManager.boss_defeated
	
	if camera.global_position.y == 0:
		background_open_finish = background_open_start_finished_scene.instantiate()
	elif boss_defeated == true:
		print("Boss dead")
		background_open_finish = background_open_finish_finished.instantiate()
		MusicController.play_track("res://Audio/Victory_music.mp3")
		finish_menu.show()
		GameManager.boss_defeated = false
		Engine.time_scale = 0
		get_tree().paused = true
	else:
		background_open_finish = background_open_finished_scene.instantiate()
	background_open_finish.global_position = background_closed.global_position
	background_closed.queue_free()
	var win_particles = win_particles_scene.instantiate()
	win_particles.global_position = camera.global_position
	win_particles.emitting = true
	add_child(background_open_finish)
	add_child(win_particles)
	move_child(win_particles, 1)
	
	level_no += 1.0

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		get_tree().paused = false
	else:
		pause_menu.show()
		Engine.time_scale = 0
		get_tree().paused = true
	paused = !paused

func deathMenu():
	dead = true
	if dead == true:
		death_menu.show()
		Engine.time_scale = 0
		get_tree().paused = true
	dead = !dead
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func enemy_spawn_func():
	
	var background_closed = background_closed_scene.instantiate()
	background_closed.global_position = camera.global_position
	
	add_child(background_closed)

func level_budget():
	
	match GameManager.difficulty_level:
		1: budget = randi_range(30 + (15 * level_no), 90 + (15 * level_no))
			
		2: budget = randi_range(40 + (20 * level_no), 100 + (20 * level_no))
		
		3: budget = randi_range(40 + (30 * level_no), 100 + (30 * level_no))
		
		4: budget = 10
	
	budget += GameManager.extradiff
	return budget
