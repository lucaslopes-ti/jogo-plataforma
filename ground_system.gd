extends Node2D

# Sistema de chão e estruturas de ambiente para melhorar o visual do jogo

func _ready():
	create_ground()
	create_environment_structures()

func create_ground():
	# Criar chão principal na parte inferior da tela
	var ground_level = 600  # Nível do chão (ajustar conforme necessário)
	var ground_width = 10000  # Largura do chão
	
	# Chão principal (base sólida)
	var ground = StaticBody2D.new()
	ground.name = "Ground"
	ground.position = Vector2(0, ground_level)
	
	# CollisionShape para o chão
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(ground_width, 100)
	collision.shape = shape
	collision.position = Vector2(ground_width / 2, 50)
	ground.add_child(collision)
	
	# Visual do chão
	var visual = Node2D.new()
	visual.name = "Visual"
	ground.add_child(visual)
	
	# Base do chão
	var base = ColorRect.new()
	base.offset_left = 0.0
	base.offset_top = 0.0
	base.offset_right = ground_width
	base.offset_bottom = 100.0
	base.color = Color(0.1, 0.2, 0.3, 1)
	visual.add_child(base)
	
	# Linha superior do chão (brilho)
	var top_line = ColorRect.new()
	top_line.offset_left = 0.0
	top_line.offset_top = 0.0
	top_line.offset_right = ground_width
	top_line.offset_bottom = 4.0
	top_line.color = Color(0, 0.7, 1, 0.8)
	visual.add_child(top_line)
	
	# Detalhes do chão (padrão de grade)
	for i in range(0, ground_width, 100):
		var detail = ColorRect.new()
		detail.offset_left = float(i)
		detail.offset_top = 4.0
		detail.offset_right = float(i + 2)
		detail.offset_bottom = 6.0
		detail.color = Color(0, 0.5, 0.8, 0.4)
		visual.add_child(detail)
	
	# Linha de brilho inferior
	var bottom_glow = ColorRect.new()
	bottom_glow.offset_left = 0.0
	bottom_glow.offset_top = 96.0
	bottom_glow.offset_right = ground_width
	bottom_glow.offset_bottom = 100.0
	bottom_glow.color = Color(0, 0.4, 0.6, 0.3)
	visual.add_child(bottom_glow)
	
	add_child(ground)
	
	# Adicionar ao grupo de plataformas para detecção
	ground.add_to_group("platform")

func create_environment_structures():
	# Criar estruturas de fundo para dar profundidade
	var structures = Node2D.new()
	structures.name = "EnvironmentStructures"
	structures.z_index = -5  # Atrás das plataformas mas na frente do fundo
	
	# Pilares verticais de fundo
	for i in range(0, 5000, 800):
		create_background_pillar(structures, i, 400)
	
	# Estruturas horizontais flutuantes de fundo
	for i in range(0, 5000, 1200):
		create_background_beam(structures, i, randf_range(200, 500))
	
	add_child(structures)

func create_background_pillar(parent: Node2D, x: float, height: float):
	var pillar = Node2D.new()
	pillar.position = Vector2(x, 600 - height)
	
	# Corpo do pilar
	var body = ColorRect.new()
	body.offset_left = 0.0
	body.offset_top = 0.0
	body.offset_right = 40.0
	body.offset_bottom = height
	body.color = Color(0.05, 0.15, 0.25, 0.6)
	pillar.add_child(body)
	
	# Linha lateral brilhante
	var edge = ColorRect.new()
	edge.offset_left = 0.0
	edge.offset_top = 0.0
	edge.offset_right = 2.0
	edge.offset_bottom = height
	edge.color = Color(0, 0.5, 0.8, 0.4)
	pillar.add_child(edge)
	
	# Detalhes verticais
	for j in range(0, int(height), 50):
		var detail = ColorRect.new()
		detail.offset_left = 38.0
		detail.offset_top = float(j)
		detail.offset_right = 40.0
		detail.offset_bottom = float(j + 2)
		detail.color = Color(0, 0.4, 0.7, 0.3)
		pillar.add_child(detail)
	
	parent.add_child(pillar)

func create_background_beam(parent: Node2D, x: float, y: float):
	var beam = Node2D.new()
	beam.position = Vector2(x, y)
	
	# Corpo da viga
	var body = ColorRect.new()
	body.offset_left = 0.0
	body.offset_top = 0.0
	body.offset_right = 200.0
	body.offset_bottom = 20.0
	body.color = Color(0.06, 0.18, 0.28, 0.5)
	beam.add_child(body)
	
	# Linha superior
	var top = ColorRect.new()
	top.offset_left = 0.0
	top.offset_top = 0.0
	top.offset_right = 200.0
	top.offset_bottom = 2.0
	top.color = Color(0, 0.6, 0.9, 0.4)
	beam.add_child(top)
	
	# Detalhes
	for i in range(0, 200, 30):
		var detail = ColorRect.new()
		detail.offset_left = float(i)
		detail.offset_top = 18.0
		detail.offset_right = float(i + 2)
		detail.offset_bottom = 20.0
		detail.color = Color(0, 0.4, 0.7, 0.3)
		beam.add_child(detail)
	
	parent.add_child(beam)

