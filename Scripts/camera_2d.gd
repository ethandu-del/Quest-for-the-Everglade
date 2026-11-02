extends Camera2D

@export var decay : float = 0.8
@export var max_offset : Vector2 = Vector2(100, 75)
@export var max_roll : float = 0.1
@onready var game = $".."

@onready var stamina_bar: TextureProgressBar = $Stamina_bar
var is_exhausted: bool = false

var trauma : float = 0.0
var trauma_power : int = 2

var max_stamina: float = 100.0
var current_stamina: float = 100.0
var regen_rate: float = 15.0
var drain_rate: float = 40.0 

var camera_moving: bool = false

func _ready() -> void:
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	randomize()

func _process(delta: float) -> void:
	
	if not camera_moving:
		if Input.is_action_pressed("dash") and current_stamina > 0.0 and not is_exhausted:
			use_stamina(drain_rate * delta)
		else:
			regenerate_stamina(regen_rate * delta)
	
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount : float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func move_camera_up(target_y_position: float, duration: float):
	var player = get_tree().get_first_node_in_group("player")
	camera_moving = true
	
	player.set_process(false)
	player.set_physics_process(false)
	if global_position.y != target_y_position:
		var tween = create_tween()
		# Moves the camera up to target_y_position over the set duration
		tween.tween_property(self, "position:y", target_y_position, duration)
	
		await tween.finished
	
	camera_moving = false
	player.set_process(true)
	player.set_physics_process(true)

func use_stamina(amount: float) -> void:
	current_stamina -= amount
	current_stamina = clamp(current_stamina, 0.0, max_stamina)
	stamina_bar.value = current_stamina
	
	if current_stamina <= 0.0:
		is_exhausted = true

func regenerate_stamina(amount: float) -> void:
	current_stamina += amount
	current_stamina = clamp(current_stamina, 0.0, max_stamina)
	stamina_bar.value = current_stamina
	
	if current_stamina >= 30.0:
		is_exhausted = false
