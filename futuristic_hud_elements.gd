extends Node

# Script auxiliar para criar elementos visuais futuristas da HUD

static func create_tech_panel(parent: Control, size: Vector2, position: Vector2, style: Dictionary = {}) -> Panel:
	"""Cria um painel tecnológico com bordas angulares e padrões internos"""
	var panel = Panel.new()
	panel.custom_minimum_size = size
	panel.position = position
	parent.add_child(panel)
	
	# Estilo do painel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = style.get("bg_color", Color(0.05, 0.15, 0.25, 0.95))
	panel_style.border_width_left = style.get("border_width", 4)
	panel_style.border_width_top = style.get("border_width", 4)
	panel_style.border_width_right = style.get("border_width", 4)
	panel_style.border_width_bottom = style.get("border_width", 4)
	panel_style.border_color = style.get("border_color", Color(0, 0.9, 1, 1))
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Adicionar padrão de grade interno
	_create_grid_pattern(panel, size)
	
	# Adicionar bordas angulares decorativas
	_create_corner_accents(panel, size, style.get("border_color", Color(0, 0.9, 1, 1)))
	
	return panel

static func _create_grid_pattern(parent: Control, size: Vector2):
	"""Cria padrão de grade interno no painel"""
	var grid_container = Control.new()
	grid_container.name = "GridPattern"
	grid_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(grid_container)
	
	# Linhas horizontais
	for y in range(0, int(size.y), 20):
		var line = ColorRect.new()
		line.position = Vector2(0, y)
		line.size = Vector2(size.x, 1)
		line.color = Color(0, 0.7, 1, 0.1)
		grid_container.add_child(line)
	
	# Linhas verticais
	for x in range(0, int(size.x), 20):
		var line = ColorRect.new()
		line.position = Vector2(x, 0)
		line.size = Vector2(1, size.y)
		line.color = Color(0, 0.7, 1, 0.1)
		grid_container.add_child(line)
	
	# Linhas diagonais decorativas
	for i in range(0, int(size.x + size.y), 30):
		var diag_line = ColorRect.new()
		diag_line.position = Vector2(i, 0)
		diag_line.size = Vector2(2, 2)
		diag_line.color = Color(0, 0.8, 1, 0.15)
		diag_line.rotation_degrees = 45
		grid_container.add_child(diag_line)

static func _create_corner_accents(parent: Control, size: Vector2, accent_color: Color):
	"""Cria acentos angulares nos cantos do painel"""
	var accent_container = Control.new()
	accent_container.name = "CornerAccents"
	accent_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(accent_container)
	
	var accent_size = 15
	var accent_thickness = 3
	
	# Canto superior esquerdo
	_create_corner_accent(accent_container, Vector2(0, 0), Vector2(accent_size, accent_thickness), accent_color)
	_create_corner_accent(accent_container, Vector2(0, 0), Vector2(accent_thickness, accent_size), accent_color)
	
	# Canto superior direito
	_create_corner_accent(accent_container, Vector2(size.x - accent_size, 0), Vector2(accent_size, accent_thickness), accent_color)
	_create_corner_accent(accent_container, Vector2(size.x - accent_thickness, 0), Vector2(accent_thickness, accent_size), accent_color)
	
	# Canto inferior esquerdo
	_create_corner_accent(accent_container, Vector2(0, size.y - accent_thickness), Vector2(accent_size, accent_thickness), accent_color)
	_create_corner_accent(accent_container, Vector2(0, size.y - accent_size), Vector2(accent_thickness, accent_size), accent_color)
	
	# Canto inferior direito
	_create_corner_accent(accent_container, Vector2(size.x - accent_size, size.y - accent_thickness), Vector2(accent_size, accent_thickness), accent_color)
	_create_corner_accent(accent_container, Vector2(size.x - accent_thickness, size.y - accent_size), Vector2(accent_thickness, accent_size), accent_color)

static func _create_corner_accent(parent: Control, pos: Vector2, size: Vector2, color: Color):
	"""Cria um acento de canto individual"""
	var accent = ColorRect.new()
	accent.position = pos
	accent.size = size
	accent.color = color
	parent.add_child(accent)

