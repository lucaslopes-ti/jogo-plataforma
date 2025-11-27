extends CharacterBody2D

const SPEED = 80.0
const GRAVITY_SCALE = 1.0

var direction = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var patrol_distance = 200.0

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var body = sprite

var animation_state = "walking"
var last_position_x = 0.0
var is_defeated = false  # Flag para evitar múltiplas chamadas de defeat_enemy

func _ready():
	# Aguardar um frame para garantir que a posição está correta
	await get_tree().process_frame
	start_position = global_position
	last_position_x = global_position.x
	
	# Verificar se está sobre uma plataforma, se não, ajustar
	ensure_on_platform()
	
	# Adicionar ao grupo de inimigos para detecção de ataque
	add_to_group("enemy")
	
	# Conectar área de detecção
	await get_tree().process_frame
	var area = get_node_or_null("Area2D")
	if area:
		area.body_entered.connect(_on_area_body_entered)
	
	# Iniciar animação de caminhada
	play_walk_animation()

func _physics_process(delta):
	# Aplicar gravidade
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_SCALE * delta
	else:
		velocity.y = 0
	
	# Patrulha
	var distance_from_start = global_position.x - start_position.x
	
	if distance_from_start >= patrol_distance:
		direction = -1
	elif distance_from_start <= -patrol_distance:
		direction = 1
	
	velocity.x = direction * SPEED
	
	# Flip visual
	if sprite:
		sprite.scale.x = abs(sprite.scale.x) * direction
	
	# Verificar colisão com paredes ou bordas de plataforma
	if is_on_wall():
		direction *= -1
	
	# Verificar se está prestes a cair (detectar borda da plataforma)
	if is_on_floor():
		var space_state = get_world_2d().direct_space_state
		var from_pos = global_position + Vector2(direction * 20, 0)
		var to_pos = global_position + Vector2(direction * 20, 100)
		var query = PhysicsRayQueryParameters2D.create(from_pos, to_pos)
		query.collision_mask = 1  # Camada de plataformas
		var result = space_state.intersect_ray(query)
		if not result:
			# Não há chão à frente, inverter direção
			direction *= -1
	
	# Animações baseadas no movimento
	if abs(global_position.x - last_position_x) > 0.1:
		play_walk_animation()
	else:
		play_idle_animation()
	
	last_position_x = global_position.x
	
	move_and_slide()
	
	# Verificar se caiu - reposicionar na posição inicial e garantir que está sobre plataforma
	if global_position.y > 2000:
		global_position = start_position
		velocity = Vector2.ZERO
		direction = -1  # Resetar direção
		# Garantir que está sobre uma plataforma
		ensure_on_platform()

func play_walk_animation():
	if animation_state != "walking" and body:
		animation_state = "walking"
		# Animação de caminhada - movimento vertical e rotação
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(body, "position:y", -1.5, 0.2)
		tween.tween_property(body, "position:y", 0.0, 0.2)
		# Rotação sutil
		tween.parallel().tween_property(body, "rotation_degrees", 3.0, 0.2)
		tween.parallel().tween_property(body, "rotation_degrees", -3.0, 0.2)
		tween.parallel().tween_property(body, "rotation_degrees", 0.0, 0.2)

func play_idle_animation():
	if animation_state != "idle" and body:
		animation_state = "idle"
		# Animação de respiração
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(body, "scale", Vector2(1.05, 1.05), 0.8)
		tween.tween_property(body, "scale", Vector2(1.0, 1.0), 0.8)

func _on_area_body_entered(body):
	if body.name == "Player":
		# Verificar se o jogador está acima do inimigo (pulando em cima)
		var player_pos = body.global_position
		var enemy_pos = global_position
		
		# Se jogador está acima do inimigo (diferença de Y negativa) e caindo
		if player_pos.y < enemy_pos.y - 10 and body.velocity.y > 50:
			# Jogador pulou em cima - derrotar inimigo (estilo Mario)
			defeat_enemy(body)
		else:
			# Jogador tocou de lado ou por baixo - causar dano
			# Mas não matar imediatamente se o jogador está atacando
			if body.has_method("is_attacking") and body.is_attacking:
				# Se o jogador está atacando, o ataque já foi processado em check_attack_hit
				# Não fazer nada aqui para evitar duplicação
				pass
			else:
				# Jogador tocou sem atacar - causar dano
				if body.has_method("take_damage"):
					body.take_damage(1)
				else:
					body.die()

