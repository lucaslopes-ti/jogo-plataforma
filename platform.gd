extends StaticBody2D

# Script para plataformas
# Pode ser expandido para adicionar comportamentos especiais como movimento

func _ready():
	# Adicionar efeito visual sutil se ColorRect existir
	var color_rect = get_node_or_null("ColorRect")
	if color_rect:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(color_rect, "modulate", Color(0.5, 0.9, 0.4, 1), 2.0)
		tween.tween_property(color_rect, "modulate", Color(0.4, 0.8, 0.3, 1), 2.0)

