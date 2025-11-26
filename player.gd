extends CharacterBody2D

# Velocidade do jogador
const SPEED = 350.0
const JUMP_VELOCITY = -450.0
const ACCELERATION = 2000.0
const FRICTION = 1500.0
const AIR_ACCELERATION = 1000.0
const AIR_FRICTION = 500.0

# Gravidade do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_direction = 1
var is_jumping = false
var coyote_time = 0.0
var coyote_time_max = 0.15
var jump_buffer = 0.0
var jump_buffer_max = 0.1

@onready var sprite = $AnimatedSprite2D2
@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D2  # Para usar sprites reais
@onready var body = get_node_or_null("AnimatedSprite2D2/Body")  # Pode não existir se usando sprites
@onready var left_arm = get_node_or_null("AnimatedSprite2D2/Body/LeftArm")
@onready var right_arm = get_node_or_null("AnimatedSprite2D2/Body/RightArm")
@onready var left_leg = get_node_or_null("AnimatedSprite2D2/Body/LeftLeg")
@onready var right_leg = get_node_or_null("AnimatedSprite2D2/Body/RightLeg")
@onready var head = get_node_or_null("AnimatedSprite2D2/Body/HeadBase")
@onready var torso = get_node_or_null("AnimatedSprite2D2/Body/TorsoBase")

var animation_state = "idle"  # idle, running, jumping, falling
var last_position_y = 0.0
var current_tween: Tween = null
var animation_frame: int = 0
var animation_timer: float = 0.0
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var using_sprites: bool = false  # Se está usando sprites reais ou fallback

signal collected_coin
signal player_died

func _ready():
	# Garantir que o jogador está configurado corretamente
	print("Jogador inicializado na posição: ", global_position)
	# Verificar se o collision shape está configurado
	if collision_shape and not collision_shape.shape:
		print("ERRO: CollisionShape2D não tem shape configurado!")
	last_position_y = global_position.y
	
	# Verificar se tem sprites configurados
	if animated_sprite and animated_sprite.sprite_frames:
		var animation_names = animated_sprite.sprite_frames.get_animation_names()
		if animation_names.size() > 0:
			using_sprites = true
			print("Usando sprites animados! Animações: ", animation_names)
			
			# Esconder qualquer fallback visual que possa existir
			if body:
				body.visible = false
				print("Body fallback escondido")
			
			# Ajustar velocidade das animações se necessário
			adjust_animation_speeds()
			
			# Garantir que a animação está tocando
			if animated_sprite.sprite_frames.has_animation("idle"):
				animated_sprite.play("idle")
			else:
				animated_sprite.play(animation_names[0])  # Tocar primeira animação disponível
			
			# Garantir que está visível e tocando
			animated_sprite.visible = true
			if not animated_sprite.is_playing():
				animated_sprite.play()
			print("Animação ativa: ", animated_sprite.animation, " | Tocando: ", animated_sprite.is_playing())
		else:
			using_sprites = false
			print("SpriteFrames vazio, usando fallback")
	else:
		using_sprites = false
		print("AnimatedSprite2D não configurado, usando fallback")

func adjust_animation_speeds():
	# Ajustar velocidades das animações para valores mais apropriados
	# NOTA: As velocidades podem precisar ser ajustadas manualmente no Godot
	# no SpriteFrames resource, pois set_animation_speed() pode não funcionar em runtime
	if not animated_sprite or not animated_sprite.sprite_frames:
		return
	
	var sprite_frames = animated_sprite.sprite_frames
	
	# Tentar ajustar velocidade (pode não funcionar em runtime, mas tenta mesmo assim)
	# Valores recomendados: idle=10-15 FPS, walk=12-15 FPS, run=15-20 FPS, attack=15-20 FPS
	if sprite_frames.has_animation("idle"):
		# Velocidade normal para idle (10-15 FPS é bom)
		pass  # Deixar como está configurado no Godot
	if sprite_frames.has_animation("walk"):
		# Walk deve ser um pouco mais rápido (12-15 FPS)
		pass
	if sprite_frames.has_animation("run"):
		# Run deve ser mais rápido (15-20 FPS)
		pass
	if sprite_frames.has_animation("jump"):
		sprite_frames.set_animation_loop("jump", false)  # Jump não deve repetir
	if sprite_frames.has_animation("fall"):
		sprite_frames.set_animation_loop("fall", false)  # Fall não deve repetir
	if sprite_frames.has_animation("attack"):
		sprite_frames.set_animation_loop("attack", false)  # Attack não deve repetir
	
	# Se run está vazio, usar walk como fallback
	if sprite_frames.has_animation("run") and sprite_frames.get_frame_count("run") == 0:
		# Copiar frames de walk para run
		if sprite_frames.has_animation("walk"):
			for i in range(sprite_frames.get_frame_count("walk")):
				var texture = sprite_frames.get_frame_texture("walk", i)
				sprite_frames.add_frame("run", texture)
	
	# Garantir que está tocando
	if not animated_sprite.is_playing():
		if sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
		print("Animação iniciada: ", animated_sprite.animation)

