extends CharacterBody2D

const SPEED = 80.0
const GRAVITY_SCALE = 1.0

var direction = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var patrol_distance = 200.0

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	start_position = global_position
	# Conectar área de detecção
	await get_tree().process_frame
	var area = get_node_or_null("Area2D")
	if area:
		area.body_entered.connect(_on_area_body_entered)

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
	
	# Verificar colisão com paredes
	if is_on_wall():
		direction *= -1
	
	move_and_slide()
	
	# Verificar se caiu
	if global_position.y > 2000:
		queue_free()

func _on_area_body_entered(body):
	if body.name == "Player":
		body.die()
