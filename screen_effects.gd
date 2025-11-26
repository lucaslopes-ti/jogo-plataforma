extends Node

# Sistema de efeitos de tela para polimento profissional

var camera_shake_strength: float = 0.0
var camera_shake_duration: float = 0.0
var current_camera: Camera2D = null
var original_camera_offset: Vector2 = Vector2.ZERO

func shake_camera(strength: float = 5.0, duration: float = 0.3):
	# Efeito de shake na câmera
	camera_shake_strength = strength
	camera_shake_duration = duration
	
	# Encontrar câmera do jogador
	var scene = Engine.get_main_loop().current_scene
	if scene:
		var player = scene.get_node_or_null("Player")
		if player:
			current_camera = player.get_node_or_null("Camera2D")
			if current_camera:
				original_camera_offset = current_camera.offset
				start_shake()

func start_shake():
	if not current_camera:
		return
	
	var shake_tween = current_camera.create_tween()
	var loops = int(camera_shake_duration / 0.05)
	
	for i in range(loops):
		var random_offset = Vector2(
			randf_range(-camera_shake_strength, camera_shake_strength),
			randf_range(-camera_shake_strength, camera_shake_strength)
		)
		shake_tween.tween_property(current_camera, "offset", original_camera_offset + random_offset, 0.05)
	
	shake_tween.tween_property(current_camera, "offset", original_camera_offset, 0.1)
	camera_shake_strength = 0.0

func flash_screen(color: Color = Color.WHITE, duration: float = 0.2):
	# Efeito de flash na tela
	var scene = Engine.get_main_loop().current_scene
	if not scene:
		return
		
	var flash = ColorRect.new()
	flash.color = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 1000
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.add_child(flash)
	
	var tween = scene.create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.tween_callback(flash.queue_free)

func fade_in(duration: float = 0.5):
	# Fade in da tela
	var scene = Engine.get_main_loop().current_scene
	if not scene:
		return
		
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_index = 1000
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.modulate.a = 1.0
	scene.add_child(fade)
	
	var tween = scene.create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, duration)
	tween.tween_callback(fade.queue_free)

func fade_out(duration: float = 0.5):
	# Fade out da tela
	var scene = Engine.get_main_loop().current_scene
	if not scene:
		return
		
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_index = 1000
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.modulate.a = 0.0
	scene.add_child(fade)
	
	var tween = scene.create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, duration)