func defeat_enemy(player):
	# Evitar múltiplas chamadas
	if is_defeated:
		return
	is_defeated = true
	
	# Desabilitar colisão imediatamente para evitar mais interações
	var area = get_node_or_null("Area2D")
	if area:
		area.monitoring = false
		area.monitorable = false
		area.set_deferred("monitoring", false)
		area.set_deferred("monitorable", false)
	
	# Parar física
	set_physics_process(false)
	set_process(false)
	
	# Efeitos de tela
	if ScreenEffects:
		ScreenEffects.shake_camera(6.0, 0.3)
		ScreenEffects.flash_screen(Color(0, 1, 0.5, 0.3), 0.2)
	
	# Dar recompensas ao jogador
	if UserDataManager:
		UserDataManager.add_coins(5)  # 5 moedas por inimigo derrotado
		UserDataManager.add_experience(15)  # 15 EXP por inimigo derrotado
	
	# Atualizar UI
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.add_score(50)  # 50 pontos por inimigo
		ui.update_user_info()
	
	# Fazer jogador pular um pouco ao derrotar
	if player and is_instance_valid(player) and player.has_method("bounce"):
		player.bounce()
	
	# Mostrar feedback (não usar await aqui)
	show_defeat_feedback()
	
	# Efeito visual de derrota melhorado
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(self, "rotation_degrees", 720, 0.3)
	tween.tween_property(self, "modulate", Color(1, 1, 0, 1), 0.15)
	tween.tween_property(self, "modulate", Color(1, 0, 0, 0), 0.15).set_delay(0.15)
	
	# Usar call_deferred para garantir remoção segura
	tween.tween_callback(func(): call_deferred("queue_free")).set_delay(0.3)

func show_defeat_feedback():
	# Criar efeito de explosão
	if ParticleEffects:
		ParticleEffects.create_explosion_effect(global_position, get_tree().current_scene, Color(1, 0.2, 0.3, 1))
	
	# Criar label flutuante com garantia de remoção
	var scene = get_tree().current_scene
	if not scene:
		return
	
	var canvas = CanvasLayer.new()
	canvas.name = "FloatingTextCanvas"
	var label = Label.new()
	label.text = "+5 Moedas\n+15 EXP\n+50 Pontos"
	label.add_theme_color_override("font_color", Color(0, 1, 0.5, 1))
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = global_position - Vector2(60, 50)
	canvas.add_child(label)
	scene.add_child(canvas)
	
	# Animação de flutuação com callback garantido
	var tween = scene.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 80, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 1.5)
	tween.tween_callback(func(): canvas.queue_free()).set_delay(1.5)

func ensure_on_platform():
	# Verificar se está sobre uma plataforma usando raycast
	var space_state = get_world_2d().direct_space_state
	var from_pos = global_position + Vector2(0, -10)  # Um pouco acima
	var to_pos = global_position + Vector2(0, 300)  # Verificar abaixo
	var query = PhysicsRayQueryParameters2D.create(from_pos, to_pos)
	query.collision_mask = 1  # Camada de plataformas
	var result = space_state.intersect_ray(query)
	
	if result:
		# Encontrou uma plataforma abaixo, ajustar posição
		var platform_top = result.position.y
		# Ajustar para ficar sobre a plataforma (considerando altura do inimigo de 28 pixels)
		# O centro do inimigo deve estar a 14 pixels do topo da plataforma
		global_position.y = platform_top - 14
		start_position = global_position  # Atualizar posição inicial
		print("Inimigo reposicionado sobre plataforma em: ", global_position)
	else:
		# Não encontrou plataforma, tentar encontrar a mais próxima
		find_nearest_platform()

func find_nearest_platform():
	# Procurar plataformas próximas na cena
	var platforms = get_tree().get_nodes_in_group("platform")
	if platforms.is_empty():
		# Se não há grupo, procurar por nome
		var scene = get_tree().current_scene
		if scene:
			for child in scene.get_children():
				if child.name.begins_with("Platform"):
					platforms.append(child)
	
	if platforms.size() > 0:
		var nearest_platform = null
		var nearest_distance = INF
		
		for platform in platforms:
			var distance = abs(global_position.x - platform.global_position.x)
			if distance < nearest_distance and distance < 500:  # Apenas plataformas próximas
				nearest_distance = distance
				nearest_platform = platform
		
		if nearest_platform:
			# Posicionar sobre a plataforma mais próxima
			# A plataforma tem altura de 32 pixels, então o topo está em y - 16
			var platform_top = nearest_platform.global_position.y - 16
			# O inimigo tem altura de 28 pixels, então o centro deve estar a 14 pixels do topo
			global_position = Vector2(nearest_platform.global_position.x, platform_top - 14)
			start_position = global_position
			print("Inimigo reposicionado para plataforma mais próxima: ", global_position)
