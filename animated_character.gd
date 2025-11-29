extends Node2D

# Sistema de animação de personagem usando frames programáticos
# Cria diferentes poses para animação

var current_animation: String = "idle"
var frame: int = 0
var frame_timer: float = 0.0
var frame_duration: float = 0.15

# Referências aos elementos do corpo
var head: Node2D
var torso: Node2D
var left_arm: Node2D
var right_arm: Node2D
var left_leg: Node2D
var right_leg: Node2D

func _ready():
	# Encontrar partes do corpo
	head = get_node_or_null("Body/HeadBase")
	torso = get_node_or_null("Body/TorsoBase")
	left_arm = get_node_or_null("Body/LeftArm")
	right_arm = get_node_or_null("Body/RightArm")
	left_leg = get_node_or_null("Body/LeftLeg")
	right_leg = get_node_or_null("Body/RightLeg")

func _process(delta):
	frame_timer += delta
	if frame_timer >= frame_duration:
		frame_timer = 0.0
		update_animation_frame()

func play_animation(anim_name: String):
	if current_animation != anim_name:
		current_animation = anim_name
		frame = 0
		frame_timer = 0.0

func update_animation_frame():
	match current_animation:
		"idle":
			animate_idle()
		"run":
			animate_run()
		"jump":
			animate_jump()
		"fall":
			animate_fall()
	
	frame = (frame + 1) % 4

func animate_idle():
	# Animação sutil de respiração
	var breath_offset = sin(frame * 0.5) * 0.5
	if head:
		head.position.y = breath_offset
	if torso:
		torso.position.y = breath_offset * 0.8

func animate_run():
	# Animação de corrida - movimento de pernas e braços
	var leg_swing = sin(frame * 1.5) * 2.0
	var arm_swing = -sin(frame * 1.5) * 3.0
	var body_bob = abs(sin(frame * 1.5)) * 1.5
	
	if left_leg:
		left_leg.rotation_degrees = leg_swing
	if right_leg:
		right_leg.rotation_degrees = -leg_swing
	if left_arm:
		left_arm.rotation_degrees = arm_swing
	if right_arm:
		right_arm.rotation_degrees = -arm_swing
	if torso:
		torso.position.y = -body_bob

func animate_jump():
	# Animação de pulo - compressão
	if left_leg:
		left_leg.scale.y = 0.8
		left_leg.position.y = 1.0
	if right_leg:
		right_leg.scale.y = 0.8
		right_leg.position.y = 1.0
	if left_arm:
		left_arm.position.y = -1.0
	if right_arm:
		right_arm.position.y = -1.0

func animate_fall():
	# Animação de queda - estiramento
	if left_leg:
		left_leg.scale.y = 1.1
	if right_leg:
		right_leg.scale.y = 1.1
	if left_arm:
		left_arm.position.y = 1.0
	if right_arm:
		right_arm.position.y = 1.0




