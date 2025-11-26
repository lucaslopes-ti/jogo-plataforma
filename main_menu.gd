extends Control

# Menu principal profissional para comercialização

@onready var title_label = $VBoxContainer/TitleLabel
@onready var start_button = $VBoxContainer/StartButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var version_label = $VersionLabel

var background_particles: Array[Node2D] = []

func _ready():
	# Configurar versão
	if version_label:
		version_label.text = "v1.0.0"
	
	# Animar título
	if title_label:
		animate_title()
	
	# Criar partículas de fundo
	create_background_particles()
	
	# Conectar botões
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	# Fade in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)

func animate_title():
	if not title_label:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(title_label, "modulate:a", 0.7, 1.5)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)
	
	# Efeito de brilho
	var glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(title_label, "scale", Vector2(1.05, 1.05), 1.0)
	glow_tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.0)

func create_background_particles():
	# Criar partículas tecnológicas no fundo
	for i in range(30):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(0, 0.8, 1, 0.3)
		particle.position = Vector2(randf() * 1920, randf() * 1080)
		particle.z_index = -1
		add_child(particle)
		background_particles.append(particle)
		
		# Animação flutuante
		var tween = create_tween()
		tween.set_loops()
		var target_y = particle.position.y + randf_range(-50, 50)
		tween.tween_property(particle, "position:y", target_y, randf_range(2.0, 4.0))
		tween.tween_property(particle, "position:y", particle.position.y, randf_range(2.0, 4.0))

func _on_start_pressed():
	# Efeito de clique
	ScreenEffects.flash_screen(Color(0, 0.8, 1, 0.3), 0.2)
	
	# Fade out e iniciar jogo
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# Carregar cena principal
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_settings_pressed():
	# Abrir menu de configurações (implementar depois)
	print("Configurações")

func _on_quit_pressed():
	# Sair do jogo
	get_tree().quit()

