extends Node

# Sistema completo de gerenciamento de áudio
# Suporta música de fundo e efeitos sonoros com pool de players
#
# CRÉDITOS DE ÁUDIO:
# Sound Effects by LIECIO from Pixabay
# https://pixabay.com/pt/users/liecio-3298866/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=190022
# https://pixabay.com/sound-effects//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=190022

var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0

# Áudio players
var music_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 16  # Pool maior para múltiplos sons simultâneos

# Cache de streams de áudio (carregados uma vez, reutilizados)
var audio_cache: Dictionary = {}

# Sons programáticos básicos (fallback se não houver arquivos)
var use_programmatic_sounds: bool = false

func _ready():
	# Criar player de música
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	# Criar pool de players para SFX
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer_" + str(i)
		sfx_players.append(sfx_player)
		add_child(sfx_player)
	
	print("SoundManager inicializado com ", MAX_SFX_PLAYERS, " players de SFX")

# ========== FUNÇÕES PRINCIPAIS ==========

func play_music(stream: AudioStream, loop: bool = true, volume: float = 1.0):
	"""Toca música de fundo"""
	if not music_player:
		return
	
	# Parar música atual se estiver tocando
	if music_player.playing:
		music_player.stop()
	
	music_player.stream = stream
	if stream:
		# Configurar loop se for AudioStreamOggVorbis ou AudioStreamMP3
		if stream is AudioStreamOggVorbis:
			stream.loop = loop
		elif stream is AudioStreamMP3:
			stream.loop = loop
	
	music_player.volume_db = linear_to_db(music_volume * master_volume * volume)
	music_player.play()
	print("Música tocando: ", stream.resource_path if stream else "N/A")

func stop_music():
	"""Para a música de fundo"""
	if music_player and music_player.playing:
		music_player.stop()

func play_sfx(stream: AudioStream, volume: float = 1.0, pitch: float = 1.0):
	"""Toca um efeito sonoro usando um player disponível do pool"""
	if not stream:
		return
	
	# Encontrar player disponível
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume * master_volume * volume)
			player.pitch_scale = pitch
			player.play()
			return
	
	# Se todos os players estão ocupados, usar o primeiro (sobrescrever)
	if sfx_players.size() > 0:
		var player = sfx_players[0]
		player.stop()
		player.stream = stream
		player.volume_db = linear_to_db(sfx_volume * master_volume * volume)
		player.pitch_scale = pitch
		player.play()

func play_sfx_from_path(path: String, volume: float = 1.0, pitch: float = 1.0):
	"""Carrega e toca um arquivo de áudio do caminho especificado"""
	if path.is_empty():
		return
	
	# Verificar cache primeiro
	if audio_cache.has(path):
		play_sfx(audio_cache[path], volume, pitch)
		return
	
	# Carregar arquivo
	var stream = load(path)
	if stream and stream is AudioStream:
		audio_cache[path] = stream
		play_sfx(stream, volume, pitch)
	else:
		print("AVISO: Não foi possível carregar áudio de: ", path)

# ========== FUNÇÕES HELPER PARA SONS ESPECÍFICOS ==========

func play_jump_sound():
	"""Som de pulo do jogador"""
	play_sfx_from_path("res://audio/sfx/jump.ogg", 0.8, 1.0)
	# Fallback: criar som programático simples se não houver arquivo
	if not audio_cache.has("res://audio/sfx/jump.ogg"):
		_create_fallback_beep(0.15, 600, 0.3)

func play_land_sound():
	"""Som de aterrissagem"""
	play_sfx_from_path("res://audio/sfx/land.ogg", 0.6, 0.9)
	if not audio_cache.has("res://audio/sfx/land.ogg"):
		_create_fallback_beep(0.1, 300, 0.2)

func play_attack_sound():
	"""Som de ataque do jogador"""
	play_sfx_from_path("res://audio/sfx/attack.ogg", 1.0, 1.1)
	if not audio_cache.has("res://audio/sfx/attack.ogg"):
		_create_fallback_beep(0.1, 800, 0.4)

func play_coin_collect_sound():
	"""Som de coleta de moeda"""
	play_sfx_from_path("res://audio/sfx/coin.ogg", 1.0, 1.2)
	if not audio_cache.has("res://audio/sfx/coin.ogg"):
		_create_fallback_beep(0.15, 1000, 0.5)

func play_enemy_defeat_sound():
	"""Som de derrota de inimigo"""
	play_sfx_from_path("res://audio/sfx/enemy_defeat.ogg", 0.9, 0.8)
	if not audio_cache.has("res://audio/sfx/enemy_defeat.ogg"):
		_create_fallback_beep(0.2, 400, 0.3)

