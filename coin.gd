extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var collected = false

func _ready():
	# Garantir que o sinal está conectado
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Garantir que está monitorando
	monitoring = true
	monitorable = true
	
	# Rotação contínua da moeda
	if animated_sprite:
		create_rotation_animation()

func create_rotation_animation():
	# Animação simples de rotação
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(animated_sprite, "rotation", TAU, 1.0)

func _on_body_entered(body):
	# Verificar se é o jogador (por nome ou grupo)
	var is_player = body.name == "Player" or body.is_in_group("player")
	if is_player and not collected:
		collected = true
		if body.has_method("collect_coin"):
			body.collect_coin()
		
		# Som de coleta de moeda
		if SoundManager:
			SoundManager.play_coin_collect_sound()
		
		# Efeito de tela melhorado
		if ScreenEffects:
			ScreenEffects.shake_camera(3.0, 0.15)
			ScreenEffects.flash_screen(Color(1, 0.84, 0, 0.2), 0.1)
		
		# Dar recompensas ao jogador
		if UserDataManager:
			UserDataManager.add_coins(2)  # 2 moedas por moeda coletada
			UserDataManager.add_experience(5)  # 5 EXP por moeda
		
		# Atualizar UI
		var ui = get_tree().get_first_node_in_group("ui")
		if ui:
			ui.add_score(10)
			ui.update_user_info()  # Atualizar informações do usuário
		
		# Efeito visual melhorado com mais impacto
		if animated_sprite:
			var tween = create_tween()
			tween.parallel().tween_property(animated_sprite, "scale", Vector2(2.5, 2.5), 0.15)
			tween.parallel().tween_property(animated_sprite, "modulate:a", 0.0, 0.15)
			tween.parallel().tween_property(animated_sprite, "rotation", rotation + TAU * 2, 0.15)
			tween.parallel().tween_property(animated_sprite, "modulate", Color(1, 1, 0, 1), 0.15)
		
		# Mostrar feedback visual de coleta
		show_collect_feedback()
		
		# Remover após animação
		await get_tree().create_timer(0.2).timeout
		queue_free()

func show_collect_feedback():
	# Criar efeito de partículas
	if ParticleEffects:
		ParticleEffects.create_collect_effect(global_position, get_tree().current_scene)
	
	# Criar label flutuante com garantia de remoção
	var scene = get_tree().current_scene
	if not scene:
		return
	
	var canvas = CanvasLayer.new()
	canvas.name = "FloatingTextCanvas"
	var label = Label.new()
	label.text = "+2 Moedas\n+5 EXP"
	label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = global_position - Vector2(50, 40)
	canvas.add_child(label)
	scene.add_child(canvas)
	
	# Animação de flutuação com callback garantido
	var tween = scene.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 1.0)
	tween.tween_callback(func(): canvas.queue_free()).set_delay(1.0)

