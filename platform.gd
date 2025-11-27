extends StaticBody2D

# Script para plataformas tecnológicas pixeladas

func _ready():
	# Adicionar ao grupo de plataformas para detecção
	add_to_group("platform")
	
	# Efeito de brilho pulsante na linha superior
	var top_glow = get_node_or_null("Visual/TopLineGlow")
	if top_glow:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(top_glow, "modulate:a", 0.5, 1.5)
		tween.tween_property(top_glow, "modulate:a", 0.2, 1.5)
	
	# Efeito nos pixels da grade (animação paralela)
	var grid_pixels = []
	for i in range(1, 10):
		var grid = get_node_or_null("Visual/GridPixel" + str(i))
		if grid:
			grid_pixels.append(grid)
	
	if grid_pixels.size() > 0:
		var tween = create_tween()
		tween.set_loops()
		for pixel in grid_pixels:
			tween.parallel().tween_property(pixel, "modulate:a", 0.9, 0.5)
			tween.parallel().tween_property(pixel, "modulate:a", 0.4, 0.5)
	
	# Efeito no centro
	var center = get_node_or_null("Visual/CenterAccent")
	if center:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(center, "modulate:a", 0.8, 1.0)
		tween.tween_property(center, "modulate:a", 0.3, 1.0)
		tween.parallel().tween_property(center, "scale", Vector2(1.2, 1.2), 1.0)
		tween.parallel().tween_property(center, "scale", Vector2(1.0, 1.0), 1.0)
	
	# Efeito nos acentos laterais
	var left_accent = get_node_or_null("Visual/SideAccentLeft")
	var right_accent = get_node_or_null("Visual/SideAccentRight")
	if left_accent:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(left_accent, "modulate:a", 1.0, 0.8)
		tween.tween_property(left_accent, "modulate:a", 0.5, 0.8)
	if right_accent:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(right_accent, "modulate:a", 1.0, 0.8)
		tween.tween_property(right_accent, "modulate:a", 0.5, 0.8)
	
	# Efeito de brilho na linha superior
	var top_line = get_node_or_null("Visual/TopLine")
	if top_line:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(top_line, "modulate", Color(0, 1, 1, 1), 0.5)
		tween.tween_property(top_line, "modulate", Color(0, 0.7, 0.9, 0.8), 0.5)

