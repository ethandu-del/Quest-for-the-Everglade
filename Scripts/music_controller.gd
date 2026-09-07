extends Node

@onready var audio_player = $Music_player
@onready var sfx_player = $SFX_player

func play_track(track_path: String):
	if audio_player.stream and audio_player.stream.resource_path == track_path:
		return
	
	var new_track = load(track_path)
	audio_player.stream = new_track
	audio_player.play()

func play_sfx(sfx_path: String):
	sfx_player.stream = load(sfx_path)
	sfx_player.play()
