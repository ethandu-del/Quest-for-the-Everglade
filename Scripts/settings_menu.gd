extends Control

var master_bus_index = AudioServer.get_bus_index("Master")
var sfx_bus_index = AudioServer.get_bus_index("SFX")
var music_bus_index = AudioServer.get_bus_index("Music")
@onready var difficulty : HSlider = $MarginContainer/VBoxContainer/difficulty_slider
@onready var label = $MarginContainer/VBoxContainer/difficulty_display

func _ready() -> void:
	difficulty.value = GameManager.difficulty_level
	update_label(difficulty.value)
	
	difficulty.value_changed.connect(_on_difficulty_slider_value_changed)
	
	

func _on_back_button_pressed() -> void:
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")


func _on_difficulty_slider_value_changed(value: float) -> void:
	GameManager.difficulty_level = int(value)
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	update_label(value)

func update_label(val: float) -> void:
	match int(val):
		1: label.text = "Easy"
		2: label.text = "Normal"
		3: label.text = "Hard"
		4: label.text = "Debug Mode"
	


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
