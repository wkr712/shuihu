# scripts/autoload/audio_manager.gd
# 管理音乐和音效播放。
# Autoload 单例: AudioManager

extends Node

## 音频总线
enum Bus {
	MASTER,
	MUSIC,
	SFX,
}

## 配置
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0

## 内部状态
var _music_players: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _current_music: String = ""

const MAX_SFX_PLAYERS: int = 8


func _ready() -> void:
	_setup_buses()
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func _setup_buses() -> void:
	AudioServer.add_bus()
	AudioServer.set_bus_name(1, "Music")
	AudioServer.set_bus_send(1, "Master")

	AudioServer.add_bus()
	AudioServer.set_bus_name(2, "SFX")
	AudioServer.set_bus_send(2, "Master")


## 音乐播放（带淡入淡出）
func play_music(stream_path: String, fade_duration: float = 1.0) -> void:
	if stream_path == _current_music:
		return

	var stream := load(stream_path) as AudioStream
	if not stream:
		push_warning("AudioManager: Cannot load music: %s" % stream_path)
		return

	_current_music = stream_path

	# 淡出旧音乐
	if _music_players.has("music"):
		var old_player: AudioStreamPlayer = _music_players["music"]
		var tween := create_tween()
		tween.tween_property(old_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(old_player.queue_free)
		_music_players.erase("music")

	# 创建新播放器
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Music"
	player.volume_db = -80.0
	add_child(player)
	player.play()

	# 淡入
	var tween := create_tween()
	tween.tween_property(player, "volume_db", linear_to_db(music_volume), fade_duration)

	_music_players["music"] = player


func stop_music(fade_duration: float = 1.0) -> void:
	if _music_players.has("music"):
		var player: AudioStreamPlayer = _music_players["music"]
		var tween := create_tween()
		tween.tween_property(player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(player.queue_free)
		_music_players.erase("music")
	_current_music = ""


## 音效播放
func play_sfx(stream_path: String, pitch_variation: float = 0.0) -> void:
	var stream := load(stream_path) as AudioStream
	if not stream:
		push_warning("AudioManager: Cannot load SFX: %s" % stream_path)
		return

	var player := _get_available_sfx_player()
	if not player:
		return

	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	_sfx_players[0].stop()
	return _sfx_players[0]


## 音量控制
func set_bus_volume(bus: Bus, volume: float) -> void:
	var bus_idx := bus as int
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

	match bus:
		Bus.MASTER:
			master_volume = volume
		Bus.MUSIC:
			music_volume = volume
		Bus.SFX:
			sfx_volume = volume
