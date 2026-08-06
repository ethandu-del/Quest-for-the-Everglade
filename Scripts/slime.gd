extends CharacterBody2D

@onready var player = $/root/Game/player
@onready var anim = $AnimatedSprite2D
@export var max_health: int = 3
@export var friction: float = 800
var knockback_velocity: Vector2 = Vector2.ZERO
var health = max_health

var speed = randi_range(35, 45)

func _process(delta: float) -> void:
	randomize()

func take_damage():
	health = health - 1
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	check_is_dead()

func check_is_dead():
	if health == 0 or health < 0:
		remove_from_group("enemies")
		queue_free()

func ai_movement():
	var random_move = Vector2(randi_range(-200,200), randi_range(-200,200))
	var slime_velocity = ((player.global_position) - global_position).normalized() * speed
	velocity = slime_velocity
	anim.play("move")
	
	move_and_slide()
	return slime_velocity

func apply_knockback(from_position: Vector2, force: float) -> void:
	var direction = (global_position - from_position).normalized()
	knockback_velocity = direction * force

func _physics_process(delta: float) -> void:
	ai_movement()
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)
	var normal_velocity = ai_movement()
	velocity = normal_velocity + knockback_velocity
	move_and_slide()

# contact with the player node
# damage
# knockback
func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		body.apply_knockback(global_position, 250)
		apply_knockback(player.global_position, 400)
		
	
