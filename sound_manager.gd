extends Node

# Sistema de gerenciamento de som (estrutura para adicionar sons depois)

var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0

# Áudio players (serão adicionados quando tiver arquivos de som)
var music_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []

func _ready():
	# Criar players de áudio
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Criar pool de players para SFX
	for i in range(8):
		var sfx_player = AudioStreamPlayer.new()
		sfx_players.append(sfx_player)
		add_child(sfx_player)

func play_music(stream: AudioStream, loop: bool = true):
	if music_player:
		music_player.stream = stream
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		if loop:
			music_player.stream.set_loop(loop)
		music_player.play()

func play_sfx(stream: AudioStream, volume: float = 1.0):
	# Encontrar player disponível
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume * master_volume * volume)
			player.play()
			return

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	for player in sfx_players:
		if player.playing:
			player.volume_db = linear_to_db(sfx_volume * master_volume)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		if player.playing:
			player.volume_db = linear_to_db(sfx_volume * master_volume)



