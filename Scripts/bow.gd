extends Node2D

@onready var anim = $bow_sprite

func _ready() -> void:
	pass


func _on_player_shoot() -> void:
	anim.play("bow_shoot")
