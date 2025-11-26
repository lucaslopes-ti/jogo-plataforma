extends Node

# Sistema de conquistas

signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

var achievements: Dictionary = {}

func _ready():
	load_achievements()

func load_achievements():
	# Conquistas baseadas em estatísticas
	achievements = {
		"first_question": {
			"name": "Primeira Pergunta",
			"description": "Responda sua primeira pergunta",
			"icon": "question",
			"reward_coins": 10
		},
		"perfect_score": {
			"name": "Pontuação Perfeita",
			"description": "Acertar 10 perguntas consecutivas",
			"icon": "star",
			"reward_coins": 50
		},
		"level_5": {
			"name": "Nível 5",
			"description": "Alcance o nível 5",
			"icon": "level",
			"reward_coins": 100
		},
		"coin_collector": {
			"name": "Colecionador",
			"description": "Colete 100 moedas",
			"icon": "coin",
			"reward_coins": 25
		},
		"math_master": {
			"name": "Mestre da Matemática",
			"description": "Acertar 50 perguntas de matemática",
			"icon": "math",
			"reward_coins": 75
		},
		"physics_expert": {
			"name": "Especialista em Física",
			"description": "Acertar 50 perguntas de física",
			"icon": "physics",
			"reward_coins": 75
		},
		"code_wizard": {
			"name": "Mago do Código",
			"description": "Acertar 50 perguntas de computação",
			"icon": "code",
			"reward_coins": 75
		}
	}

func check_achievements():
	if not UserDataManager:
		return
	
	var stats = UserDataManager.current_user.get("statistics", {})
	
	# Verificar conquistas
	if stats.get("total_questions", 0) >= 1:
		unlock_achievement("first_question")
	
	if stats.get("correct_answers", 0) >= 10:
		unlock_achievement("perfect_score")
	
	if UserDataManager.get_user_level() >= 5:
		unlock_achievement("level_5")
	
	# Verificar moedas coletadas (precisa rastrear isso)
	# Verificar por categoria de perguntas

func unlock_achievement(achievement_id: String):
	if achievement_id in achievements:
		var unlocked = UserDataManager.unlock_achievement(achievement_id)
		if unlocked:
			var achievement = achievements[achievement_id]
			if UserDataManager:
				UserDataManager.add_coins(achievement.reward_coins)
			achievement_unlocked.emit(achievement_id, achievement)

