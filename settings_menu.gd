extends Control

# Menu de configurações completo e funcional

@onready var master_volume_slider = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/AudioSection/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_label = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/AudioSection/MasterVolumeContainer/MasterVolumeLabel
@onready var music_volume_slider = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/AudioSection/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_label = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/AudioSection/MusicVolumeContainer/MusicVolumeLabel
@onready var sfx_volume_slider = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/AudioSection/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_label = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/AudioSection/SFXVolumeContainer/SFXVolumeLabel

@onready var fullscreen_checkbox = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/VideoSection/FullscreenContainer/FullscreenCheckBox
@onready var vsync_checkbox = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/VideoSection/VSyncContainer/VSyncCheckBox
@onready var resolution_option = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/VideoSection/ResolutionContainer/ResolutionOptionButton

@onready var difficulty_option = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/GameplaySection/DifficultyContainer/DifficultyOptionButton
@onready var show_tutorial_checkbox = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/GameplaySection/TutorialContainer/ShowTutorialCheckBox

@onready var back_button = $Panel/VBoxContainer/ButtonContainer/BackButton
@onready var reset_button = $Panel/VBoxContainer/ButtonContainer/ResetButton

var parent_menu = null

# Resoluções disponíveis
var resolutions = [
	{"name": "1280x720", "width": 1280, "height": 720},
	{"name": "1366x768", "width": 1366, "height": 768},
	{"name": "1600x900", "width": 1600, "height": 900},
	{"name": "1920x1080", "width": 1920, "height": 1080},
	{"name": "2560x1440", "width": 2560, "height": 1440}
]

func _ready():
	# Verificar se SettingsManager está disponível
	if not SettingsManager:
		print("ERRO: SettingsManager não encontrado!")
		queue_free()
		return
	
	print("Menu de configurações inicializando...")
	
	# Garantir que está visível desde o início
	visible = true
	modulate.a = 1.0
	
	# Garantir que ocupa toda a tela
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Aguardar um frame para garantir que tudo está pronto
	await get_tree().process_frame
	
	# Carregar configurações atuais
	load_current_settings()
	
	# Conectar sinais
	_connect_signals()
	
	# Configurar resoluções
	_setup_resolutions()
	
	# Configurar dificuldades
	_setup_difficulties()
	
	# Animação de entrada (começar visível mas com escala menor)
	modulate.a = 1.0
	scale = Vector2(0.9, 0.9)
	
	# Criar tween que funciona mesmo quando pausado
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Garantir que está processando mesmo quando pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("Menu de configurações pronto e visível!")

