extends Node

# Sistema de ícones tecnológicos para a HUD
# Cria ícones vetoriais programaticamente com estilo futurista

static func create_icon_user(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(0, 1, 1, 1)) -> Control:
	"""Cria ícone de usuário tecnológico"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	# Cabeça (quadrado com bordas)
	var head = ColorRect.new()
	head.position = Vector2(size.x * 0.3, size.y * 0.15)
	head.size = Vector2(size.x * 0.4, size.y * 0.35)
	head.color = color
	icon.add_child(head)
	
	# Corpo (retângulo maior)
	var body = ColorRect.new()
	body.position = Vector2(size.x * 0.25, size.y * 0.5)
	body.size = Vector2(size.x * 0.5, size.y * 0.4)
	body.color = color
	icon.add_child(body)
	
	# Linhas decorativas
	_create_tech_lines(icon, size, color)
	
	return icon

static func create_icon_level(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(1, 0.8, 0, 1)) -> Control:
	"""Cria ícone de nível/estrela tecnológica"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	# Estrela usando formas geométricas
	var center = size / 2
	
	# Quadrado central
	var center_square = ColorRect.new()
	center_square.position = Vector2(center.x - size.x * 0.15, center.y - size.y * 0.15)
	center_square.size = Vector2(size.x * 0.3, size.y * 0.3)
	center_square.color = color
	icon.add_child(center_square)
	
	# Pontas da estrela (4 retângulos)
	var points = [
		Vector2(center.x - 1, 2),  # Topo
		Vector2(size.x - 2, center.y - 1),  # Direita
		Vector2(center.x - 1, size.y - 2),  # Baixo
		Vector2(2, center.y - 1)  # Esquerda
	]
	
	for point in points:
		var point_rect = ColorRect.new()
		point_rect.position = point
		point_rect.size = Vector2(3, 3)
		point_rect.color = color
		icon.add_child(point_rect)
	
	_create_tech_lines(icon, size, color)
	
	return icon

static func create_icon_score(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(0, 1, 1, 1)) -> Control:
	"""Cria ícone de pontuação (diamante)"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	# Diamante usando formas geométricas
	var center = size / 2
	
	# Triângulo superior
	var top_triangle = ColorRect.new()
	top_triangle.position = Vector2(center.x - size.x * 0.2, size.y * 0.2)
	top_triangle.size = Vector2(size.x * 0.4, size.y * 0.3)
	top_triangle.color = color
	top_triangle.rotation_degrees = 45
	icon.add_child(top_triangle)
	
	# Triângulo inferior
	var bottom_triangle = ColorRect.new()
	bottom_triangle.position = Vector2(center.x - size.x * 0.2, size.y * 0.5)
	bottom_triangle.size = Vector2(size.x * 0.4, size.y * 0.3)
	bottom_triangle.color = color
	bottom_triangle.rotation_degrees = -45
	icon.add_child(bottom_triangle)
	
	_create_tech_lines(icon, size, color)
	
	return icon

static func create_icon_coin(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(1, 0.84, 0, 1)) -> Control:
	"""Cria ícone de moeda tecnológica"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	var center = size / 2
	
	# Círculo externo (usando quadrado rotacionado)
	var outer = ColorRect.new()
	outer.position = Vector2(center.x - size.x * 0.4, center.y - size.y * 0.4)
	outer.size = Vector2(size.x * 0.8, size.y * 0.8)
	outer.color = color
	outer.rotation_degrees = 45
	icon.add_child(outer)
	
	# Círculo interno
	var inner = ColorRect.new()
	inner.position = Vector2(center.x - size.x * 0.2, center.y - size.y * 0.2)
	inner.size = Vector2(size.x * 0.4, size.y * 0.4)
	inner.color = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3, 1)
	inner.rotation_degrees = 45
	icon.add_child(inner)
	
	# Linha central
	var line = ColorRect.new()
	line.position = Vector2(center.x - 1, center.y - size.y * 0.3)
	line.size = Vector2(2, size.y * 0.6)
	line.color = Color(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1)
	icon.add_child(line)
	
	return icon

