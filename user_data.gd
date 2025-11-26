extends Node

# Sistema de gerenciamento de dados do usuário
# Salva progresso, estatísticas, avatar, etc.

signal profile_updated
signal level_up

var current_user: Dictionary = {}
var user_data_path = "user://user_data.json"

# Estrutura de dados do usuário
var default_user_data = {
	"username": "Jogador",
	"level": 1,
	"experience": 0,
	"coins": 0,
	"avatar": {
		"color": "blue",
		"accessories": []
	},
	"statistics": {
		"total_questions": 0,
		"correct_answers": 0,
		"total_playtime": 0,
		"levels_completed": 0,
		"achievements_unlocked": []
	},
	"inventory": {
		"potions": 0,
		"armor": 0,
		"upgrades": []
	},
	"settings": {
		"difficulty": 1,
		"age_range": "all",
		"school_level": "all"
	}
}

func _ready():
	load_user_data()

func create_user(username: String) -> Dictionary:
	var new_user = default_user_data.duplicate(true)
	new_user.username = username
	new_user.created_at = Time.get_unix_time_from_system()
	current_user = new_user
	save_user_data()
	return current_user

func load_user_data():
	if FileAccess.file_exists(user_data_path):
		var file = FileAccess.open(user_data_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				current_user = json.data
			else:
				current_user = default_user_data.duplicate(true)
		else:
			current_user = default_user_data.duplicate(true)
	else:
		current_user = default_user_data.duplicate(true)

func save_user_data():
	var file = FileAccess.open(user_data_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(current_user)
		file.store_string(json_string)
		file.close()
		profile_updated.emit()

func add_experience(amount: int):
	if not current_user.has("experience"):
		current_user.experience = 0
	current_user.experience += amount
	check_level_up()
	save_user_data()

func check_level_up():
	var exp_needed = current_user.level * 100
	if current_user.experience >= exp_needed:
		var old_level = current_user.level
		current_user.level += 1
		current_user.experience -= exp_needed
		level_up.emit()
		
		# Mostrar efeito de level up
		var main_scene = Engine.get_main_loop().current_scene
		if main_scene:
			var player = main_scene.get_node_or_null("Player")
			if player:
				# Carregar script de efeitos de partículas
				var particle_script = load("res://particle_effects.gd")
				if particle_script:
					particle_script.create_level_up_effect(player.global_position, main_scene)
		
		check_level_up()  # Verificar se subiu múltiplos níveis

func add_coins(amount: int):
	if not current_user.has("coins"):
		current_user.coins = 0
	current_user.coins += amount
	save_user_data()

func spend_coins(amount: int) -> bool:
	if current_user.coins >= amount:
		current_user.coins -= amount
		save_user_data()
		return true
	return false

func update_statistics(stat_name: String, value):
	if not current_user.has("statistics"):
		current_user.statistics = default_user_data.statistics.duplicate(true)
	
	if not current_user.statistics.has(stat_name):
		current_user.statistics[stat_name] = 0
	
	if stat_name == "correct_answers" or stat_name == "total_questions":
		current_user.statistics[stat_name] += value
	else:
		current_user.statistics[stat_name] = value
	
	save_user_data()

func unlock_achievement(achievement_id: String):
	if not current_user.has("statistics"):
		current_user.statistics = default_user_data.statistics.duplicate(true)
	
	if not current_user.statistics.has("achievements_unlocked"):
		current_user.statistics.achievements_unlocked = []
	
	if achievement_id not in current_user.statistics.achievements_unlocked:
		current_user.statistics.achievements_unlocked.append(achievement_id)
		save_user_data()
		return true
	return false

func get_user_level() -> int:
	return current_user.get("level", 1)

func get_user_coins() -> int:
	return current_user.get("coins", 0)

func get_user_experience() -> int:
	return current_user.get("experience", 0)
