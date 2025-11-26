extends Label

# Sistema de texto flutuante que desaparece automaticamente

var lifetime: float = 1.0
var float_speed: float = 50.0

func _ready():
	# Configurar estilo
	add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	add_theme_font_size_override("font_size", 20)
	add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	add_theme_constant_override("outline_size", 2)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Animação de flutuação e fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - float_speed, lifetime)
	tween.tween_property(self, "modulate:a", 0.0, lifetime)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), lifetime * 0.5)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), lifetime * 0.5).set_delay(lifetime * 0.5)
	
	await tween.finished
	queue_free()

