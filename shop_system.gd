extends CanvasLayer

# Sistema de loja virtual

@onready var shop_panel = $ShopPanel
@onready var coins_label = $ShopPanel/VBoxContainer/CoinsLabel
@onready var items_container = $ShopPanel/VBoxContainer/ItemsContainer

var shop_items: Array[Dictionary] = []

signal item_purchased(item_id: String)

func _ready():
	load_shop_items()
	shop_panel.visible = false

func load_shop_items():
	shop_items = [
		{
			"id": "potion_health",
			"name": "Poção de Vida",
			"description": "Restaura 1 vida",
			"price": 50,
			"icon": "potion"
		},
		{
			"id": "potion_extra_life",
			"name": "Vida Extra",
			"description": "Adiciona 1 vida permanente",
			"price": 100,
			"icon": "life"
		},
		{
			"id": "armor_basic",
			"name": "Armadura Básica",
			"description": "Reduz dano em 25%",
			"price": 200,
			"icon": "armor"
		},
		{
			"id": "upgrade_speed",
			"name": "Upgrade de Velocidade",
			"description": "Aumenta velocidade em 20%",
			"price": 150,
			"icon": "speed"
		},
		{
			"id": "upgrade_jump",
			"name": "Upgrade de Pulo",
			"description": "Aumenta altura do pulo em 20%",
			"price": 150,
			"icon": "jump"
		}
	]

func show_shop():
	shop_panel.visible = true
	update_shop_ui()
	get_tree().paused = true

func hide_shop():
	shop_panel.visible = false
	get_tree().paused = false

func update_shop_ui():
	if coins_label and UserDataManager:
		coins_label.text = "Moedas: " + str(UserDataManager.get_user_coins())
	
	# Atualizar itens da loja
	# (implementar criação de botões de itens)

func purchase_item(item_id: String) -> bool:
	var item = null
	for shop_item in shop_items:
		if shop_item.id == item_id:
			item = shop_item
			break
	
	if not item:
		return false
	
	if UserDataManager and UserDataManager.spend_coins(item.price):
		item_purchased.emit(item_id)
		update_shop_ui()
		return true
	return false




