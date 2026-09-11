extends AudioStreamPlayer
class_name Music

signal purchased_song(song)
signal updated_playlists()

@export var all_songs : Array[Song] = []
var owned_songs : PackedInt32Array = [2, 3, 5, 8, 11, 12]
var main_playlist : PackedInt32Array = [2, 8, 12]
var play_playlist : PackedInt32Array = [3, 5, 11]
var jukebox_playlist : PackedInt32Array = [2, 3, 5, 8, 11, 12]
@export var silent_song : Song

@onready var anim : AnimationPlayer = $anim
enum STATE {MENU, PLAY, PAUSE}
var current_state : STATE = STATE.MENU
var current_song : Song = null

var playback_time : float = -0
var timer_remaining : float = 0
@onready var audio_timer : Timer = $audio_timer


func set_state(new_state : STATE):
	if new_state == STATE.MENU:
		anim.play("intro_ramp")
		print("MUSIC: intro_ramp")
	if new_state == STATE.PLAY:
		if current_state == STATE.MENU:
			anim.play("start_play")
		if current_state == STATE.PAUSE:
			if playback_time >= 0:
				play(playback_time)
			if timer_remaining >= 0:
				audio_timer.start(timer_remaining)
			anim.play("resume_play")
	if new_state == STATE.PAUSE:
		if current_state == STATE.PLAY:
			playback_time = -1
			anim.play("pause_play")
	current_state = new_state


func set_track_random():
	print("MUSIC: set_track_random")
	var matched_song : Song = silent_song
	if current_state == STATE.MENU and main_playlist.size() > 0:
		var idx = main_playlist[randi_range(0, main_playlist.size() - 1)]
		matched_song = all_songs[idx]
	if current_state == STATE.PLAY and play_playlist.size() > 0:
		var idx = play_playlist[randi_range(0, play_playlist.size() - 1)]
		matched_song = all_songs[idx]
	stream = matched_song.track
	current_song = matched_song
	audio_timer.start(stream.get_length() - 2.0)
	play()


func _on_finished():
	anim.play("queue_next")
	print("MUSIC: queue_next")


func capture_playback_time():
	playback_time = get_playback_position()
	timer_remaining = audio_timer.time_left
	audio_timer.stop()
	stop()


func _on_audio_timer_timeout() -> void:
	audio_timer.stop()
	if current_song.crossfade:
		print("MUSIC: fade_out")
		anim.play("fade_out")


func playlist_edit(playlist : String, song : Song, add_remove : bool) -> void:
	var song_library_idx : int = all_songs.find(song)
	print("Editing: ", playlist, " with song: ", song_library_idx, ": ", song.title, " ADD: ", add_remove)
	if playlist == "work":
		if play_playlist.has(song_library_idx) and !add_remove:
			play_playlist.remove_at(play_playlist.find(song_library_idx))
		elif !play_playlist.has(song_library_idx) and add_remove:
			play_playlist.append(song_library_idx)
	if playlist == "menu":
		if main_playlist.has(song_library_idx) and !add_remove:
			main_playlist.remove_at(main_playlist.find(song_library_idx))
		elif !main_playlist.has(song_library_idx) and add_remove:
			main_playlist.append(song_library_idx)
	if playlist == "jukebox":
		if jukebox_playlist.has(song_library_idx) and !add_remove:
			jukebox_playlist.remove_at(jukebox_playlist.find(song_library_idx))
		elif !jukebox_playlist.has(song_library_idx) and add_remove:
			jukebox_playlist.append(song_library_idx)
	print("SAVE PLAYLIST")
	emit_signal("updated_playlists")
