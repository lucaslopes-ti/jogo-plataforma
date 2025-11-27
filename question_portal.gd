extends Area2D

@onready var question_system = get_node("/root/QuestionSystem")
@onready var collision_shape = $CollisionShape2D
@onready var visual = $Visual

var question_difficulty: int = 1
var question_category: String = ""
var is_active: bool = true
var question_answered: bool = false

signal portal_activated

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("question_portal")
	
	# Garantir que está ativo inicialmente
	is_active = true
	question_answered = false
	monitoring = true
	monitorable = true
	
	update_visual()
	create_pulse_animation()

func create_pulse_animation():
	# Animação de pulso melhorada e mais cativante para o portal
	var outer_ring = get_node_or_null("Visual/OuterRing")
	var middle_ring = get_node_or_null("Visual/MiddleRing")
	var inner_core = get_node_or_null("Visual/InnerCore")
	var center = get_node_or_null("Visual/Center")
	var question_mark = get_node_or_null("Visual/QuestionMark")
	
	# Anel externo - pulso expansivo
	if outer_ring:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(outer_ring, "modulate:a", 0.7, 0.8)
		tween.tween_property(outer_ring, "modulate:a", 0.2, 0.8)
		tween.parallel().tween_property(outer_ring, "scale", Vector2(1.1, 1.1), 0.8)
		tween.parallel().tween_property(outer_ring, "scale", Vector2(1.0, 1.0), 0.8)
	
	# Anel médio - rotação contínua
	if middle_ring:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(middle_ring, "modulate:a", 0.9, 1.0)
		tween.tween_property(middle_ring, "modulate:a", 0.5, 1.0)
		tween.parallel().tween_property(middle_ring, "rotation_degrees", 360, 2.0)
	
	# Núcleo interno - pulso rápido
	if inner_core:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(inner_core, "scale", Vector2(1.2, 1.2), 0.6)
		tween.tween_property(inner_core, "scale", Vector2(1.0, 1.0), 0.6)
		tween.parallel().tween_property(inner_core, "modulate:a", 1.0, 0.6)
		tween.parallel().tween_property(inner_core, "modulate:a", 0.8, 0.6)
	
	# Centro - brilho pulsante
	if center:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(center, "modulate:a", 1.0, 0.5)
		tween.tween_property(center, "modulate:a", 0.6, 0.5)
		tween.parallel().tween_property(center, "scale", Vector2(1.1, 1.1), 0.5)
		tween.parallel().tween_property(center, "scale", Vector2(1.0, 1.0), 0.5)
	
	# Interrogação - animação de flutuação
	if question_mark:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(question_mark, "position:y", question_mark.position.y - 4, 0.9)
		tween.tween_property(question_mark, "position:y", question_mark.position.y, 0.9)
		tween.parallel().tween_property(question_mark, "modulate:a", 1.0, 0.9)
		tween.parallel().tween_property(question_mark, "modulate:a", 0.8, 0.9)
		tween.parallel().tween_property(question_mark, "scale", Vector2(1.1, 1.1), 0.45)
		tween.parallel().tween_property(question_mark, "scale", Vector2(1.0, 1.0), 0.45)
	
	# Brilho do centro
	var center_glow = get_node_or_null("Visual/CenterGlow")
	if center_glow:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(center_glow, "modulate:a", 0.8, 0.7)
		tween.tween_property(center_glow, "modulate:a", 0.3, 0.7)
		tween.parallel().tween_property(center_glow, "scale", Vector2(1.2, 1.2), 0.7)
		tween.parallel().tween_property(center_glow, "scale", Vector2(1.0, 1.0), 0.7)
	
	# Sparkles - brilhos nos cantos
	for i in range(1, 5):
		var sparkle = get_node_or_null("Visual/Sparkle" + str(i))
		if sparkle:
			var tween = create_tween()
			tween.set_loops()
			var delay = (i - 1) * 0.2
			tween.tween_property(sparkle, "modulate:a", 1.0, 0.5).set_delay(delay)
			tween.tween_property(sparkle, "modulate:a", 0.3, 0.5).set_delay(delay)
			tween.parallel().tween_property(sparkle, "scale", Vector2(1.3, 1.3), 0.5).set_delay(delay)
			tween.parallel().tween_property(sparkle, "scale", Vector2(1.0, 1.0), 0.5).set_delay(delay)
			tween.parallel().tween_property(sparkle, "rotation_degrees", 360, 2.0)
	
	# Criar partículas flutuantes ao redor
	create_floating_particles()

func update_visual():
	if visual:
		if question_answered:
			# Verde quando respondido
			var inner = get_node_or_null("Visual/InnerCore")
			var center = get_node_or_null("Visual/Center")
			if inner:
				inner.color = Color(0.2, 1, 0.4, 1)
			if center:
				center.color = Color(0, 1, 0.5, 1)
		else:
			# Ciano/azul quando ativo
			var inner = get_node_or_null("Visual/InnerCore")
			var center = get_node_or_null("Visual/Center")
			if inner:
				inner.color = Color(0.1, 0.7, 1, 1)
			if center:
				center.color = Color(0, 1, 1, 1)

