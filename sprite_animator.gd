extends AnimatedSprite2D

# Sistema de animação de sprites para o personagem
# Gerencia todas as animações do personagem

enum AnimationState {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	DRAW_WEAPON,
	HURT,
	DEATH
}

var current_state: AnimationState = AnimationState.IDLE
var facing_right: bool = true

# Referências aos sprites (serão carregados das imagens)
var idle_frames: Array[Texture2D] = []
var walk_frames: Array[Texture2D] = []
var run_frames: Array[Texture2D] = []
var jump_frames: Array[Texture2D] = []
var fall_frames: Array[Texture2D] = []
var attack_frames: Array[Texture2D] = []
var draw_weapon_frames: Array[Texture2D] = []
var hurt_frames: Array[Texture2D] = []
var death_frames: Array[Texture2D] = []

func _ready():
	# Carregar sprites das imagens
	load_sprite_frames()
	setup_animations()

func load_sprite_frames():
	# Carregar frames das animações
	# As imagens serão carregadas aqui quando disponíveis
	# Por enquanto, vamos criar um sistema que funciona com spritesheets
	
	# TODO: Carregar sprites reais das imagens fornecidas
	pass

func setup_animations():
	# Configurar animações no AnimatedSprite2D
	var sprite_frames = SpriteFrames.new()
	
	# Criar animações
	# idle, walk, run, jump, fall, attack, etc.
	
	# Por enquanto, vamos usar o sistema programático
	pass

func play_animation(state: AnimationState):
	if current_state == state:
		return
	
	current_state = state
	
	match state:
		AnimationState.IDLE:
			play("idle")
		AnimationState.WALK:
			play("walk")
		AnimationState.RUN:
			play("run")
		AnimationState.JUMP:
			play("jump")
		AnimationState.FALL:
			play("fall")
		AnimationState.ATTACK:
			play("attack")
		AnimationState.DRAW_WEAPON:
			play("draw_weapon")
		AnimationState.HURT:
			play("hurt")
		AnimationState.DEATH:
			play("death")
	
	# Aplicar direção
	flip_h = not facing_right

func set_facing_direction(right: bool):
	facing_right = right
	flip_h = not facing_right