static func create_tech_progress_bar(parent: Control, size: Vector2, position: Vector2, max_value: float = 100.0) -> Dictionary:
	"""Cria uma barra de progresso tecnológica segmentada"""
	var container = Control.new()
	container.custom_minimum_size = size
	container.position = position
	parent.add_child(container)
	
	# Fundo da barra
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.1, 0.15, 0.9)
	container.add_child(bg)
	
	# Borda da barra
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_width_left = 2
	border_style.border_width_top = 2
	border_style.border_width_right = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(0, 0.9, 1, 1)
	
	var border = Panel.new()
	border.name = "Border"
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.add_theme_stylebox_override("panel", border_style)
	container.add_child(border)
	
	# Preenchimento segmentado
	var fill_container = Control.new()
	fill_container.name = "FillContainer"
	fill_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fill_container.offset_left = 2
	fill_container.offset_top = 2
	fill_container.offset_right = -2
	fill_container.offset_bottom = -2
	container.add_child(fill_container)
	
	# Criar segmentos
	var segment_count = 20
	var segment_width = (size.x - 4) / segment_count
	
	for i in range(segment_count):
		var segment = ColorRect.new()
		segment.name = "Segment_" + str(i)
		segment.position = Vector2(i * segment_width, 0)
		segment.size = Vector2(segment_width - 2, size.y - 4)
		segment.color = Color(0, 0.9, 1, 0.3)
		segment.visible = false
		fill_container.add_child(segment)
	
	# Label de porcentagem
	var label = Label.new()
	label.name = "PercentageLabel"
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0, 1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.text = "0%"
	container.add_child(label)
	
	return {
		"container": container,
		"fill_container": fill_container,
		"label": label,
		"segment_count": segment_count
	}

static func create_tech_label(parent: Control, text: String, position: Vector2, size: Vector2 = Vector2(200, 30), style: Dictionary = {}) -> Label:
	"""Cria um label com estilo tecnológico"""
	var label = Label.new()
	label.text = text
	label.custom_minimum_size = size
	label.position = position
	label.add_theme_font_size_override("font_size", style.get("font_size", 20))
	label.add_theme_color_override("font_color", style.get("font_color", Color(0, 1, 1, 1)))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", style.get("outline_size", 3))
	label.horizontal_alignment = style.get("alignment", HORIZONTAL_ALIGNMENT_LEFT)
	parent.add_child(label)
	
	# Adicionar efeito de brilho pulsante
	var glow_tween = label.create_tween()
	glow_tween.set_loops()
	var base_color = style.get("font_color", Color(0, 1, 1, 1))
	glow_tween.tween_method(func(value: float):
		label.add_theme_color_override("font_color", Color(base_color.r, base_color.g, base_color.b, value))
	, 0.7, 1.0, 2.0)
	glow_tween.tween_method(func(value: float):
		label.add_theme_color_override("font_color", Color(base_color.r, base_color.g, base_color.b, value))
	, 1.0, 0.7, 2.0)
	
	return label

static func update_progress_bar(bar_data: Dictionary, value: float, max_value: float):
	"""Atualiza uma barra de progresso tecnológica"""
	var percentage = clamp(value / max_value, 0.0, 1.0)
	var segment_count = bar_data.segment_count
	var active_segments = int(percentage * segment_count)
	
	# Atualizar segmentos visíveis
	for i in range(segment_count):
		var segment = bar_data.fill_container.get_node_or_null("Segment_" + str(i))
		if segment:
			segment.visible = (i < active_segments)
			# Cor baseada na porcentagem
			if percentage > 0.6:
				segment.color = Color(0, 1, 0.3, 0.8)  # Verde
			elif percentage > 0.3:
				segment.color = Color(1, 0.8, 0, 0.8)  # Amarelo
			else:
				segment.color = Color(1, 0.2, 0.2, 0.8)  # Vermelho
	
	# Atualizar label
	if bar_data.label:
		bar_data.label.text = str(int(percentage * 100)) + "%"

