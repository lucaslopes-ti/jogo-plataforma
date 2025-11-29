extends Node

# Gerenciador de configurações do jogo
# Salva e carrega todas as preferências do usuário

signal settings_changed

# Configurações padrão
var default_settings = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.7,
		"sfx_volume": 1.0
	},
	"video": {
		"fullscreen": false,
		"vsync": true,
		"resolution": {
			"width": 1920,
			"height": 1080
		}
	},
	"gameplay": {
		"difficulty": 1,
		"show_tutorial": true
	},
	"controls": {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
		"attack": KEY_J
	}
}

var current_settings: Dictionary = {}
var settings_path = "user://settings.json"

func _ready():
	print("SettingsManager inicializando...")
	load_settings()
	apply_settings()
	# Sincronizar volumes com SoundManager se já existir
	if SoundManager:
		SoundManager.set_master_volume(get_master_volume())
		SoundManager.set_music_volume(get_music_volume())
		SoundManager.set_sfx_volume(get_sfx_volume())
		print("Volumes sincronizados com SoundManager")
	print("SettingsManager pronto!")

func load_settings():
	"""Carrega configurações do arquivo"""
	if FileAccess.file_exists(settings_path):
		var file = FileAccess.open(settings_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				current_settings = json.data
				# Garantir que todas as chaves existam
				_merge_defaults()
			else:
				current_settings = default_settings.duplicate(true)
		else:
			current_settings = default_settings.duplicate(true)
	else:
		current_settings = default_settings.duplicate(true)
	
	print("Configurações carregadas")

func save_settings():
	"""Salva configurações no arquivo"""
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(current_settings)
		file.store_string(json_string)
		file.close()
		print("Configurações salvas")
		settings_changed.emit()

func _merge_defaults():
	"""Garante que todas as chaves padrão existam nas configurações carregadas"""
	for key in default_settings:
		if not current_settings.has(key):
			current_settings[key] = default_settings[key].duplicate(true)
		elif default_settings[key] is Dictionary:
			for sub_key in default_settings[key]:
				if not current_settings[key].has(sub_key):
					current_settings[key][sub_key] = default_settings[key][sub_key]

func apply_settings():
	"""Aplica as configurações carregadas ao jogo"""
	# Aplicar configurações de áudio
	if SoundManager:
		if current_settings.has("audio"):
			var audio = current_settings.audio
			if audio.has("master_volume"):
				SoundManager.set_master_volume(audio.master_volume)
			if audio.has("music_volume"):
				SoundManager.set_music_volume(audio.music_volume)
			if audio.has("sfx_volume"):
				SoundManager.set_sfx_volume(audio.sfx_volume)
	
	# Aplicar configurações de vídeo
	if current_settings.has("video"):
		var video = current_settings.video
		if video.has("fullscreen"):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if video.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		if video.has("vsync"):
			if video.vsync:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			else:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		if video.has("resolution"):
			var res = video.resolution
			if res.has("width") and res.has("height"):
				DisplayServer.window_set_size(Vector2i(res.width, res.height))
				DisplayServer.window_set_position(DisplayServer.screen_get_usable_rect().size / 2 - Vector2i(res.width, res.height) / 2)

# ========== GETTERS E SETTERS ==========

func get_master_volume() -> float:
	if current_settings.has("audio") and current_settings.audio.has("master_volume"):
		return current_settings.audio.master_volume
	return default_settings.audio.master_volume

func set_master_volume(volume: float):
	if not current_settings.has("audio"):
		current_settings.audio = {}
	current_settings.audio.master_volume = clamp(volume, 0.0, 1.0)
	if SoundManager:
		SoundManager.set_master_volume(current_settings.audio.master_volume)
	save_settings()

func get_music_volume() -> float:
	if current_settings.has("audio") and current_settings.audio.has("music_volume"):
		return current_settings.audio.music_volume
	return default_settings.audio.music_volume

func set_music_volume(volume: float):
	if not current_settings.has("audio"):
		current_settings.audio = {}
	current_settings.audio.music_volume = clamp(volume, 0.0, 1.0)
	if SoundManager:
		SoundManager.set_music_volume(current_settings.audio.music_volume)
	save_settings()

func get_sfx_volume() -> float:
	if current_settings.has("audio") and current_settings.audio.has("sfx_volume"):
		return current_settings.audio.sfx_volume
	return default_settings.audio.sfx_volume

func set_sfx_volume(volume: float):
	if not current_settings.has("audio"):
		current_settings.audio = {}
	current_settings.audio.sfx_volume = clamp(volume, 0.0, 1.0)
	if SoundManager:
		SoundManager.set_sfx_volume(current_settings.audio.sfx_volume)
	save_settings()

func get_fullscreen() -> bool:
	if current_settings.has("video") and current_settings.video.has("fullscreen"):
		return current_settings.video.fullscreen
	return default_settings.video.fullscreen

func set_fullscreen(enabled: bool):
	if not current_settings.has("video"):
		current_settings.video = {}
	current_settings.video.fullscreen = enabled
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func get_vsync() -> bool:
	if current_settings.has("video") and current_settings.video.has("vsync"):
		return current_settings.video.vsync
	return default_settings.video.vsync

func set_vsync(enabled: bool):
	if not current_settings.has("video"):
		current_settings.video = {}
	current_settings.video.vsync = enabled
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	save_settings()

func get_resolution() -> Vector2i:
	if current_settings.has("video") and current_settings.video.has("resolution"):
		var res = current_settings.video.resolution
		if res.has("width") and res.has("height"):
			return Vector2i(res.width, res.height)
	return Vector2i(default_settings.video.resolution.width, default_settings.video.resolution.height)

func set_resolution(width: int, height: int):
	if not current_settings.has("video"):
		current_settings.video = {}
	if not current_settings.video.has("resolution"):
		current_settings.video.resolution = {}
	current_settings.video.resolution.width = width
	current_settings.video.resolution.height = height
	DisplayServer.window_set_size(Vector2i(width, height))
	DisplayServer.window_set_position(DisplayServer.screen_get_usable_rect().size / 2 - Vector2i(width, height) / 2)
	save_settings()

func reset_to_defaults():
	"""Reseta todas as configurações para os valores padrão"""
	current_settings = default_settings.duplicate(true)
	apply_settings()
	save_settings()