func _physics_process(delta):
	# Aplicar gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_time += delta
		is_jumping = true
	else:
		coyote_time = 0.0
		is_jumping = false
		if velocity.y > 0:
			velocity.y = 0
	
	# Jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = jump_buffer_max
	else:
		jump_buffer = max(0, jump_buffer - delta)
	
	# Pulo com coyote time e jump buffer
	if jump_buffer > 0 and (is_on_floor() or coyote_time < coyote_time_max):
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0
		coyote_time = coyote_time_max + 1
		play_jump_animation()
	
	# Movimento horizontal com aceleração suave
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		facing_direction = direction
		var accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
		
		# Animações de movimento
		if is_on_floor():
			play_run_animation()
	else:
		var friction = FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
		# Animações
		if is_on_floor():
			play_idle_animation()
	
	# Flip visual baseado na direção
	if using_sprites and animated_sprite:
		animated_sprite.flip_h = (facing_direction < 0)
	
	# Animação de pulo/cair
	if not is_on_floor():
		if global_position.y < last_position_y:
			play_jump_animation()
		else:
			play_fall_animation()
	
	last_position_y = global_position.y
	
	# Atualizar cooldown de ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Sistema de ataque (tecla X ou clique do mouse)
	if Input.is_action_just_pressed("ui_select") and attack_cooldown <= 0:
		perform_attack()
	
	# Usar move_and_slide com parâmetros padrão
	move_and_slide()
	
	# Verificar se caiu
	if global_position.y > 2000:
		die()

func perform_attack():
	if is_attacking:
		return
	
	is_attacking = true
	attack_cooldown = 0.5  # Cooldown de 0.5 segundos
	
	# Efeito visual de ataque
	if ScreenEffects:
		ScreenEffects.shake_camera(3.0, 0.15)
	
	# Usar sprite animado se disponível
	if using_sprites and animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation("attack"):
			animated_sprite.play("attack")
			# Aguardar animação terminar
			await animated_sprite.animation_finished
			is_attacking = false
			# Voltar para animação apropriada
			if is_on_floor():
				if abs(velocity.x) > 50:
					play_run_animation()
				else:
					play_idle_animation()
		else:
			# Se não tem animação de ataque, usar fallback
			is_attacking = false
			check_attack_hit()
	else:
		# Fallback: animação simples
		is_attacking = false
		check_attack_hit()

func play_idle_animation():
	if animation_state != "idle" and not is_attacking:
		animation_state = "idle"
		# Usar sprite animado se disponível
		if using_sprites and animated_sprite and animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("idle"):
				if animated_sprite.animation != "idle" or not animated_sprite.is_playing():
					animated_sprite.play("idle")
			elif animated_sprite.sprite_frames.has_animation("walk"):
				if animated_sprite.animation != "walk" or not animated_sprite.is_playing():
					animated_sprite.play("walk")  # Fallback para walk se não tiver idle
		else:
			# Fallback para animação programática
			reset_limbs()
			if current_tween:
				current_tween.kill()
			current_tween = create_tween()
			current_tween.set_loops()
			if head:
				current_tween.parallel().tween_property(head, "position:y", -0.5, 1.2)
				current_tween.parallel().tween_property(head, "position:y", 0.0, 1.2)
			if torso:
				current_tween.parallel().tween_property(torso, "position:y", -0.3, 1.2)
				current_tween.parallel().tween_property(torso, "position:y", 0.0, 1.2)

func play_run_animation():
	if animation_state != "running" and not is_attacking:
		animation_state = "running"
		# Usar sprite animado se disponível
		if using_sprites and animated_sprite and animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("run"):
				if animated_sprite.animation != "run" or not animated_sprite.is_playing():
					animated_sprite.play("run")
			elif animated_sprite.sprite_frames.has_animation("walk"):
				if animated_sprite.animation != "walk" or not animated_sprite.is_playing():
					animated_sprite.play("walk")
		else:
			# Fallback para animação programática
			reset_limbs()
			if current_tween:
				current_tween.kill()
			current_tween = create_tween()
			current_tween.set_loops()
			if left_leg:
				current_tween.parallel().tween_property(left_leg, "rotation_degrees", 25.0, 0.2)
				current_tween.parallel().tween_property(left_leg, "rotation_degrees", -25.0, 0.2)
			if right_leg:
				current_tween.parallel().tween_property(right_leg, "rotation_degrees", -25.0, 0.2)
				current_tween.parallel().tween_property(right_leg, "rotation_degrees", 25.0, 0.2)
			if left_arm:
				current_tween.parallel().tween_property(left_arm, "rotation_degrees", -30.0, 0.2)
				current_tween.parallel().tween_property(left_arm, "rotation_degrees", 30.0, 0.2)
			if right_arm:
				current_tween.parallel().tween_property(right_arm, "rotation_degrees", 30.0, 0.2)
				current_tween.parallel().tween_property(right_arm, "rotation_degrees", -30.0, 0.2)
			if torso:
				current_tween.parallel().tween_property(torso, "position:y", -2.0, 0.2)
				current_tween.parallel().tween_property(torso, "position:y", 0.0, 0.2)

