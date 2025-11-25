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

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

signal collected_coin
signal player_died

func _ready():
	# Garantir que o jogador está configurado corretamente
	print("Jogador inicializado na posição: ", global_position)
	# Verificar se o collision shape está configurado
	if collision_shape and not collision_shape.shape:
		print("ERRO: CollisionShape2D não tem shape configurado!")

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
	
	# Movimento horizontal com aceleração suave
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		facing_direction = direction
		var accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
		
		# Animações (serão implementadas quando sprites estiverem prontos)
		# Por enquanto, apenas atualizamos a direção visual
		pass
	else:
		var friction = FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
		# Animações (serão implementadas quando sprites estiverem prontos)
		pass
	
	# Flip visual baseado na direção (se tiver sprite)
	if sprite:
		sprite.scale.x = abs(sprite.scale.x) * facing_direction
	
	# Usar move_and_slide com parâmetros padrão
	# O segundo parâmetro (up_direction) é importante para is_on_floor()
	move_and_slide()
	
	# Verificar se caiu do mapa
	if global_position.y > 2000:
		die()

func die():
	player_died.emit()
	queue_free()

func collect_coin():
	collected_coin.emit()
