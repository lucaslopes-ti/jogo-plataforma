extends CanvasLayer

# Painel Superior Esquerdo (Informações do Jogador)
@onready var user_info_label = $UI/TopLeftPanel/VBoxContainer/UserInfoLabel
@onready var level_label = $UI/TopLeftPanel/VBoxContainer/LevelLabel

# Painel Superior Direito (Estatísticas)
@onready var score_label = $UI/TopRightPanel/VBoxContainer/ScoreLabel
@onready var coins_label = $UI/TopRightPanel/VBoxContainer/CoinsLabel
@onready var exp_label = $UI/TopRightPanel/VBoxContainer/ExpLabel
@onready var questions_label = $UI/TopRightPanel/VBoxContainer/QuestionsLabel
@onready var lives_label = $UI/TopRightPanel/VBoxContainer/LivesLabel

# Painel Inferior Esquerdo (HP)
@onready var hp_bar_container = $UI/BottomLeftPanel/VBoxContainer/HPBarContainer
@onready var hp_bar_fill = $UI/BottomLeftPanel/VBoxContainer/HPBarFill
@onready var hp_bar_bg = $UI/BottomLeftPanel/VBoxContainer/HPBarBG
@onready var hp_label = $UI/BottomLeftPanel/VBoxContainer/HPLabel

# Painéis de diálogo
@onready var game_over_panel = $UI/GameOverPanel
@onready var restart_button = $UI/GameOverPanel/RestartButton
@onready var tutorial_panel = $UI/TutorialPanel
@onready var close_tutorial_button = $UI/TutorialPanel/VBoxContainer/CloseButton

var score = 0
var lives = 3
var questions_answered = 0
var questions_correct = 0

func _ready():
	# Garantir que os painéis estão visíveis
	var top_left = get_node_or_null("UI/TopLeftPanel")
	var top_right = get_node_or_null("UI/TopRightPanel")
	var bottom_left = get_node_or_null("UI/BottomLeftPanel")
	
	if top_left:
		top_left.visible = true
	if top_right:
		top_right.visible = true
	if bottom_left:
		bottom_left.visible = true
	
	update_ui()
	game_over_panel.visible = false
	
	# NÃO mostrar tutorial no início - será mostrado após login
	tutorial_panel.visible = false
	
	# Aguardar um frame para garantir que os nós estão prontos
	await get_tree().process_frame
	
	# Verificar se todos os labels existem
	print("ScoreLabel existe: ", score_label != null)
	print("LivesLabel existe: ", lives_label != null)
	print("QuestionsLabel existe: ", questions_label != null)
	print("UserInfoLabel existe: ", user_info_label != null)
	
	if restart_button:
		restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
		if not restart_button.pressed.is_connected(_on_restart_button_pressed):
			restart_button.pressed.connect(_on_restart_button_pressed)
		print("Botão de reiniciar configurado")
	
	if close_tutorial_button:
		if not close_tutorial_button.pressed.is_connected(_on_close_tutorial_pressed):
			close_tutorial_button.pressed.connect(_on_close_tutorial_pressed)
		# Garantir que o botão funcione mesmo quando pausado
		close_tutorial_button.process_mode = Node.PROCESS_MODE_ALWAYS
		tutorial_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conectar sinal de atualização do perfil
	if UserDataManager:
		if not UserDataManager.profile_updated.is_connected(update_user_info):
			UserDataManager.profile_updated.connect(update_user_info)
	
	# Conectar sinal de HP do jogador
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("hp_changed"):
		if not player.hp_changed.is_connected(_on_player_hp_changed):
			player.hp_changed.connect(_on_player_hp_changed)
		# Atualizar HP inicial
		_on_player_hp_changed(player.current_hp, player.max_hp)
	
	# Atualizar informações periodicamente
	update_user_info()
	
	# NÃO pausar o jogo no início - deixar o login funcionar
	# get_tree().paused = true  # COMENTADO

func update_ui():
	# Animações suaves ao atualizar
	if score_label:
		animate_label_update(score_label, "💎 Pontos: " + str(score))
		# Efeito visual quando pontuação aumenta
		if score > 0:
			create_ui_pulse(score_label)
	if lives_label:
		animate_label_update(lives_label, "❤️ Vidas: " + str(lives))
		# Efeito visual quando vida muda
		create_ui_pulse(lives_label)
	if questions_label:
		var accuracy = 0
		if questions_answered > 0:
			accuracy = int((float(questions_correct) / float(questions_answered)) * 100)
		animate_label_update(questions_label, "❓ Perguntas: " + str(questions_correct) + "/" + str(questions_answered) + " (" + str(accuracy) + "%)")
	
	# Atualizar informações do usuário
	update_user_info()

