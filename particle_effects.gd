extends Node

# Sistema de efeitos de partículas pixelados

static func create_collect_effect(position: Vector2, scene: Node):
	# Efeito de coleta de moeda
	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(1, 0.84, 0, 1)
		particle.position = position
		particle.z_index = 100
		scene.add_child(particle)
		
		var angle = (i / 8.0) * TAU
		var distance = 30.0
		var target_pos = position + Vector2(cos(angle), sin(angle)) * distance
		
		var tween = scene.create_tween()
		tween.parallel().tween_property(particle, "position", target_pos, 0.5)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.parallel().tween_property(particle, "scale", Vector2(0.5, 0.5), 0.5)
		tween.tween_callback(particle.queue_free)

static func create_explosion_effect(position: Vector2, scene: Node, color: Color = Color(1, 0.3, 0.3, 1)):
	# Efeito de explosão
	for i in range(12):
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = color
		particle.position = position
		particle.z_index = 100
		scene.add_child(particle)
		
		var angle = (i / 12.0) * TAU
		var distance = 40.0 + randf() * 20.0
		var target_pos = position + Vector2(cos(angle), sin(angle)) * distance
		
		var tween = scene.create_tween()
		tween.parallel().tween_property(particle, "position", target_pos, 0.6)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.6)
		tween.parallel().tween_property(particle, "scale", Vector2(0.3, 0.3), 0.6)
		tween.tween_callback(particle.queue_free)

static func create_level_up_effect(position: Vector2, scene: Node):
	# Efeito de level up
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = "⭐ LEVEL UP! ⭐"
	label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.position = position - Vector2(80, 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(label)
	scene.add_child(canvas)
	
	# Criar partículas de estrelas
	for i in range(16):
		var star = ColorRect.new()
		star.size = Vector2(8, 8)
		star.color = Color(1, 0.9, 0.3, 1)
		star.position = position
		star.z_index = 150
		canvas.add_child(star)
		
		var angle = (i / 16.0) * TAU
		var distance = 60.0 + randf() * 30.0
		var target_pos = position + Vector2(cos(angle), sin(angle)) * distance
		
		var tween = scene.create_tween()
		tween.parallel().tween_property(star, "position", target_pos, 1.0)
		tween.parallel().tween_property(star, "modulate:a", 0.0, 1.0)
		tween.parallel().tween_property(star, "rotation_degrees", 360, 1.0)
		tween.tween_callback(star.queue_free)
	
	var tween = scene.create_tween()
	tween.parallel().tween_property(label, "position:y", label.position.y - 120, 2.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 2.0)
	tween.parallel().tween_property(label, "scale", Vector2(1.5, 1.5), 2.0)
	tween.tween_callback(canvas.queue_free)