func _on_body_entered(body):
	if body.name == "Player" and is_active and not question_answered:
		print("Portal ativado pelo jogador!")
		activate_portal()
	else:
		if body.name == "Player":
			print("Portal não ativado - is_active: ", is_active, " question_answered: ", question_answered)

func activate_portal():
	if question_answered or not is_active:
		print("Portal não pode ser ativado - já foi respondido ou está inativo")
		return
	portal_activated.emit()
	# O sistema de UI vai lidar com mostrar a pergunta

func set_answered():
	print("Portal marcado como respondido!")
	question_answered = true
	is_active = false
	
	# Criar efeito de sucesso antes de desaparecer
	create_success_effect()
	
	# Desabilitar colisão imediatamente
	if collision_shape:
		collision_shape.disabled = true
		collision_shape.visible = false
	
	# Desconectar sinal para evitar ativação novamente
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	
	# Desabilitar área imediatamente
	monitoring = false
	monitorable = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Remover do grupo ANTES de qualquer coisa
	remove_from_group("question_portal")
	
	# Parar todas as animações
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween and is_instance_valid(tween):
			tween.kill()
	
	# Fazer portal desaparecer com animação suave
	await disappear()

func reset_portal():
	question_answered = false
	is_active = true
	update_visual()

func create_success_effect():
	# Efeito visual de sucesso quando portal é respondido
	if ParticleEffects:
		ParticleEffects.create_explosion_effect(global_position, get_tree().current_scene, Color(0, 1, 0.5, 1))
	
	# Criar label de sucesso
	var scene = get_tree().current_scene
	if scene:
		var canvas = CanvasLayer.new()
		var label = Label.new()
		label.text = "✓ CONCLUÍDO!"
		label.add_theme_color_override("font_color", Color(0, 1, 0.5, 1))
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		label.add_theme_constant_override("outline_size", 3)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = global_position - Vector2(60, 40)
		canvas.add_child(label)
		scene.add_child(canvas)
		
		var tween = scene.create_tween()
		tween.set_parallel(true)
		tween.tween_property(label, "position:y", label.position.y - 50, 1.0)
		tween.tween_property(label, "modulate:a", 0.0, 1.0)
		tween.tween_property(label, "scale", Vector2(1.3, 1.3), 1.0)
		tween.tween_callback(func(): canvas.queue_free()).set_delay(1.0)

func create_floating_particles():
	# Criar partículas flutuantes ao redor do portal
	var scene = get_tree().current_scene
	if not scene:
		return
	
	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		var hue = (i / 8.0) * 0.3 + 0.5  # Cores entre ciano e azul
		particle.color = Color.from_hsv(hue, 0.8, 1.0, 0.8)
		particle.position = global_position
		particle.z_index = 50
		scene.add_child(particle)
		
		var angle = (i / 8.0) * TAU
		var distance = 40.0 + randf() * 20.0
		var target_pos = global_position + Vector2(cos(angle), sin(angle)) * distance
		
		var tween = scene.create_tween()
		tween.set_loops()
		tween.tween_property(particle, "position", target_pos, 2.0)
		tween.tween_property(particle, "position", global_position, 2.0)
		tween.parallel().tween_property(particle, "modulate:a", 0.3, 1.0)
		tween.parallel().tween_property(particle, "modulate:a", 0.8, 1.0)

func disappear():
	print("Portal desaparecendo...")
	
	# Desabilitar completamente processos
	set_physics_process(false)
	set_process(false)
	
	# Parar todas as animações de partículas flutuantes
	var scene = get_tree().current_scene
	if scene:
		for child in scene.get_children():
			if child is ColorRect and child.z_index == 50:
				# Provavelmente é uma partícula do portal
				var dist = child.global_position.distance_to(global_position)
				if dist < 100:
					child.queue_free()
	
	# Animação de desaparecimento suave e cativante
	if visual and is_instance_valid(visual):
		# Efeito de expansão e fade
		var fade_tween = create_tween()
		fade_tween.set_parallel(true)
		fade_tween.tween_property(visual, "modulate:a", 0.0, 0.4)
		fade_tween.tween_property(visual, "scale", Vector2(1.6, 1.6), 0.4)
		fade_tween.tween_property(visual, "rotation_degrees", 180, 0.4)
		await fade_tween.finished
	
	# Garantir que está completamente escondido
	if visual and is_instance_valid(visual):
		visual.visible = false
		visual.modulate.a = 0.0
		visual.scale = Vector2.ZERO
		# Esconder todos os filhos também
		for child in visual.get_children():
			if is_instance_valid(child):
				child.visible = false
				if child.has_method("set_modulate"):
					child.modulate.a = 0.0
				if child.has_method("set_scale"):
					child.scale = Vector2.ZERO
	
	# Remover imediatamente após animação
	await get_tree().process_frame
	call_deferred("queue_free")
	print("Portal removido!")
