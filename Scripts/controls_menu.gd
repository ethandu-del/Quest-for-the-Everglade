extends Control



func _on_button_pressed() -> void:
	MusicController.play_sfx("res://Audio/button_press_sound.mp3")
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