func _connect_signals():
	print("Conectando sinais do menu de configurações...")
	
	# Áudio
	if master_volume_slider:
		if not master_volume_slider.value_changed.is_connected(_on_master_volume_changed):
			master_volume_slider.value_changed.connect(_on_master_volume_changed)
		print("✓ Master volume slider conectado")
	else:
		print("✗ ERRO: master_volume_slider não encontrado")
	
	if music_volume_slider:
		if not music_volume_slider.value_changed.is_connected(_on_music_volume_changed):
			music_volume_slider.value_changed.connect(_on_music_volume_changed)
		print("✓ Music volume slider conectado")
	else:
		print("✗ ERRO: music_volume_slider não encontrado")
	
	if sfx_volume_slider:
		if not sfx_volume_slider.value_changed.is_connected(_on_sfx_volume_changed):
			sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
		print("✓ SFX volume slider conectado")
	else:
		print("✗ ERRO: sfx_volume_slider não encontrado")
	
	# Vídeo
	if fullscreen_checkbox:
		if not fullscreen_checkbox.toggled.is_connected(_on_fullscreen_toggled):
			fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
		print("✓ Fullscreen checkbox conectado")
	else:
		print("✗ ERRO: fullscreen_checkbox não encontrado")
	
	if vsync_checkbox:
		if not vsync_checkbox.toggled.is_connected(_on_vsync_toggled):
			vsync_checkbox.toggled.connect(_on_vsync_toggled)
		print("✓ VSync checkbox conectado")
	else:
		print("✗ ERRO: vsync_checkbox não encontrado")
	
	if resolution_option:
		if not resolution_option.item_selected.is_connected(_on_resolution_selected):
			resolution_option.item_selected.connect(_on_resolution_selected)
		print("✓ Resolution option conectado")
	else:
		print("✗ ERRO: resolution_option não encontrado")
	
	# Gameplay
	if difficulty_option:
		if not difficulty_option.item_selected.is_connected(_on_difficulty_selected):
			difficulty_option.item_selected.connect(_on_difficulty_selected)
		print("✓ Difficulty option conectado")
	else:
		print("✗ ERRO: difficulty_option não encontrado")
	
	if show_tutorial_checkbox:
		if not show_tutorial_checkbox.toggled.is_connected(_on_tutorial_toggled):
			show_tutorial_checkbox.toggled.connect(_on_tutorial_toggled)
		print("✓ Tutorial checkbox conectado")
	else:
		print("✗ ERRO: show_tutorial_checkbox não encontrado")
	
	# Botões
	if back_button:
		if not back_button.pressed.is_connected(_on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)
		if not back_button.mouse_entered.is_connected(_on_button_hover):
			back_button.mouse_entered.connect(_on_button_hover)
		print("✓ Back button conectado")
	else:
		print("✗ ERRO CRÍTICO: back_button não encontrado!")
	
	if reset_button:
		if not reset_button.pressed.is_connected(_on_reset_pressed):
			reset_button.pressed.connect(_on_reset_pressed)
		if not reset_button.mouse_entered.is_connected(_on_button_hover):
			reset_button.mouse_entered.connect(_on_button_hover)
		print("✓ Reset button conectado")
	else:
		print("✗ ERRO: reset_button não encontrado")

func _setup_resolutions():
	if not resolution_option:
		return
	
	resolution_option.clear()
	var current_res = SettingsManager.get_resolution()
	var current_index = 0
	
	for i in range(resolutions.size()):
		var res = resolutions[i]
		resolution_option.add_item(res.name)
		if res.width == current_res.x and res.height == current_res.y:
			current_index = i
	
	resolution_option.selected = current_index

func _setup_difficulties():
	if not difficulty_option:
		return
	
	difficulty_option.clear()
	difficulty_option.add_item("Fácil")
	difficulty_option.add_item("Normal")
	difficulty_option.add_item("Difícil")
	difficulty_option.add_item("Muito Difícil")

func load_current_settings():
	"""Carrega as configurações atuais e atualiza a UI"""
	if not SettingsManager:
		print("ERRO: SettingsManager não disponível em load_current_settings()")
		return
	
	print("Carregando configurações atuais...")
	
	# Áudio
	if master_volume_slider:
		var volume = SettingsManager.get_master_volume()
		master_volume_slider.value = volume
		_update_master_volume_label(volume)
	
	if music_volume_slider:
		var volume = SettingsManager.get_music_volume()
		music_volume_slider.value = volume
		_update_music_volume_label(volume)
	
	if sfx_volume_slider:
		var volume = SettingsManager.get_sfx_volume()
		sfx_volume_slider.value = volume
		_update_sfx_volume_label(volume)
	
	# Vídeo
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = SettingsManager.get_fullscreen()
	if vsync_checkbox:
		vsync_checkbox.button_pressed = SettingsManager.get_vsync()
	
	# Gameplay
	if difficulty_option:
		var difficulty = SettingsManager.current_settings.get("gameplay", {}).get("difficulty", 1)
		difficulty_option.selected = difficulty - 1
	if show_tutorial_checkbox:
		var show_tutorial = SettingsManager.current_settings.get("gameplay", {}).get("show_tutorial", true)
		show_tutorial_checkbox.button_pressed = show_tutorial

func _update_master_volume_label(value: float):
	if master_volume_label:
		master_volume_label.text = "Volume Mestre: " + str(int(value * 100)) + "%"

