extends Area2D

@onready var question_system = get_node("/root/QuestionSystem")
@onready var collision_shape = $CollisionShape2D
@onready var visual = $Visual

var question_difficulty: int = 1
var question_category: String = ""
var is_active: bool = true
var question_answered: bool = false

signal portal_activated

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("question_portal")
	
	# Garantir que está ativo inicialmente
	is_active = true
	question_answered = false
	monitoring = true
	monitorable = true
	
	update_visual()
	create_pulse_animation()

func create_pulse_animation():
	# Animação de pulso para o portal
	var outer_ring = get_node_or_null("Visual/OuterRing")
	var middle_ring = get_node_or_null("Visual/MiddleRing")
	var inner_core = get_node_or_null("Visual/InnerCore")
	
	if outer_ring:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(outer_ring, "modulate:a", 0.5, 1.0)
		tween.tween_property(outer_ring, "modulate:a", 0.3, 1.0)
	
	if middle_ring:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(middle_ring, "modulate:a", 0.7, 1.2)
		tween.tween_property(middle_ring, "modulate:a", 0.4, 1.2)
	
	if inner_core:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(inner_core, "scale", Vector2(1.1, 1.1), 0.8)
		tween.tween_property(inner_core, "scale", Vector2(1.0, 1.0), 0.8)

func update_visual():
	if visual:
		if question_answered:
			# Verde quando respondido
			var inner = get_node_or_null("Visual/InnerCore")
			var center = get_node_or_null("Visual/Center")
			if inner:
				inner.color = Color(0.2, 1, 0.4, 1)
			if center:
				center.color = Color(0, 1, 0.5, 1)
		else:
			# Ciano/azul quando ativo
			var inner = get_node_or_null("Visual/InnerCore")
			var center = get_node_or_null("Visual/Center")
			if inner:
				inner.color = Color(0.1, 0.7, 1, 1)
			if center:
				center.color = Color(0, 1, 1, 1)

func _on_body_entered(body):
	if body.name == "Player" and is_active and not question_answered:
		print("Portal ativado pelo jogador!")
		activate_portal()
	else:
		if body.name == "Player":
			print("Portal não ativado - is_active: ", is_active, " question_answered: ", question_answered)

func activate_portal():
	if question_answered or not is_active:
		print("Portal não pode ser ativado - já foi respondido ou está inativo")
		return
	portal_activated.emit()
	# O sistema de UI vai lidar com mostrar a pergunta

func set_answered():
	print("Portal marcado como respondido!")
	question_answered = true
	is_active = false
	
	# Desabilitar colisão imediatamente
	if collision_shape:
		collision_shape.disabled = true
		collision_shape.visible = false
	
	# Desconectar sinal para evitar ativação novamente
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	
	# Desabilitar área imediatamente
	monitoring = false
	monitorable = false
	
	# Esconder visual imediatamente
	if visual:
		visual.visible = false
		visual.modulate.a = 0.0
	
	# Remover do grupo
	remove_from_group("question_portal")
	
	update_visual()
	
	# Fazer portal desaparecer imediatamente
	disappear()

func reset_portal():
	question_answered = false
	is_active = true
	update_visual()

func disappear():
	print("Portal desaparecendo...")
	# Desabilitar completamente a área ANTES de qualquer coisa
	monitoring = false
	monitorable = false
	
	# Esconder todos os elementos visuais imediatamente
	if visual:
		visual.visible = false
		visual.modulate.a = 0.0
	
	# Desabilitar completamente processos
	set_physics_process(false)
	set_process(false)
	
	# Remover do grupo para evitar detecção
	remove_from_group("question_portal")
	
	# Remover imediatamente
	queue_free()
	print("Portal removido!")