static func create_icon_exp(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(0.5, 1, 0.8, 1)) -> Control:
	"""Cria ícone de experiência (raio)"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	var center = size / 2
	
	# Linha principal vertical
	var main_line = ColorRect.new()
	main_line.position = Vector2(center.x - 2, size.y * 0.15)
	main_line.size = Vector2(4, size.y * 0.7)
	main_line.color = color
	icon.add_child(main_line)
	
	# Linhas diagonais (raio)
	var bolt_lines = [
		Vector2(center.x - 4, size.y * 0.3),
		Vector2(center.x + 2, size.y * 0.4),
		Vector2(center.x - 4, size.y * 0.5),
		Vector2(center.x + 2, size.y * 0.6)
	]
	
	for i in range(bolt_lines.size() - 1):
		var start = bolt_lines[i]
		var end = bolt_lines[i + 1]
		var line = ColorRect.new()
		line.position = start
		var length = start.distance_to(end)
		var angle = atan2(end.y - start.y, end.x - start.x)
		line.size = Vector2(length, 3)
		line.rotation = angle
		line.color = color
		icon.add_child(line)
	
	# Pontos decorativos
	for i in range(3):
		var point = ColorRect.new()
		point.position = Vector2(center.x - 1, size.y * 0.25 + i * size.y * 0.25)
		point.size = Vector2(3, 3)
		point.color = Color(color.r * 1.5, color.g * 1.5, color.b * 1.5, 1)
		icon.add_child(point)
	
	return icon

static func create_icon_question(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(0.5, 1, 0.5, 1)) -> Control:
	"""Cria ícone de pergunta tecnológica"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	var center = size / 2
	
	# Círculo externo (quadrado rotacionado)
	var circle = ColorRect.new()
	circle.position = Vector2(center.x - size.x * 0.35, center.y - size.y * 0.35)
	circle.size = Vector2(size.x * 0.7, size.y * 0.7)
	circle.color = color
	circle.rotation_degrees = 45
	icon.add_child(circle)
	
	# Ponto de interrogação (formas geométricas)
	# Parte superior (curva)
	var top_curve = ColorRect.new()
	top_curve.position = Vector2(center.x - size.x * 0.15, size.y * 0.2)
	top_curve.size = Vector2(size.x * 0.3, size.y * 0.15)
	top_curve.color = Color(0.1, 0.1, 0.15, 1)
	icon.add_child(top_curve)
	
	# Linha vertical
	var v_line = ColorRect.new()
	v_line.position = Vector2(center.x - 1, size.y * 0.35)
	v_line.size = Vector2(2, size.y * 0.25)
	v_line.color = Color(0.1, 0.1, 0.15, 1)
	icon.add_child(v_line)
	
	# Ponto inferior
	var dot = ColorRect.new()
	dot.position = Vector2(center.x - size.x * 0.1, size.y * 0.7)
	dot.size = Vector2(size.x * 0.2, size.y * 0.2)
	dot.color = color
	icon.add_child(dot)
	
	return icon

static func create_icon_life(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(1, 0.5, 0.5, 1)) -> Control:
	"""Cria ícone de vida (coração tecnológico)"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	var center = size / 2
	
	# Coração usando formas geométricas
	# Parte superior esquerda
	var top_left = ColorRect.new()
	top_left.position = Vector2(center.x - size.x * 0.25, size.y * 0.15)
	top_left.size = Vector2(size.x * 0.3, size.y * 0.3)
	top_left.color = color
	top_left.rotation_degrees = 45
	icon.add_child(top_left)
	
	# Parte superior direita
	var top_right = ColorRect.new()
	top_right.position = Vector2(center.x - size.x * 0.05, size.y * 0.15)
	top_right.size = Vector2(size.x * 0.3, size.y * 0.3)
	top_right.color = color
	top_right.rotation_degrees = -45
	icon.add_child(top_right)
	
	# Parte inferior (triângulo)
	var bottom = ColorRect.new()
	bottom.position = Vector2(center.x - size.x * 0.15, center.y + size.y * 0.1)
	bottom.size = Vector2(size.x * 0.3, size.y * 0.25)
	bottom.color = color
	bottom.rotation_degrees = 45
	icon.add_child(bottom)
	
	_create_tech_lines(icon, size, color)
	
	return icon

static func create_icon_hp(parent: Control, size: Vector2 = Vector2(24, 24), color: Color = Color(1, 0.3, 0.3, 1)) -> Control:
	"""Cria ícone de HP (cruz médica)"""
	var icon = Control.new()
	icon.custom_minimum_size = size
	parent.add_child(icon)
	
	var center = size / 2
	
	# Linha vertical (mais espessa)
	var v_line = ColorRect.new()
	v_line.position = Vector2(center.x - 3, size.y * 0.15)
	v_line.size = Vector2(6, size.y * 0.7)
	v_line.color = color
	icon.add_child(v_line)
	
	# Linha horizontal (mais espessa)
	var h_line = ColorRect.new()
	h_line.position = Vector2(size.x * 0.15, center.y - 3)
	h_line.size = Vector2(size.x * 0.7, 6)
	h_line.color = color
	icon.add_child(h_line)
	
	# Quadrado central
	var center_square = ColorRect.new()
	center_square.position = Vector2(center.x - size.x * 0.15, center.y - size.y * 0.15)
	center_square.size = Vector2(size.x * 0.3, size.y * 0.3)
	center_square.color = Color(color.r * 1.3, color.g * 1.3, color.b * 1.3, 1)
	icon.add_child(center_square)
	
	_create_tech_lines(icon, size, color)
	
	return icon

static func _create_circle_segment(parent: Control, center: Vector2, radius: float, color: Color) -> Control:
	"""Cria um segmento de círculo usando múltiplos retângulos"""
	var circle = Control.new()
	parent.add_child(circle)
	
	# Criar círculo usando pequenos quadrados
	for i in range(16):
		var angle = (i * TAU / 16)
		var x = center.x + cos(angle) * radius
		var y = center.y + sin(angle) * radius
		
		var pixel = ColorRect.new()
		pixel.position = Vector2(x - 1, y - 1)
		pixel.size = Vector2(3, 3)
		pixel.color = color
		circle.add_child(pixel)
	
	return circle

static func _create_tech_lines(parent: Control, size: Vector2, color: Color):
	"""Adiciona linhas decorativas tecnológicas ao ícone"""
	# Linhas diagonais sutis
	var line1 = ColorRect.new()
	line1.position = Vector2(2, 2)
	line1.size = Vector2(1, size.y * 0.3)
	line1.color = Color(color.r, color.g, color.b, 0.3)
	line1.rotation_degrees = 45
	parent.add_child(line1)
	
	var line2 = ColorRect.new()
	line2.position = Vector2(size.x - 2, size.y - 2)
	line2.size = Vector2(1, size.y * 0.3)
	line2.color = Color(color.r, color.g, color.b, 0.3)
	line2.rotation_degrees = 45
	parent.add_child(line2)

