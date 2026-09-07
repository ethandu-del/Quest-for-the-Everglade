extends Control

@onready var button_press_audio = $button_press_sfx

func _on_button_pressed() -> void:
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	MusicController.play_track("res://Audio/atlasaudio-adventure-adventure-music-576610.mp3")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_settings_button_pressed() -> void:
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	get_tree().change_scene_to_file("res://Prefabs/settings_menu.tscn")


func _on_quit_button_pressed() -> void:
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	print("doesnt exist yet")
