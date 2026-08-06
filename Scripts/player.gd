extends CharacterBody2D

@export var speed = 200
@export var max_health = 5
var health = max_health

var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var bow := $Bow
@onready var weapon_pivot : Marker2D= $WeaponPivot
@onready var shoot_timer: Timer = $shoot_timer
@onready var animation := $AnimatedSprite2D
@onready var healthbar = $/root/Game/Camera2D/Health_bar
@onready var camera = $/root/Game/Camera2D


@export var friction: float = 800
var knockback_velocity: Vector2 = Vector2.ZERO

@export var weapon_hold_distance: float = 30

var can_shoot: bool = true
signal shoot

func _process(delta: float) -> void:
	var mouse_direction := weapon_pivot.global_position.direction_to(get_global_mouse_position())
	bow.global_position = weapon_pivot.global_position + mouse_direction * weapon_hold_distance
	bow.scale.y = 0.5 if mouse_direction.x > 0 else -0.5
	bow.show_behind_parent = mouse_direction.y < 0
	bow.look_at(get_global_mouse_position())

func player_movement():
	var player_direction = Vector2.ZERO
	
	player_direction.x = Input.get_axis("ui_left", "ui_right") * speed
	player_direction.y = Input.get_axis("ui_up", "ui_down") * speed
	
	if player_direction.length() > 1.0:
		player_direction = player_direction.normalized()
	
	var player_velocity = player_direction * speed
	velocity = player_velocity
	
	if velocity != Vector2.ZERO:
		animation.play("Walk")
	elif velocity == Vector2.ZERO:
		animation.play("Idle")
	
	return player_velocity

func apply_knockback(from_position: Vector2, force: float) -> void:
	var direction = (global_position - from_position).normalized()
	knockback_velocity = direction * force


func _physics_process(delta: float) -> void:
	
	player_movement()
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)
	var normal_velocity = player_movement()
	velocity = normal_velocity + knockback_velocity
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		camera.add_trauma(0.2)
		shoot.emit
		shoot_timer.start()
		var bullet = bullet_scene.instantiate()
		bullet.global_position = bow.global_position
		bullet.look_at(get_global_mouse_position())
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		$/root/Game.add_child(bullet)
		$/root/Game.move_child(bullet, 1)
	
	move_and_slide()
	
	if health == 0 or health < 0:
		global_position = Vector2(1000, 1000)
		Engine.time_scale = 0


func _on_timer_timeout() -> void:
	can_shoot = true

func take_damage():
	health = health - 1
	camera.add_trauma(0.2)
	healthbar.change_value(health)
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