func create_ui_pulse(node: Control):
	# Criar efeito de pulso em elementos UI
	if not node or not is_instance_valid(node):
		return
	
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.tween_property(node, "scale", original_scale * 1.15, 0.15)
	tween.tween_property(node, "scale", original_scale, 0.15)

func animate_label_update(label: Label, new_text: String):
	# Animação suave melhorada ao atualizar label
	if not label:
		return
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 0.6, 0.08)
	tween.tween_callback(func(): 
		if label:
			label.text = new_text
	)
	tween.tween_property(label, "modulate:a", 1.0, 0.12).set_delay(0.08)
	tween.tween_property(label, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)

func update_user_info():
	if UserDataManager:
		var user = UserDataManager.current_user
		var username = user.get("username", "Jogador")
		var level = UserDataManager.get_user_level()
		var coins = UserDataManager.get_user_coins()
		var experience = UserDataManager.get_user_experience()
		var exp_needed = level * 100
		
		if user_info_label:
			animate_label_update(user_info_label, "👤 " + username)
		if level_label:
			animate_label_update(level_label, "⭐ Nível: " + str(level))
			# Efeito especial quando nível muda
			create_ui_pulse(level_label)
		if coins_label:
			animate_label_update(coins_label, "🪙 Moedas: " + str(coins))
			# Efeito quando moedas aumentam
			create_ui_pulse(coins_label)
		if exp_label:
			animate_label_update(exp_label, "⚡ EXP: " + str(experience) + "/" + str(exp_needed))
			# Efeito quando EXP aumenta
			create_ui_pulse(exp_label)

func add_score(points: int):
	score += points
	update_ui()

func add_question_result(correct: bool):
	questions_answered += 1
	if correct:
		questions_correct += 1
	update_ui()

func lose_life():
	lives -= 1
	update_ui()
	if lives <= 0:
		show_game_over()
		return true
	return false

func show_game_over():
	# Efeito visual ao mostrar game over
	if ScreenEffects:
		ScreenEffects.fade_out(0.5)
	
	game_over_panel.visible = true
	
	# Animação de entrada do painel
	if game_over_panel:
		game_over_panel.modulate.a = 0.0
		game_over_panel.scale = Vector2(0.8, 0.8)
		var tween = create_tween()
		tween.parallel().tween_property(game_over_panel, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(game_over_panel, "scale", Vector2(1.0, 1.0), 0.3)
	
	get_tree().paused = true

func _on_restart_button_pressed():
	print("Botão de reiniciar pressionado!")
	# Despausar primeiro
	get_tree().paused = false
	# Aguardar um frame para garantir que o jogo foi despausado
	await get_tree().process_frame
	# Recarregar a cena
	get_tree().reload_current_scene()

func _on_close_tutorial_pressed():
	print("Botão clicado!")
	if tutorial_panel:
		tutorial_panel.visible = false
	# Despausar o jogo
	get_tree().paused = false
	print("Tutorial fechado, jogo iniciado!")

func _on_player_hp_changed(current_hp: int, max_hp: int):
	# Atualizar barra de vida
	if hp_bar_fill and hp_bar_bg:
		var percentage = float(current_hp) / float(max_hp)
		percentage = clamp(percentage, 0.0, 1.0)
		
		# Animação suave da barra
		var tween = create_tween()
		var target_width = hp_bar_bg.size.x * percentage
		tween.tween_property(hp_bar_fill, "size:x", target_width, 0.3)
		
		# Mudar cor baseado na porcentagem
		if percentage > 0.6:
			hp_bar_fill.color = Color(0, 1, 0.3, 1)  # Verde
		elif percentage > 0.3:
			hp_bar_fill.color = Color(1, 0.8, 0, 1)  # Amarelo
		else:
			hp_bar_fill.color = Color(1, 0.2, 0.2, 1)  # Vermelho
		
		# Efeito de pulso quando HP está baixo
		if percentage < 0.3:
			var bottom_panel = get_node_or_null("UI/BottomLeftPanel")
			if bottom_panel:
				create_ui_pulse(bottom_panel)
	
	# Atualizar label de HP
	if hp_label:
		animate_label_update(hp_label, "❤️ VIDA: " + str(current_hp) + "/" + str(max_hp))
		create_ui_pulse(hp_label)
