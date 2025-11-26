extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var question_ui = $QuestionUI
@onready var login_system = $LoginSystem

var player_start_position = Vector2(200, 368)
var current_phase: int = 1
var game_mode: String = "adventure"  # adventure, endless, multiplayer

func _ready():
	print("MathQuest iniciado!")
	
	# NÃO pausar o jogo ainda - deixar o login funcionar
	# O login_system vai pausar quando necessário
	
	# Conectar sistema de login
	if login_system:
		login_system.user_logged_in.connect(_on_user_logged_in)
		# Não inicializar jogo até login
		return
	
	initialize_game()

func initialize_game():
	# Fade in ao iniciar
	if ScreenEffects:
		ScreenEffects.fade_in(0.8)
	
	print("Use as setas para mover e ESPAÇO para pular")
	print("Responda perguntas nos portais para avançar!")
	
	# Verificar se há múltiplos jogadores
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 1:
		print("AVISO: Múltiplos jogadores encontrados: ", players.size())
	
	if player:
		player.add_to_group("player")
		player.collected_coin.connect(_on_player_collected_coin)
		player.player_died.connect(_on_player_died)
		
		# Configurar limites da câmera
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = -1000
			camera.limit_right = 5000
			camera.limit_top = -1000
			camera.limit_bottom = 2000
	
	# Conectar portais de perguntas
	await get_tree().process_frame
	connect_question_portals()
	
	# Adicionar UI ao grupo para acesso fácil
	if ui:
		ui.add_to_group("ui")
	
	# Mostrar tutorial após login (se não foi mostrado antes)
	if ui:
		await get_tree().process_frame
		if ui.tutorial_panel and not ui.tutorial_panel.visible:
			ui.tutorial_panel.visible = true
			get_tree().paused = true

func _on_user_logged_in(user_data: Dictionary):
	print("Usuário logado: ", user_data.username)
	# Esconder login e inicializar jogo
	if login_system:
		login_system.login_panel.visible = false
	initialize_game()

func connect_question_portals():
	for portal in get_tree().get_nodes_in_group("question_portal"):
		if portal.has_signal("portal_activated"):
			# Verificar se já está conectado antes de conectar novamente
			if not portal.portal_activated.is_connected(_on_portal_activated):
				portal.portal_activated.connect(_on_portal_activated.bind(portal))

func _on_portal_activated(portal: Node):
	if question_ui and QuestionSystem:
		var question = QuestionSystem.get_random_question(portal.question_difficulty, portal.question_category)
		question_ui.show_question(question, portal)

func _on_player_collected_coin():
	if ui:
		ui.add_score(10)
	if UserDataManager:
		UserDataManager.add_coins(1)

func _on_player_died():
	if ui:
		var should_respawn = not ui.lose_life()
		if should_respawn:
			respawn_player()

func respawn_player():
	await get_tree().create_timer(0.5).timeout
	if player:
		player.queue_free()
	
	# Recriar jogador
	var player_scene = load("res://Player.tscn")
	var new_player = player_scene.instantiate()
	new_player.position = player_start_position
	new_player.collected_coin.connect(_on_player_collected_coin)
	new_player.player_died.connect(_on_player_died)
	add_child(new_player)
	player = new_player
