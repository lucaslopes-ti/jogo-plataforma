extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var camera = $Player/Camera2D

var player_start_position = Vector2(200, 200)

func _ready():
	print("Jogo de Plataforma iniciado!")
	print("Use as setas para mover e ESPAÇO para pular")
	
	if player:
		player.collected_coin.connect(_on_player_collected_coin)
		player.player_died.connect(_on_player_died)
	
	if camera:
		camera.limit_left = -1000
		camera.limit_right = 5000
		camera.limit_top = -1000
		camera.limit_bottom = 2000

func _on_player_collected_coin():
	if ui:
		ui.add_score(10)

func _on_player_died():
	if ui:
		var should_respawn = not ui.lose_life()
		if should_respawn:
			respawn_player()

func respawn_player():
	await get_tree().create_timer(0.5).timeout
	if player:
		player.queue_free()
	
	# Recriar jogador
	var player_scene = load("res://Player.tscn")
	var new_player = player_scene.instantiate()
	new_player.position = player_start_position
	new_player.collected_coin.connect(_on_player_collected_coin)
	new_player.player_died.connect(_on_player_died)
	add_child(new_player)
	player = new_player
	
	# Mover câmera para o novo jogador
	if camera:
		camera.get_parent().remove_child(camera)
		new_player.add_child(camera)

