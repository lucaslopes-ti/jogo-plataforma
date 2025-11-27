extends CanvasLayer

# Sistema de login/cadastro

@onready var login_panel = $LoginPanel
@onready var username_input = $LoginPanel/VBoxContainer/UsernameInput
@onready var login_button = $LoginPanel/VBoxContainer/LoginButton

var user_data_manager: Node

signal user_logged_in(user_data: Dictionary)

func _ready():
	user_data_manager = get_node("/root/UserDataManager")
	add_to_group("login_system")
	
	# NÃO pausar ainda - deixar o input funcionar
	login_panel.visible = true
	login_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	login_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Não bloquear eventos de mouse
	
	# Aguardar vários frames para garantir que tudo está carregado
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Configurar LineEdit PRIMEIRO
	if username_input:
		username_input.process_mode = Node.PROCESS_MODE_ALWAYS
		username_input.editable = true
		username_input.focus_mode = Control.FOCUS_ALL
		
		# Conectar sinal para Enter
		if not username_input.text_submitted.is_connected(_on_username_entered):
			username_input.text_submitted.connect(_on_username_entered)
		
		# Dar foco ao campo de texto
		username_input.call_deferred("grab_focus")
		print("LineEdit configurado, tentando dar foco...")
	
	if login_button:
		login_button.process_mode = Node.PROCESS_MODE_ALWAYS
		login_button.text = "ENTRAR"
		login_button.disabled = false
		login_button.mouse_filter = Control.MOUSE_FILTER_STOP
		login_button.focus_mode = Control.FOCUS_ALL
		login_button.flat = false  # Garantir que não é flat
		
		# Desconectar qualquer conexão anterior para evitar duplicação
		if login_button.pressed.is_connected(_on_login_pressed):
			login_button.pressed.disconnect(_on_login_pressed)
		if login_button.button_down.is_connected(_on_login_button_down):
			login_button.button_down.disconnect(_on_login_button_down)
		
		# Conectar múltiplos sinais para garantir que funciona
		call_deferred("_connect_login_button")
		print("Botão ENTRAR encontrado - texto: '", login_button.text, "'")
	else:
		print("ERRO: login_button não encontrado!")
	
	# VBoxContainer também precisa de process_mode
	var vbox = login_panel.get_node_or_null("VBoxContainer")
	if vbox:
		vbox.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Aguardar mais um frame e dar foco novamente
	await get_tree().process_frame
	if username_input:
		username_input.call_deferred("grab_focus")
		print("Foco dado ao LineEdit")
	
	# NÃO pausar o jogo - deixar o jogador digitar livremente
	# O jogo só será pausado quando necessário (ex: durante perguntas)
	# get_tree().paused = true  # COMENTADO - não pausar para permitir input
	print("Login pronto - aguardando input do usuário")
	
	# Garantir conexão do botão após tudo estar pronto
	await get_tree().process_frame
	await get_tree().process_frame  # Aguardar mais um frame
	_connect_login_button()
	
	# Verificação final
	await get_tree().process_frame
	if login_button:
		print("=== VERIFICAÇÃO FINAL DO BOTÃO ===")
		print("Botão existe: ", login_button != null)
		print("Botão visível: ", login_button.visible)
		print("Botão habilitado: ", not login_button.disabled)
		print("Botão conectado (pressed): ", login_button.pressed.is_connected(_on_login_pressed))
		print("Botão conectado (button_down): ", login_button.button_down.is_connected(_on_login_button_down))
		print("Botão process_mode: ", login_button.process_mode)
		print("Botão mouse_filter: ", login_button.mouse_filter)

func _connect_login_button():
	# Função auxiliar para conectar o botão de forma confiável
	if login_button:
		# Conectar sinal pressed (principal)
		if not login_button.pressed.is_connected(_on_login_pressed):
			login_button.pressed.connect(_on_login_pressed)
			print("Botão ENTRAR conectado (pressed) com sucesso!")
		else:
			print("Botão ENTRAR já estava conectado (pressed)")
		
		# Conectar também button_down como backup
		if not login_button.button_down.is_connected(_on_login_button_down):
			login_button.button_down.connect(_on_login_button_down)
			print("Botão ENTRAR conectado (button_down) com sucesso!")
		
		# Testar se o botão está clicável
		print("Botão habilitado: ", not login_button.disabled)
		print("Botão visível: ", login_button.visible)
		print("Botão process_mode: ", login_button.process_mode)
		print("Botão mouse_filter: ", login_button.mouse_filter)
		
		# Adicionar script inline para capturar gui_input como último recurso
		if not login_button.has_meta("gui_input_connected"):
			login_button.set_meta("gui_input_connected", true)
			# Criar um script temporário para o botão
			var button_script = """
extends Button

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("GUI_INPUT detectado no botão ENTRAR!")
		var login_system = get_node("/root/LoginSystem")
		if login_system:
			login_system._on_login_pressed()
"""
			# Não vamos adicionar script inline, mas vamos garantir que o botão recebe eventos
			# Em vez disso, vamos usar _unhandled_input

func _input(event):
	# Debug: verificar se eventos estão chegando
	if event is InputEventKey and event.pressed:
		print("Tecla pressionada: ", event.keycode)
		if username_input and username_input.has_focus():
			print("LineEdit tem foco!")

func _unhandled_input(event):
	# Capturar clique do mouse diretamente no botão como fallback
	# Este método captura eventos que não foram tratados por outros nós
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if login_button and login_button.visible and not login_button.disabled:
			# Converter posição global do mouse para posição local do botão
			var mouse_pos = event.position
			var button_global_pos = login_button.global_position
			var button_size = login_button.size
			var button_rect = Rect2(button_global_pos, button_size)
			
			# Verificar se o clique está dentro do botão
			if button_rect.has_point(mouse_pos):
				print("Clique detectado diretamente no botão ENTRAR (unhandled_input)!")
				get_viewport().set_input_as_handled()  # Marcar como tratado
				_on_login_pressed()

func _on_username_entered(_text: String):
	_on_login_pressed()

func _on_login_button_down():
	# Backup handler para button_down
	print("Botão ENTRAR button_down detectado!")
	_on_login_pressed()

func _on_login_pressed():
	print("=== BOTÃO ENTRAR PRESSIONADO ===")
	
	if not username_input:
		print("ERRO: username_input não existe!")
		return
	
	var username = username_input.text.strip_edges()
	print("Username digitado: '", username, "' (tamanho: ", username.length(), ")")
	
	if username.length() > 0:
		print("Processando login...")
		# Carregar ou criar usuário automaticamente
		if user_data_manager:
			user_data_manager.load_user_data()
			var current_username = user_data_manager.current_user.get("username", "")
			
			if current_username != username:
				# Criar novo usuário se o nome for diferente
				print("Criando novo usuário: ", username)
				user_data_manager.create_user(username)
			else:
				print("Usuário já existe: ", username)
			
			print("Emitindo sinal user_logged_in...")
			user_logged_in.emit(user_data_manager.current_user)
			login_panel.visible = false
			get_tree().paused = false
			print("Login concluído!")
		else:
			print("ERRO: user_data_manager não existe!")
	else:
		print("ERRO: Username vazio! Por favor, digite um nome.")
		# Feedback visual - fazer o campo piscar
		if username_input:
			var tween = create_tween()
			tween.tween_property(username_input, "modulate", Color(1, 0.3, 0.3, 1), 0.2)
			tween.tween_property(username_input, "modulate", Color(1, 1, 1, 1), 0.2)
