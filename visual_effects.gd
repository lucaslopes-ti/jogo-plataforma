extends Node

# Sistema de efeitos visuais avançados para polimento completo

static func create_glow_effect(node: Node2D, color: Color = Color(0, 1, 1, 0.5), duration: float = 0.3):
	# Criar efeito de brilho ao redor de um nó
	if not node or not is_instance_valid(node):
		return
	
	var glow = ColorRect.new()
	glow.size = node.get_viewport_rect().size if node.get_viewport() else Vector2(5000, 5000)
	glow.color = color
	glow.z_index = node.z_index - 1
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var parent = node.get_parent()
	if parent:
		parent.add_child(glow)
		glow.global_position = node.global_position - glow.size / 2
		
		var tween = node.create_tween()
		tween.tween_property(glow, "modulate:a", 0.0, duration)
		tween.tween_callback(glow.queue_free)

static func create_trail_effect(position: Vector2, color: Color, scene: Node):
	# Criar efeito de rastro
	for i in range(5):
		var trail = ColorRect.new()
		trail.size = Vector2(8 - i, 8 - i)
		trail.color = color
		trail.color.a = 0.6 - (i * 0.1)
		trail.position = position
		trail.z_index = 50
		
		scene.add_child(trail)
		
		var tween = scene.create_tween()
		tween.parallel().tween_property(trail, "position", position + Vector2(randf_range(-20, 20), randf_range(-20, 20)), 0.5)
		tween.parallel().tween_property(trail, "modulate:a", 0.0, 0.5)
		tween.parallel().tween_property(trail, "scale", Vector2.ZERO, 0.5)
		tween.tween_callback(trail.queue_free)

static func create_impact_ring(position: Vector2, color: Color, scene: Node, size: float = 50.0):
	# Criar anel de impacto
	var ring = ColorRect.new()
	ring.size = Vector2(size, 4)
	ring.color = color
	ring.position = position - Vector2(size / 2, 2)
	ring.z_index = 50
	
	scene.add_child(ring)
	
	var tween = scene.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "size", Vector2(size * 3, 4), 0.4)
	tween.tween_property(ring, "modulate:a", 0.0, 0.4)
	tween.tween_property(ring, "rotation_degrees", 360, 0.4)
	tween.tween_callback(ring.queue_free)

static func create_energy_wave(position: Vector2, direction: Vector2, scene: Node):
	# Criar onda de energia
	for i in range(3):
		var wave = ColorRect.new()
		wave.size = Vector2(30, 4)
		wave.color = Color(0, 1, 1, 0.7)
		wave.position = position + direction * (i * 20)
		wave.z_index = 50
		
		scene.add_child(wave)
		
		var tween = scene.create_tween()
		tween.set_parallel(true)
		tween.tween_property(wave, "position", position + direction * (i * 20 + 100), 0.6)
		tween.tween_property(wave, "modulate:a", 0.0, 0.6)
		tween.tween_property(wave, "scale", Vector2(2.0, 1.0), 0.6)
		tween.tween_callback(wave.queue_free)

static func create_ui_pulse(node: Control, scale: float = 1.1, duration: float = 0.2):
	# Criar efeito de pulso em elementos UI
	if not node or not is_instance_valid(node):
		return
	
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.tween_property(node, "scale", original_scale * scale, duration / 2)
	tween.tween_property(node, "scale", original_scale, duration / 2)

static func create_text_popup(text: String, position: Vector2, color: Color, scene: Node, size: int = 24):
	# Criar popup de texto animado
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = position - Vector2(50, 20)
	
	canvas.add_child(label)
	scene.add_child(canvas)
	
	var tween = scene.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 80, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 1.5)
	tween.tween_callback(canvas.queue_free).set_delay(1.5)