func _update_music_volume_label(value: float):
	if music_volume_label:
		music_volume_label.text = "Música: " + str(int(value * 100)) + "%"

func _update_sfx_volume_label(value: float):
	if sfx_volume_label:
		sfx_volume_label.text = "Efeitos Sonoros: " + str(int(value * 100)) + "%"

# ========== HANDLERS DE ÁUDIO ==========

func _on_master_volume_changed(value: float):
	_update_master_volume_label(value)
	SettingsManager.set_master_volume(value)
	if SoundManager:
		SoundManager.play_ui_click_sound()

func _on_music_volume_changed(value: float):
	_update_music_volume_label(value)
	SettingsManager.set_music_volume(value)
	if SoundManager:
		SoundManager.play_ui_click_sound()

func _on_sfx_volume_changed(value: float):
	_update_sfx_volume_label(value)
	SettingsManager.set_sfx_volume(value)
	if SoundManager:
		SoundManager.play_ui_click_sound()

# ========== HANDLERS DE VÍDEO ==========

func _on_fullscreen_toggled(button_pressed: bool):
	SettingsManager.set_fullscreen(button_pressed)
	if SoundManager:
		SoundManager.play_ui_click_sound()

func _on_vsync_toggled(button_pressed: bool):
	SettingsManager.set_vsync(button_pressed)
	if SoundManager:
		SoundManager.play_ui_click_sound()

func _on_resolution_selected(index: int):
	if index >= 0 and index < resolutions.size():
		var res = resolutions[index]
		SettingsManager.set_resolution(res.width, res.height)
		if SoundManager:
			SoundManager.play_ui_click_sound()

# ========== HANDLERS DE GAMEPLAY ==========

func _on_difficulty_selected(index: int):
	if not SettingsManager.current_settings.has("gameplay"):
		SettingsManager.current_settings.gameplay = {}
	SettingsManager.current_settings.gameplay.difficulty = index + 1
	SettingsManager.save_settings()
	if SoundManager:
		SoundManager.play_ui_click_sound()

func _on_tutorial_toggled(button_pressed: bool):
	if not SettingsManager.current_settings.has("gameplay"):
		SettingsManager.current_settings.gameplay = {}
	SettingsManager.current_settings.gameplay.show_tutorial = button_pressed
	SettingsManager.save_settings()
	if SoundManager:
		SoundManager.play_ui_click_sound()

# ========== HANDLERS DE BOTÕES ==========

signal menu_closed

func _on_back_pressed():
	if SoundManager:
		SoundManager.play_ui_click_sound()
	
	close_menu()

func close_menu():
	"""Fecha o menu de configurações"""
	print("Fechando menu de configurações...")
	
	# Emitir sinal de fechamento
	if has_signal("menu_closed"):
		menu_closed.emit()
	
	# Despausar o jogo antes de remover o menu
	get_tree().paused = false
	
	# Animação de saída
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)
	await tween.finished
	
	# Remover o CanvasLayer se existir
	var parent = get_parent()
	if parent and parent.name == "SettingsCanvas":
		parent.queue_free()
	else:
		queue_free()

func _on_reset_pressed():
	if SoundManager:
		SoundManager.play_ui_click_sound()
	
	# Confirmar reset
	var confirm = _show_confirm_dialog("Deseja realmente resetar todas as configurações para os valores padrão?")
	if confirm:
		SettingsManager.reset_to_defaults()
		load_current_settings()
		if SoundManager:
			SoundManager.play_portal_success_sound()

func _on_button_hover():
	if SoundManager:
		SoundManager.play_ui_hover_sound()

func _show_confirm_dialog(message: String) -> bool:
	# Implementação simples de confirmação
	# Em produção, você pode usar um diálogo mais elaborado
	print(message)
	return true  # Por enquanto, sempre confirma

func _input(event):
	# Fechar com ESC
	if event.is_action_pressed("ui_cancel"):
		close_menu()
