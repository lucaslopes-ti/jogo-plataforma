extends CanvasLayer

@onready var question_panel = $QuestionPanel
@onready var question_label = $QuestionPanel/VBoxContainer/QuestionLabel
@onready var options_container = $QuestionPanel/VBoxContainer/OptionsContainer
@onready var attempts_label = $QuestionPanel/VBoxContainer/AttemptsLabel
@onready var category_label = $QuestionPanel/VBoxContainer/CategoryLabel

@onready var question_system = get_node("/root/QuestionSystem")
@onready var option_buttons: Array[Button] = []

var current_question: Dictionary = {}
var current_portal: Node = null
var is_question_active: bool = false

func _ready():
	question_panel.visible = false
	# Conectar sinais do sistema de perguntas
	if question_system:
		question_system.question_answered.connect(_on_question_answered)
		question_system.question_completed.connect(_on_question_completed)

func show_question(question: Dictionary, portal: Node):
	current_question = question
	current_portal = portal
	is_question_active = true
	
	# Atualizar UI
	question_label.text = question.question
	category_label.text = "Categoria: " + question.category.capitalize()
	update_attempts_label()
	
	# Criar botões de opções com estilo pixelado tecnológico
	clear_options()
	for i in range(question.options.size()):
		var button = Button.new()
		button.text = question.options[i]
		button.custom_minimum_size = Vector2(400, 60)
		
		# Estilo pixelado tecnológico
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.2, 0.35, 1)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = Color(0, 0.8, 1, 1)
		style.corner_radius_top_left = 0
		style.corner_radius_top_right = 0
		style.corner_radius_bottom_right = 0
		style.corner_radius_bottom_left = 0
		
		button.add_theme_stylebox_override("normal", style)
		
		var hover_style = style.duplicate()
		hover_style.bg_color = Color(0.15, 0.3, 0.45, 1)
		hover_style.border_color = Color(0, 1, 1, 1)
		button.add_theme_stylebox_override("hover", hover_style)
		
		var pressed_style = style.duplicate()
		pressed_style.bg_color = Color(0.2, 0.4, 0.55, 1)
		button.add_theme_stylebox_override("pressed", pressed_style)
		
		button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(0, 1, 1, 1))
		button.add_theme_font_size_override("font_size", 20)
		
		button.pressed.connect(_on_option_selected.bind(i))
		options_container.add_child(button)
		option_buttons.append(button)
	
	question_panel.visible = true
	question_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func clear_options():
	for button in option_buttons:
		button.queue_free()
	option_buttons.clear()

func update_attempts_label():
	if question_system:
		var remaining = question_system.get_remaining_attempts()
		attempts_label.text = "Tentativas restantes: " + str(remaining)

func _on_option_selected(option_index: int):
	if not is_question_active:
		return
	
	var correct = question_system.answer_question(option_index)
	
	# Mostrar feedback educacional
	var feedback_system = get_node_or_null("/root/FeedbackSystem")
	if feedback_system:
		feedback_system.show_feedback(current_question, correct)
	
	# Atualizar estatísticas do usuário
	if UserDataManager:
		UserDataManager.update_statistics("total_questions", 1)
		if correct:
			UserDataManager.update_statistics("correct_answers", 1)
			UserDataManager.add_experience(10)
			UserDataManager.add_coins(5)
	
	# Atualizar UI principal
	var ui = get_tree().get_first_node_in_group("ui")
	if ui and ui.has_method("add_question_result"):
		ui.add_question_result(correct)
	
	# Destacar a resposta correta/errada
	if correct:
		# Efeitos visuais de sucesso
		if ScreenEffects:
			ScreenEffects.flash_screen(Color(0, 1, 0.5, 0.2), 0.3)
			ScreenEffects.shake_camera(3.0, 0.2)
		
		option_buttons[option_index].modulate = Color(0.3, 1, 0.3, 1)  # Verde
		
		# Animação de sucesso
		var tween = create_tween()
		tween.parallel().tween_property(option_buttons[option_index], "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(option_buttons[option_index], "scale", Vector2(1.0, 1.0), 0.2)
		
		await get_tree().create_timer(1.0).timeout
		hide_question()
		if current_portal and is_instance_valid(current_portal):
			print("Chamando set_answered() no portal...")
			# Chamar set_answered imediatamente
			current_portal.set_answered()
			# Limpar referência ao portal
			current_portal = null
	else:
		# Efeitos visuais de erro
		if ScreenEffects:
			ScreenEffects.flash_screen(Color(1, 0.2, 0.2, 0.2), 0.2)
			ScreenEffects.shake_camera(4.0, 0.15)
		
		option_buttons[option_index].modulate = Color(1, 0.3, 0.3, 1)  # Vermelho
		
		# Animação de erro
		var tween = create_tween()
		tween.parallel().tween_property(option_buttons[option_index], "position:x", option_buttons[option_index].position.x - 10, 0.05)
		tween.parallel().tween_property(option_buttons[option_index], "position:x", option_buttons[option_index].position.x + 10, 0.05)
		tween.parallel().tween_property(option_buttons[option_index], "position:x", option_buttons[option_index].position.x, 0.05)
		
		update_attempts_label()
		
		# Mostrar explicação da resposta correta
		show_correct_answer_explanation()
		
		# Se esgotou as tentativas
		if question_system.get_remaining_attempts() <= 0:
			await get_tree().create_timer(2.0).timeout
			hide_question()
			# Resetar fase
			get_tree().call_deferred("reload_current_scene")

func show_correct_answer_explanation():
	# Destacar a resposta correta
	var correct_index = current_question.correct
	if correct_index < option_buttons.size():
		option_buttons[correct_index].modulate = Color(0.3, 1, 0.8, 1)  # Ciano para resposta correta

func _on_question_answered(_correct: bool):
	pass

func _on_question_completed():
	pass

func hide_question():
	question_panel.visible = false
	is_question_active = false
	get_tree().paused = false
	clear_options()
	current_question = {}
	current_portal = null
