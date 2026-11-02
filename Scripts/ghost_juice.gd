extends Area2D

var velocity: Vector2 = Vector2.ZERO

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func setup(dir_speed: Vector2) -> void:
	velocity = dir_speed
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		body.apply_knockback(global_position, 100)
		queue_free()
		
