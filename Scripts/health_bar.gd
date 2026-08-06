extends TextureProgressBar

@onready var player = $/root/Game/Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.min_value = 0
	self.max_value = 5
	self.value = 5

func change_value(health):
	self.value = health