func play_damage_sound():
	"""Som de dano recebido"""
	play_sfx_from_path("res://audio/sfx/damage.ogg", 1.0, 0.9)
	if not audio_cache.has("res://audio/sfx/damage.ogg"):
		_create_fallback_beep(0.2, 200, 0.4)

func play_death_sound():
	"""Som de morte do jogador"""
	play_sfx_from_path("res://audio/sfx/death.ogg", 1.0, 0.7)
	if not audio_cache.has("res://audio/sfx/death.ogg"):
		_create_fallback_beep(0.3, 150, 0.5)

func play_portal_activate_sound():
	"""Som de ativação de portal"""
	play_sfx_from_path("res://audio/sfx/portal_activate.ogg", 0.8, 1.0)
	if not audio_cache.has("res://audio/sfx/portal_activate.ogg"):
		_create_fallback_beep(0.2, 500, 0.4)

func play_portal_success_sound():
	"""Som de resposta correta no portal"""
	play_sfx_from_path("res://audio/sfx/portal_success.ogg", 1.0, 1.1)
	if not audio_cache.has("res://audio/sfx/portal_success.ogg"):
		_create_fallback_beep(0.2, 800, 0.6)

func play_ui_click_sound():
	"""Som de clique em botão da UI"""
	play_sfx_from_path("res://audio/sfx/ui_click.ogg", 0.7, 1.0)
	if not audio_cache.has("res://audio/sfx/ui_click.ogg"):
		_create_fallback_beep(0.05, 1000, 0.2)

func play_ui_hover_sound():
	"""Som de hover em botão"""
	play_sfx_from_path("res://audio/sfx/ui_hover.ogg", 0.5, 1.1)
	if not audio_cache.has("res://audio/sfx/ui_hover.ogg"):
		_create_fallback_beep(0.05, 1200, 0.15)

func play_question_correct_sound():
	"""Som de resposta correta"""
	play_sfx_from_path("res://audio/sfx/question_correct.ogg", 1.0, 1.2)
	if not audio_cache.has("res://audio/sfx/question_correct.ogg"):
		_create_fallback_beep(0.2, 900, 0.5)

func play_question_wrong_sound():
	"""Som de resposta errada"""
	play_sfx_from_path("res://audio/sfx/question_wrong.ogg", 0.9, 0.8)
	if not audio_cache.has("res://audio/sfx/question_wrong.ogg"):
		_create_fallback_beep(0.2, 300, 0.4)

func play_footstep_sound():
	"""Som de passos (será chamado durante movimento)"""
	play_sfx_from_path("res://audio/sfx/footstep.ogg", 0.4, randf_range(0.9, 1.1))
	if not audio_cache.has("res://audio/sfx/footstep.ogg"):
		_create_fallback_beep(0.05, 400, 0.1)

func play_background_music():
	"""Toca música de fundo do jogo"""
	play_music(load("res://audio/music/background.ogg"), true, 1.0)
	if not audio_cache.has("res://audio/music/background.ogg"):
		print("AVISO: Música de fundo não encontrada em res://audio/music/background.ogg")

# ========== CONTROLES DE VOLUME ==========

func set_master_volume(volume: float):
	"""Define o volume mestre (0.0 a 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)
	_update_all_volumes()

func set_music_volume(volume: float):
	"""Define o volume da música (0.0 a 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(volume: float):
	"""Define o volume dos efeitos sonoros (0.0 a 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	# Volume dos players ativos será atualizado na próxima reprodução

func _update_all_volumes():
	"""Atualiza volumes de todos os players ativos"""
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	
	# SFX players serão atualizados na próxima reprodução

# ========== FUNÇÕES AUXILIARES ==========

func _create_fallback_beep(duration: float, frequency: float, volume: float):
	"""Cria um beep programático simples como fallback"""
	# Nota: Em produção, você deve usar arquivos de áudio reais
	# Esta função é apenas um placeholder
	use_programmatic_sounds = true
	# Por enquanto, apenas print (em produção, você pode usar AudioStreamGenerator)
	print("AVISO: Som programático não implementado. Adicione arquivos de áudio em res://audio/")

func get_master_volume() -> float:
	return master_volume

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

func is_music_playing() -> bool:
	return music_player and music_player.playing

func clear_audio_cache():
	"""Limpa o cache de áudio (útil para liberar memória)"""
	audio_cache.clear()
