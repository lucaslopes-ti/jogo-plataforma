extends Area2D

# Moeda especial em homenagem aos alunos do SENAI Dr. Celso Charuri

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
	
	# Animação especial elegante
	if animated_sprite:
		create_special_animation()

func create_special_animation():
	# Animação de rotação suave
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(animated_sprite, "rotation", TAU, 2.0)
	
	# Animação de pulso elegante
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(animated_sprite, "scale", Vector2(1.2, 1.2), 1.0)
	pulse_tween.tween_property(animated_sprite, "scale", Vector2(1.0, 1.0), 1.0)
	
	# Animação de brilho (modulate)
	var glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(animated_sprite, "modulate", Color(1.2, 1.2, 1.5, 1.0), 0.8)
	glow_tween.tween_property(animated_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8)

func _on_body_entered(body):
	# Verificar se é o jogador (por nome ou grupo)
	var is_player = body.name == "Player" or body.is_in_group("player")
	if is_player and not collected:
		collected = true
		
		# Som especial (usar som de moeda normal por enquanto)
		if SoundManager:
			SoundManager.play_coin_collect_sound()
		
		# Efeito visual especial melhorado
		if ScreenEffects:
			ScreenEffects.shake_camera(5.0, 0.3)
			ScreenEffects.flash_screen(Color(0.5, 0.8, 1, 0.4), 0.3)
		
		# Efeito de partículas especial
		if ParticleEffects:
			ParticleEffects.create_collect_effect(global_position, get_tree().current_scene)
			# Efeito adicional de estrelas
			for i in range(8):
				ParticleEffects.create_collect_effect(
					global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30)),
					get_tree().current_scene
				)
		
		# Mostrar popup de homenagem
		show_tribute_popup()
		
		# Efeito visual de coleta
		if animated_sprite:
			var tween = create_tween()
			tween.parallel().tween_property(animated_sprite, "scale", Vector2(3.0, 3.0), 0.3)
			tween.parallel().tween_property(animated_sprite, "modulate:a", 0.0, 0.3)
			tween.parallel().tween_property(animated_sprite, "rotation", rotation + TAU * 3, 0.3)
		
		# Remover após animação
		await get_tree().create_timer(0.3).timeout
		queue_free()

func show_tribute_popup():
	# Criar popup elegante de homenagem
	var scene = get_tree().current_scene
	if not scene:
		return
	
	var canvas = CanvasLayer.new()
	canvas.name = "TributePopupCanvas"
	
	# Painel de fundo com estilo elegante
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(800, 500)
	panel.position = Vector2(560, 290)  # Centralizado na tela (1920x1080)
	
	# Estilo do painel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.1, 0.2, 0.98)
	style.border_width_left = 8
	style.border_width_top = 8
	style.border_width_right = 8
	style.border_width_bottom = 8
	style.border_color = Color(0.3, 0.7, 1, 1)  # Azul brilhante
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	panel.add_theme_stylebox_override("panel", style)
	
	# Container principal
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 40
	vbox.offset_top = 40
	vbox.offset_right = -40
	vbox.offset_bottom = -40
	panel.add_child(vbox)
	
	# Título principal
	var title = Label.new()
	title.text = "⭐ MOEDA ESPECIAL ⭐"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.3, 0.8, 1, 1))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title.add_theme_constant_override("outline_size", 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Separador
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	# Texto de homenagem
	var tribute_text = Label.new()
	tribute_text.text = "HOMENAGEM ESPECIAL"
	tribute_text.add_theme_font_size_override("font_size", 32)
	tribute_text.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
	tribute_text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	tribute_text.add_theme_constant_override("outline_size", 3)
	tribute_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(tribute_text)
	
	# Espaçador
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer1)
	
	# Texto principal
	var main_text = Label.new()
	main_text.text = "Esta moeda especial é dedicada aos\nincríveis alunos do curso de\nPROGRAMAÇÃO DE JOGOS\ndo SENAI Dr. Celso Charuri"
	main_text.add_theme_font_size_override("font_size", 28)
	main_text.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	main_text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	main_text.add_theme_constant_override("outline_size", 3)
	main_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(main_text)
	
	# Espaçador
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer2)
	
	# Mensagem motivacional
	var message = Label.new()
	message.text = "Parabéns pelo seu aprendizado e dedicação!\nContinue criando jogos incríveis! Tamo junto!"
	message.add_theme_font_size_override("font_size", 22)
	message.add_theme_color_override("font_color", Color(0.5, 1, 0.8, 1))
	message.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	message.add_theme_constant_override("outline_size", 2)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(message)
	
	# Espaçador flexível
	var spacer3 = Control.new()
	spacer3.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer3)
	
	# Botão de fechar
	var close_button = Button.new()
	close_button.text = "FECHAR"
	close_button.custom_minimum_size = Vector2(200, 60)
	close_button.add_theme_font_size_override("font_size", 24)
	
	# Estilo do botão
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.5, 0.8, 1)
	button_style.border_width_left = 4
	button_style.border_width_top = 4
	button_style.border_width_right = 4
	button_style.border_width_bottom = 4
	button_style.border_color = Color(0.3, 0.7, 1, 1)
	close_button.add_theme_stylebox_override("normal", button_style)
	
	var button_hover = button_style.duplicate()
	button_hover.bg_color = Color(0.3, 0.6, 0.9, 1)
	close_button.add_theme_stylebox_override("hover", button_hover)
	
	var button_pressed = button_style.duplicate()
	button_pressed.bg_color = Color(0.1, 0.4, 0.7, 1)
	close_button.add_theme_stylebox_override("pressed", button_pressed)
	
	# Variável para armazenar o tween de brilho
	var glow_tween_ref = null
	
	# Função para fechar o popup
	var close_popup = func():
		# Parar o tween de brilho se ainda estiver rodando
		if glow_tween_ref and glow_tween_ref.is_valid():
			glow_tween_ref.kill()
		# Animação de saída antes de remover
		if is_instance_valid(panel):
			var exit_tween = scene.create_tween()
			exit_tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.3)
			exit_tween.parallel().tween_property(panel, "scale", Vector2(0.8, 0.8), 0.3)
			exit_tween.tween_callback(func(): 
				if is_instance_valid(canvas):
					canvas.queue_free()
			)
		else:
			if is_instance_valid(canvas):
				canvas.queue_free()
	
	close_button.pressed.connect(close_popup)
	
	# Centralizar botão
	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_child(Control.new())  # Espaçador esquerdo
	button_container.add_child(close_button)
	button_container.add_child(Control.new())  # Espaçador direito
	vbox.add_child(button_container)
	
	canvas.add_child(panel)
	scene.add_child(canvas)
	
	# Animação de entrada do popup
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	var tween = scene.create_tween()
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.5)
	
	# Efeito de brilho pulsante na borda
	glow_tween_ref = scene.create_tween()
	glow_tween_ref.set_loops()
	var glow_style = style.duplicate()
	glow_tween_ref.tween_method(func(value: float):
		if is_instance_valid(panel) and is_instance_valid(canvas):
			var new_style = style.duplicate()
			new_style.border_color = Color(0.3, 0.7, 1, value)
			panel.add_theme_stylebox_override("panel", new_style)
	, 0.6, 1.0, 1.5)
	glow_tween_ref.tween_method(func(value: float):
		if is_instance_valid(panel) and is_instance_valid(canvas):
			var new_style = style.duplicate()
			new_style.border_color = Color(0.3, 0.7, 1, value)
			panel.add_theme_stylebox_override("panel", new_style)
	, 1.0, 0.6, 1.5)
