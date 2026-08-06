extends Node2D

@export var level_dificulty: int = 5

@export var player_scene = preload("res://Prefabs/player.tscn")
@export var enemy_scene = preload("res://Prefabs/slime.tscn")
@export var background_closed_scene = preload("res://Backgrounds/background_closed.tscn")
@export var background_open_finished_scene = preload("res://Backgrounds/background_open_finished.tscn")
@export var background_open_start_finished_scene = preload("res://Backgrounds/background_open_start.tscn")
@export var win_particles_scene = preload("res://Prefabs/win_particles.tscn")
@onready var background_open = $background_open
@onready var camera = $Camera2D
@onready var player_spawn: Marker2D = $player_spawn
@onready var enemy_spawn_area = $Player_enemy_spawn
@onready var pause_menu = $Camera2D/Pause_menu
var paused : bool = false

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
	
	if camera.global_position.y == 0:
		background_open_finish = background_open_start_finished_scene.instantiate()
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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func enemy_spawn_func(pos: Vector2):
	
	var background_closed = background_closed_scene.instantiate()
	background_closed.global_position = camera.global_position
	
	add_child(background_closed)
	
	for i in level_dificulty:
		var enemy = enemy_scene.instantiate()
		var enemy_spawn_rand = Vector2(randi_range(-400, 400), randi_range(-200, 0))
		enemy.global_position = (pos + enemy_spawn_rand)
		add_child(enemy)
		move_child(enemy, 1)
	
	level_dificulty += 2
