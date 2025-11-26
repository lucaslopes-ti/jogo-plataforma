extends CanvasLayer

@onready var score_label = $UI/HUD/ScoreLabel
@onready var lives_label = $UI/HUD/LivesLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var restart_button = $UI/GameOverPanel/RestartButton
@onready var tutorial_panel = $UI/TutorialPanel
@onready var close_tutorial_button = $UI/TutorialPanel/VBoxContainer/CloseButton
@onready var questions_label = $UI/HUD/QuestionsLabel
@onready var user_info_label = $UI/HUD/UserInfoLabel
@onready var level_label = $UI/HUD/LevelLabel
@onready var coins_label = $UI/HUD/CoinsLabel
@onready var exp_label = $UI/HUD/ExpLabel

var score = 0
var lives = 3
var questions_answered = 0
var questions_correct = 0

func _ready():
	# Garantir que o HUD está visível
	var hud = get_node_or_null("UI/HUD")
	if hud:
		hud.visible = true
		print("HUD encontrado e visível")
	
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
	
	# Atualizar informações periodicamente
	update_user_info()
	
	# NÃO pausar o jogo no início - deixar o login funcionar
	# get_tree().paused = true  # COMENTADO

func update_ui():
	# Animações suaves ao atualizar
	if score_label:
		animate_label_update(score_label, "💎 Pontos: " + str(score))
	if lives_label:
		animate_label_update(lives_label, "❤️ Vidas: " + str(lives))
	if questions_label:
		var accuracy = 0
		if questions_answered > 0:
			accuracy = int((float(questions_correct) / float(questions_answered)) * 100)
		animate_label_update(questions_label, "❓ Perguntas: " + str(questions_correct) + "/" + str(questions_answered) + " (" + str(accuracy) + "%)")
	
	# Atualizar informações do usuário
	update_user_info()

func animate_label_update(label: Label, new_text: String):
	# Animação suave ao atualizar label
	var tween = create_tween()
	tween.parallel().tween_property(label, "modulate:a", 0.5, 0.1)
	tween.tween_callback(func(): label.text = new_text)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)

func update_user_info():
	if UserDataManager:
		var user = UserDataManager.current_user
		var username = user.get("username", "Jogador")
		var level = UserDataManager.get_user_level()
		var coins = UserDataManager.get_user_coins()
		var experience = UserDataManager.get_user_experience()
		var exp_needed = level * 100
		
		if user_info_label:
			user_info_label.text = "👤 " + username
		if level_label:
			level_label.text = "⭐ Nível: " + str(level)
		if coins_label:
			coins_label.text = "🪙 Moedas: " + str(coins)
		if exp_label:
			exp_label.text = "⚡ EXP: " + str(experience) + "/" + str(exp_needed)

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
