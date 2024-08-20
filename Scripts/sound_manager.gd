# sound_manager.gd
extends Node

var sfx_pitches: Array[float] = [0.943874, 1.0, 1.059463, 1.122455, 1.33484]
var sfx_pitch_index: int = 0

var soundscape_player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(soundscape_player)


func play_soundscape(soundscape: AudioStream, volume: float) -> void:
	if soundscape_player.is_playing() and soundscape_player.get_stream() != soundscape:
		dip_fade(soundscape_player, soundscape, volume, randf_range(0, soundscape.get_length()))
	else:
		fade_in(soundscape_player, soundscape, volume, randf_range(0, soundscape.get_length()))


func dip_fade(player: AudioStreamPlayer, sound: AudioStream, volume: float, offset: float) -> void:
	await fade_out(player)
	fade_in(player, sound, volume, offset)


func fade_in(player: AudioStreamPlayer, sound: AudioStream, volume: float, offset: float = 0) -> void:
	var tween: Tween = get_tree().create_tween()
	player.set_stream(sound)
	player.set_volume_db(-24)
	player.play(offset)
	tween.tween_property(player, "volume_db", volume, 1.0)


func fade_out(player: AudioStreamPlayer) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(player, "volume_db", -48, 1.0)
	await tween.finished
	player.stop()


func is_soundscape_playing(soundscape: AudioStream) -> bool:
	return soundscape_player.is_playing() and soundscape_player.get_stream() == soundscape


func play_sfx(sfx: AudioStream, pitch: float = 1.0, volume: float = 0) -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.set_stream(sfx)
	sfx_player.set_pitch_scale(pitch)
	sfx_player.set_volume_db(volume)
	sfx_player.play()
	await sfx_player.finished
	remove_child(sfx_player)
	sfx_player.queue_free()


func play_shuffled_pitch_sfx(sfx: AudioStream, volume: float = 0) -> void:
	play_sfx(sfx, sfx_pitches[sfx_pitch_index], volume)
	sfx_pitch_index += 1
	if sfx_pitch_index >= sfx_pitches.size():
		sfx_pitches.shuffle()
		sfx_pitch_index = 0

