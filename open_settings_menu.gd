extends Node

# Função auxiliar para abrir o menu de configurações de qualquer lugar do jogo

static func open_settings_menu(parent_node: Node):
	"""Abre o menu de configurações a partir de qualquer nó"""
	if not SettingsManager:
		print("ERRO: SettingsManager não está disponível!")
		return null
	
	var settings_scene = load("res://SettingsMenu.tscn")
	if not settings_scene:
		print("ERRO: Não foi possível carregar SettingsMenu.tscn")
		return null
	
	var settings_menu = settings_scene.instantiate()
	if not settings_menu:
		print("ERRO: Falha ao instanciar menu de configurações")
		return null
	
	# Adicionar ao CanvasLayer se o parent for um Node2D ou similar
	if parent_node is Node2D:
		# Criar um CanvasLayer para o menu
		var canvas = CanvasLayer.new()
		canvas.name = "SettingsCanvas"
		parent_node.add_child(canvas)
		canvas.add_child(settings_menu)
	else:
		parent_node.add_child(settings_menu)
	
	# Pausar o jogo quando o menu estiver aberto
	get_tree().paused = true
	
	print("Menu de configurações aberto com sucesso!")
	return settings_menu