func play_jump_animation():
	if animation_state != "jumping" and not is_attacking:
		animation_state = "jumping"
		# Usar sprite animado se disponível
		if using_sprites and animated_sprite and animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("jump"):
				if animated_sprite.animation != "jump" or not animated_sprite.is_playing():
					animated_sprite.play("jump")
		else:
			# Fallback para animação programática
			if current_tween:
				current_tween.kill()
			if left_leg:
				current_tween = create_tween()
				current_tween.tween_property(left_leg, "scale:y", 0.7, 0.1)
				current_tween.tween_property(left_leg, "scale:y", 1.0, 0.2)
			if right_leg:
				current_tween.parallel().tween_property(right_leg, "scale:y", 0.7, 0.1)
				current_tween.parallel().tween_property(right_leg, "scale:y", 1.0, 0.2)
			if left_arm:
				current_tween.parallel().tween_property(left_arm, "position:y", -2.0, 0.1)
			if right_arm:
				current_tween.parallel().tween_property(right_arm, "position:y", -2.0, 0.1)

func play_fall_animation():
	if animation_state != "falling" and not is_attacking:
		animation_state = "falling"
		# Usar sprite animado se disponível
		if using_sprites and animated_sprite and animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("fall"):
				if animated_sprite.animation != "fall" or not animated_sprite.is_playing():
					animated_sprite.play("fall")
			elif animated_sprite.sprite_frames.has_animation("jump"):
				if animated_sprite.animation != "jump" or not animated_sprite.is_playing():
					animated_sprite.play("jump")  # Fallback para jump
		else:
			# Fallback para animação programática
			if current_tween:
				current_tween.kill()
			if left_leg:
				current_tween = create_tween()
				current_tween.tween_property(left_leg, "scale:y", 1.15, 0.1)
			if right_leg:
				current_tween.parallel().tween_property(right_leg, "scale:y", 1.15, 0.1)
			if left_arm:
				current_tween.parallel().tween_property(left_arm, "position:y", 1.5, 0.1)
			if right_arm:
				current_tween.parallel().tween_property(right_arm, "position:y", 1.5, 0.1)

func reset_limbs():
	# Resetar todas as transformações dos membros (apenas se não estiver usando sprites)
	if using_sprites:
		return  # Não precisa resetar se está usando sprites
	
	if left_arm:
		left_arm.position = Vector2(-14, -6)
		left_arm.rotation_degrees = 0.0
		left_arm.scale = Vector2.ONE
	if right_arm:
		right_arm.position = Vector2(10, -6)
		right_arm.rotation_degrees = 0.0
		right_arm.scale = Vector2.ONE
	if left_leg:
		left_leg.position = Vector2(-10, 4)
		left_leg.rotation_degrees = 0.0
		left_leg.scale = Vector2.ONE
	if right_leg:
		right_leg.position = Vector2(4, 4)
		right_leg.rotation_degrees = 0.0
		right_leg.scale = Vector2.ONE
	if head:
		head.position = Vector2.ZERO
	if torso:
		torso.position = Vector2.ZERO

func die():
	# Efeito visual ao morrer
	if ScreenEffects:
		ScreenEffects.flash_screen(Color(1, 0.2, 0.2, 0.5), 0.3)
		ScreenEffects.shake_camera(8.0, 0.4)
	
	# Efeito de morte no personagem
	if using_sprites and animated_sprite:
		var tween = create_tween()
		tween.parallel().tween_property(animated_sprite, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(animated_sprite, "rotation_degrees", 360, 0.3)
		tween.parallel().tween_property(animated_sprite, "scale", Vector2(0.5, 0.5), 0.3)
	elif body:
		var tween = create_tween()
		tween.parallel().tween_property(body, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(body, "rotation_degrees", 360, 0.3)
		tween.parallel().tween_property(body, "scale", Vector2(0.5, 0.5), 0.3)
	
	player_died.emit()

func bounce():
	# Pequeno pulo ao derrotar inimigo
	velocity.y = JUMP_VELOCITY * 0.6  # 60% da força do pulo normal

func check_attack_hit():
	# Verificar se atacou um inimigo usando Area2D ou raycast
	var attack_range = 60.0
	var attack_position = global_position + Vector2(facing_direction * attack_range * 0.5, 0)
	
	# Usar overlap para detectar inimigos próximos
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = attack_position
	query.collision_mask = 0xFFFFFFFF  # Todas as camadas
	
	# Verificar inimigos no grupo
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			var direction_to_enemy = (enemy.global_position - global_position).normalized()
			
			# Verificar se está na frente e dentro do alcance
			if distance <= attack_range and abs(direction_to_enemy.x * facing_direction) > 0.5:
				if enemy.has_method("defeat_enemy"):
					enemy.defeat_enemy(self)
					bounce()  # Pequeno pulo ao derrotar
					break
