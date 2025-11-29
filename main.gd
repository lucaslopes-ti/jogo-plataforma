extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var question_ui = $QuestionUI
@onready var login_system = $LoginSystem

var player_start_position = Vector2(200, 450)
var current_phase: int = 1
var game_mode: String = "adventure"  # adventure, endless, multiplayer
var settings_menu_instance = null

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
	
	# Iniciar música de fundo
	if SoundManager:
		SoundManager.play_background_music()
	
	# Salvar progresso ao iniciar
	if UserDataManager:
		UserDataManager.save_game_progress(current_phase, player_start_position)
	
	print("Use WASD ou setas para mover e ESPAÇO/W para pular")
	print("Clique do mouse ou X para atacar")
	print("Responda perguntas nos portais para avançar!")
	
	# Verificar se há múltiplos jogadores
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 1:
		print("AVISO: Múltiplos jogadores encontrados: ", players.size())
	
	if player:
		player.add_to_group("player")
		player.collected_coin.connect(_on_player_collected_coin)
		player.player_died.connect(_on_player_died)
		# Conectar sinal de HP para UI
		if player.has_signal("hp_changed") and ui:
			player.hp_changed.connect(ui._on_player_hp_changed)
			# Atualizar HP inicial
			ui._on_player_hp_changed(player.current_hp, player.max_hp)
		
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

func _input(event):
	# Abrir menu de configurações com ESC
	if event.is_action_pressed("ui_cancel"):
		# Se o menu já está aberto, fechar
		if settings_menu_instance:
			close_settings_menu()
			return
		
		# Verificar se não há outros menus abertos
		if ui and ui.tutorial_panel and ui.tutorial_panel.visible:
			return  # Não abrir se o tutorial estiver aberto
		if ui and ui.game_over_panel and ui.game_over_panel.visible:
			return  # Não abrir se o game over estiver aberto
		
		open_settings_menu()

func open_settings_menu():
	"""Abre o menu de configurações durante o jogo"""
	print("Tentando abrir menu de configurações...")
	
	if settings_menu_instance:
		print("Menu já está aberto!")
		return  # Já está aberto
	
	if not SettingsManager:
		print("ERRO: SettingsManager não está disponível!")
		return
	
	var settings_scene = load("res://SettingsMenu.tscn")
	if not settings_scene:
		print("ERRO: Não foi possível carregar SettingsMenu.tscn")
		return
	
	print("Cena carregada, instanciando...")
	settings_menu_instance = settings_scene.instantiate()
	if not settings_menu_instance:
		print("ERRO: Falha ao instanciar menu de configurações")
		return
	
	# Criar CanvasLayer para o menu
	var canvas = CanvasLayer.new()
	canvas.name = "SettingsCanvas"
	canvas.layer = 100  # Acima de tudo (CanvasLayer usa 'layer' em vez de 'z_index')
	add_child(canvas)
	canvas.add_child(settings_menu_instance)
	
	# Garantir que o menu está visível e configurado corretamente
	settings_menu_instance.visible = true
	settings_menu_instance.modulate.a = 1.0
	settings_menu_instance.scale = Vector2(1.0, 1.0)
	
	# Garantir que o menu ocupa toda a tela
	settings_menu_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Garantir que processa mesmo quando pausado
	settings_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Pausar o jogo (mas o menu continuará processando)
	get_tree().paused = true
	
	# Aguardar um frame para garantir que está renderizado
	await get_tree().process_frame
	print("Menu renderizado e pronto para exibição!")
	
	# Conectar sinal para saber quando fechar
	if settings_menu_instance.has_signal("menu_closed"):
		if not settings_menu_instance.menu_closed.is_connected(_on_settings_menu_closed):
			settings_menu_instance.menu_closed.connect(_on_settings_menu_closed)
	
	print("Menu de configurações aberto com ESC!")

func close_settings_menu():
	"""Fecha o menu de configurações"""
	if not settings_menu_instance:
		return
	
	print("Fechando menu de configurações...")
	
	# Despausar o jogo
	get_tree().paused = false
	
	# Remover o CanvasLayer
	var canvas = settings_menu_instance.get_parent()
	if canvas and canvas.name == "SettingsCanvas":
		canvas.queue_free()
	
	settings_menu_instance = null
	print("Menu fechado!")

func _on_settings_menu_closed():
	"""Chamado quando o menu de configurações é fechado"""
	settings_menu_instance = null
	get_tree().paused = false

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
	# Aguardar um pouco antes de respawnar
	await get_tree().create_timer(0.5).timeout
	
	# Se o player ainda existe, remover
	if player and is_instance_valid(player):
		player.queue_free()
		await get_tree().process_frame
	
	# Recriar jogador
	var player_scene = load("res://Player.tscn")
	if player_scene:
		var new_player = player_scene.instantiate()
		new_player.position = player_start_position
		new_player.collected_coin.connect(_on_player_collected_coin)
		new_player.player_died.connect(_on_player_died)
		# Conectar sinal de HP para UI
		if new_player.has_signal("hp_changed") and ui:
			new_player.hp_changed.connect(ui._on_player_hp_changed)
			# Atualizar HP inicial
			ui._on_player_hp_changed(new_player.current_hp, new_player.max_hp)
		add_child(new_player)
		player = new_player
		
		# Garantir que está no grupo
		player.add_to_group("player")
		
		# Configurar câmera novamente
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = -1000
			camera.limit_right = 5000
			camera.limit_top = -1000
			camera.limit_bottom = 2000
		
		print("Player respawnado em: ", player_start_position)
