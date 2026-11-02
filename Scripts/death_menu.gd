extends Control

@onready var main = $/root/Game

func _on_menu_button_pressed() -> void:
	Engine.time_scale = 1
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	MusicController.play_track("res://Audio/Monkeys-Spinning-Monkeys(chosic.com).mp3")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
	print("menu")


func _on_respawn_button_pressed() -> void:
	Engine.time_scale = 1
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	MusicController.play_track("res://Audio/atlasaudio-adventure-adventure-music-576610.mp3")
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("respawn")
