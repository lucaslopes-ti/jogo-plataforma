extends Node2D

# Sistema de background tecnológico pixelado de alta qualidade com parallax

@onready var parallax_layers: Array[Node2D] = []
var player_camera: Camera2D = null
var last_camera_position: Vector2 = Vector2.ZERO

func _ready():
	create_tech_background()
	setup_parallax()

func _process(_delta):
	update_parallax()

func setup_parallax():
	# Encontrar câmera do jogador
	var scene = get_tree().current_scene
	if scene:
		var player = scene.get_node_or_null("Player")
		if player:
			player_camera = player.get_node_or_null("Camera2D")
			if player_camera:
				last_camera_position = player_camera.global_position

func update_parallax():
	if not player_camera:
		setup_parallax()
		return
	
	var current_pos = player_camera.global_position
	var delta_pos = current_pos - last_camera_position
	
	# Aplicar parallax em diferentes camadas
	for i in range(parallax_layers.size()):
		var layer = parallax_layers[i]
		if layer and is_instance_valid(layer):
			var speed = 0.1 + (i * 0.1)  # Velocidades diferentes para cada camada
			layer.position += delta_pos * speed
	
	last_camera_position = current_pos

func create_tech_background():
	# Camada 1: Fundo base escuro (sem parallax)
	var base_layer = create_base_layer()
	add_child(base_layer)
	
	# Camada 2: Grid tecnológico (parallax lento)
	var grid_layer = create_grid_layer()
	add_child(grid_layer)
	parallax_layers.append(grid_layer)
	
	# Camada 3: Partículas/estrelas (parallax médio)
	var stars_layer = create_stars_layer()
	add_child(stars_layer)
	parallax_layers.append(stars_layer)
	
	# Camada 4: Linhas de energia (parallax rápido)
	var energy_lines = create_energy_lines()
	add_child(energy_lines)
	parallax_layers.append(energy_lines)
	
	# Camada 5: Circuitos pixelados (parallax médio)
	var circuits = create_circuits()
	add_child(circuits)
	parallax_layers.append(circuits)
	
	# Camada 6: Nebulosa/atmosfera (parallax muito lento)
	var nebula = create_nebula_layer()
	add_child(nebula)
	parallax_layers.append(nebula)
	
	# Camada 7: Partículas flutuantes (parallax rápido)
	var floating_particles = create_floating_particles()
	add_child(floating_particles)
	parallax_layers.append(floating_particles)

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

func create_nebula_layer() -> Node2D:
	var nebula = Node2D.new()
	nebula.z_index = -11
	
	# Criar várias camadas de nebulosa com gradientes
	for i in range(8):
		var nebula_rect = ColorRect.new()
		var x = randf_range(-4000, 6000)
		var y = randf_range(-2000, 3000)
		var width = randf_range(2000, 4000)
		var height = randf_range(1500, 3000)
		
		nebula_rect.position = Vector2(x, y)
		nebula_rect.size = Vector2(width, height)
		
		# Cores variadas de azul/ciano
		var hue = randf_range(0.45, 0.6)  # Azul para ciano
		var saturation = randf_range(0.3, 0.6)
		var brightness = randf_range(0.1, 0.3)
		nebula_rect.color = Color.from_hsv(hue, saturation, brightness, randf_range(0.1, 0.25))
		
		nebula.add_child(nebula_rect)
		
		# Animação suave de movimento
		var tween = create_tween()
		tween.set_loops()
		var move_x = randf_range(-500, 500)
		var move_y = randf_range(-300, 300)
		tween.tween_property(nebula_rect, "position", nebula_rect.position + Vector2(move_x, move_y), randf_range(10.0, 20.0))
		tween.tween_property(nebula_rect, "position", nebula_rect.position, randf_range(10.0, 20.0))
	
	return nebula

func create_floating_particles() -> Node2D:
	var particles = Node2D.new()
	particles.z_index = -5
	
	# Partículas maiores e mais brilhantes
	for i in range(150):
		var particle = ColorRect.new()
		var x = randf_range(-4000, 7000)
		var y = randf_range(-2000, 3000)
		var size = randf_range(3, 8)
		
		particle.position = Vector2(x, y)
		particle.size = Vector2(size, size)
		
		# Cores vibrantes
		var hue = randf_range(0.4, 0.7)
		particle.color = Color.from_hsv(hue, 0.8, 1.0, randf_range(0.5, 1.0))
		
		particles.add_child(particle)
		
		# Animação de movimento e pulso
		var tween = create_tween()
		tween.set_loops()
		
		# Movimento
		var target_x = x + randf_range(-200, 200)
		var target_y = y + randf_range(-200, 200)
		tween.tween_property(particle, "position", Vector2(target_x, target_y), randf_range(3.0, 6.0))
		tween.tween_property(particle, "position", Vector2(x, y), randf_range(3.0, 6.0))
		
		# Pulso
		tween.parallel().tween_property(particle, "modulate:a", 0.3, randf_range(1.5, 3.0))
		tween.parallel().tween_property(particle, "modulate:a", 1.0, randf_range(1.5, 3.0))
	
	return particles

