extends CanvasLayer

# Sistema de login/cadastro

@onready var login_panel = $LoginPanel
@onready var username_input = $LoginPanel/VBoxContainer/UsernameInput
@onready var login_button = $LoginPanel/VBoxContainer/LoginButton
@onready var create_account_button = $LoginPanel/VBoxContainer/CreateAccountButton

var user_data_manager: Node

signal user_logged_in(user_data: Dictionary)

func _ready():
	user_data_manager = get_node("/root/UserDataManager")
	add_to_group("login_system")
	
	# NÃO pausar ainda - deixar o input funcionar
	login_panel.visible = true
	login_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
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
		if not login_button.pressed.is_connected(_on_login_pressed):
			login_button.pressed.connect(_on_login_pressed)
	if create_account_button:
		create_account_button.process_mode = Node.PROCESS_MODE_ALWAYS
		if not create_account_button.pressed.is_connected(_on_create_account_pressed):
			create_account_button.pressed.connect(_on_create_account_pressed)
	
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

func _input(event):
	# Debug: verificar se eventos estão chegando
	if event is InputEventKey and event.pressed:
		print("Tecla pressionada: ", event.keycode)
		if username_input and username_input.has_focus():
			print("LineEdit tem foco!")

func _on_username_entered(_text: String):
	_on_login_pressed()

func _on_login_pressed():
	var username = username_input.text.strip_edges()
	if username.length() > 0:
		# Carregar ou criar usuário
		user_data_manager.load_user_data()
		if user_data_manager.current_user.get("username", "") != username:
			# Criar novo usuário
			user_data_manager.create_user(username)
		user_logged_in.emit(user_data_manager.current_user)
		login_panel.visible = false
		get_tree().paused = false

func _on_create_account_pressed():
	_on_login_pressed()  # Mesma funcionalidade por enquanto
