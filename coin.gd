extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var collected = false

func _ready():
	body_entered.connect(_on_body_entered)
	# Rotação contínua da moeda
	if animated_sprite:
		create_rotation_animation()

func create_rotation_animation():
	# Animação simples de rotação
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(animated_sprite, "rotation", TAU, 1.0)

func _on_body_entered(body):
	if body.name == "Player" and not collected:
		collected = true
		if body.has_method("collect_coin"):
			body.collect_coin()
		
		# Efeito visual de escala
		if animated_sprite:
			var tween = create_tween()
			tween.tween_property(animated_sprite, "scale", Vector2(1.5, 1.5), 0.1)
			tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.1)
		
		# Remover após animação
		await get_tree().create_timer(0.2).timeout
		queue_free()

