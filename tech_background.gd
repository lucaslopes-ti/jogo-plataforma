extends Node2D

# Sistema de background tecnológico pixelado de alta qualidade

@onready var parallax_layers: Array[Node2D] = []

func _ready():
	create_tech_background()

func create_tech_background():
	# Camada 1: Fundo base escuro
	var base_layer = create_base_layer()
	add_child(base_layer)
	
	# Camada 2: Grid tecnológico
	var grid_layer = create_grid_layer()
	add_child(grid_layer)
	
	# Camada 3: Partículas/estrelas
	var stars_layer = create_stars_layer()
	add_child(stars_layer)
	
	# Camada 4: Linhas de energia
	var energy_lines = create_energy_lines()
	add_child(energy_lines)
	
	# Camada 5: Circuitos pixelados
	var circuits = create_circuits()
	add_child(circuits)

func create_base_layer() -> ColorRect:
	var base = ColorRect.new()
	base.offset_left = -5000.0
	base.offset_top = -5000.0
	base.offset_right = 10000.0
	base.offset_bottom = 10000.0
	base.color = Color(0.02, 0.05, 0.1, 1)
	base.z_index = -10
	return base

func create_grid_layer() -> Node2D:
	var grid = Node2D.new()
	grid.z_index = -9
	
	# Linhas horizontais
	for y in range(-3000, 5000, 200):
		var line = ColorRect.new()
		line.position = Vector2(-5000, y)
		line.size = Vector2(10000, 2)
		line.color = Color(0, 0.3, 0.5, 0.15)
		grid.add_child(line)
	
	# Linhas verticais
	for x in range(-3000, 8000, 200):
		var line = ColorRect.new()
		line.position = Vector2(x, -5000)
		line.size = Vector2(2, 10000)
		line.color = Color(0, 0.3, 0.5, 0.1)
		grid.add_child(line)
	
	# Linhas principais mais brilhantes
	for y in range(-3000, 5000, 1000):
		var line = ColorRect.new()
		line.position = Vector2(-5000, y)
		line.size = Vector2(10000, 3)
		line.color = Color(0, 0.5, 0.8, 0.2)
		grid.add_child(line)
	
	return grid

func create_stars_layer() -> Node2D:
	var stars = Node2D.new()
	stars.z_index = -8
	
	# Criar "estrelas" pixeladas
	for i in range(300):
		var star = ColorRect.new()
		var x = randf_range(-4000, 7000)
		var y = randf_range(-2000, 3000)
		var size = randf_range(2, 5)
		star.position = Vector2(x, y)
		star.size = Vector2(size, size)
		star.color = Color(0, 0.8, 1, randf_range(0.4, 0.9))
		stars.add_child(star)
		
		# Animação de piscar
		var tween = create_tween()
		if tween:
			tween.set_loops()
			tween.tween_property(star, "modulate:a", 0.2, randf_range(1.0, 3.0))
			tween.tween_property(star, "modulate:a", 0.8, randf_range(1.0, 3.0))
	
	return stars

func create_energy_lines() -> Node2D:
	var lines = Node2D.new()
	lines.z_index = -7
	
	# Linhas de energia horizontais
	for i in range(5):
		var line = ColorRect.new()
		var y = randf_range(-1000, 2000)
		line.position = Vector2(-5000, y)
		line.size = Vector2(10000, 1)
		var alpha = randf_range(0.1, 0.3)
		line.color = Color(0, 0.6, 1, alpha)
		lines.add_child(line)
		
		# Efeito de movimento
		var tween = create_tween()
		if tween:
			tween.set_loops()
			tween.tween_property(line, "modulate:a", alpha * 0.3, 2.0)
			tween.tween_property(line, "modulate:a", alpha, 2.0)
	
	return lines

func create_circuits() -> Node2D:
	var circuits = Node2D.new()
	circuits.z_index = -6
	
	# Criar padrões de circuitos pixelados
	for i in range(15):
		var circuit = Node2D.new()
		var start_x = randf_range(-3000, 6000)
		var start_y = randf_range(-1500, 2500)
		circuit.position = Vector2(start_x, start_y)
		
		# Criar padrão de circuito
		for j in range(5):
			var pixel = ColorRect.new()
			pixel.position = Vector2(j * 20, 0)
			pixel.size = Vector2(4, 4)
			pixel.color = Color(0, 0.7, 0.9, 0.4)
			circuit.add_child(pixel)
		
		circuits.add_child(circuit)
	
	return circuits

