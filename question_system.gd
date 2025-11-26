extends Node

# Sistema de perguntas para MathQuest
signal question_answered(correct: bool)
signal question_completed

var current_question: Dictionary = {}
var current_attempts: int = 0
var max_attempts: int = 2
var questions_answered: int = 0
var questions_correct: int = 0
var used_questions: Array[Dictionary] = []  # Rastrear perguntas já usadas nesta sessão

# Banco de perguntas
var question_bank: Array[Dictionary] = []

func _ready():
	load_questions()

func load_questions():
	# Matemática
	question_bank.append({
		"question": "Qual é o resultado de 15 + 27?",
		"options": ["40", "42", "44", "45"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a raiz quadrada de 64?",
		"options": ["6", "7", "8", "9"],
		"correct": 2,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é o valor de 3² × 2³?",
		"options": ["48", "54", "72", "81"],
		"correct": 2,
		"category": "matematica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual é a derivada de x²?",
		"options": ["x", "2x", "x²", "2x²"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 3
	})
	
	question_bank.append({
		"question": "Qual é o resultado de 100 ÷ 4?",
		"options": ["20", "25", "30", "40"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 1
	})
	
	# Física
	question_bank.append({
		"question": "Qual é a fórmula da velocidade?",
		"options": ["v = d/t", "v = t/d", "v = d×t", "v = d²/t"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a aceleração da gravidade na Terra (aproximadamente)?",
		"options": ["9.8 m/s²", "10 m/s²", "8.9 m/s²", "11 m/s²"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a fórmula da energia cinética?",
		"options": ["E = mv", "E = mv²", "E = ½mv²", "E = m²v"],
		"correct": 2,
		"category": "fisica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é força?",
		"options": ["m × v", "m × a", "v × t", "d × t"],
		"correct": 1,
		"category": "fisica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a unidade de medida da força?",
		"options": ["Joule", "Watt", "Newton", "Pascal"],
		"correct": 2,
		"category": "fisica",
		"difficulty": 1
	})
	
	# Computação
	question_bank.append({
		"question": "O que significa CPU?",
		"options": ["Central Processing Unit", "Computer Processing Unit", "Central Program Unit", "Computer Program Unit"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a complexidade de tempo de uma busca binária?",
		"options": ["O(n)", "O(log n)", "O(n²)", "O(1)"],
		"correct": 1,
		"category": "computacao",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é um algoritmo?",
		"options": ["Um programa", "Uma sequência de passos para resolver um problema", "Uma linguagem de programação", "Um compilador"],
		"correct": 1,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual estrutura de dados é LIFO (Last In First Out)?",
		"options": ["Fila", "Pilha", "Lista", "Árvore"],
		"correct": 1,
		"category": "computacao",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é RAM?",
		"options": ["Random Access Memory", "Read Access Memory", "Random Algorithm Memory", "Read Algorithm Memory"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a base do sistema binário?",
		"options": ["8", "10", "2", "16"],
		"correct": 2,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "O que é um loop infinito?",
		"options": ["Um loop que nunca termina", "Um loop muito rápido", "Um loop com muitas iterações", "Um loop que executa uma vez"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a complexidade de tempo de um algoritmo de ordenação bubble sort?",
		"options": ["O(n)", "O(n log n)", "O(n²)", "O(log n)"],
		"correct": 2,
		"category": "computacao",
		"difficulty": 2
	})
	
	# Mais perguntas de Matemática
	question_bank.append({
		"question": "Qual é o resultado de 7 × 8?",
		"options": ["54", "56", "58", "60"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é o valor de π (pi) aproximado?",
		"options": ["3.14", "3.15", "3.16", "3.17"],
		"correct": 0,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é o resultado de 144 ÷ 12?",
		"options": ["10", "11", "12", "13"],
		"correct": 2,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a área de um quadrado com lado 5?",
		"options": ["20", "25", "30", "35"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é o resultado de 2³ + 3²?",
		"options": ["15", "17", "19", "21"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual é a raiz quadrada de 144?",
		"options": ["10", "11", "12", "13"],
		"correct": 2,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é o resultado de 5! (fatorial de 5)?",
		"options": ["100", "120", "140", "160"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual é a fórmula da área de um círculo?",
		"options": ["πr", "πr²", "2πr", "πr³"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual é o resultado de 9 × 6?",
		"options": ["52", "54", "56", "58"],
		"correct": 1,
		"category": "matematica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a integral de x?",
		"options": ["x", "x²", "x²/2", "2x"],
		"correct": 2,
		"category": "matematica",
		"difficulty": 3
	})
	
	# Mais perguntas de Física
	question_bank.append({
		"question": "Qual é a fórmula da energia potencial gravitacional?",
		"options": ["mgh", "mv²", "½mv²", "Fd"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é aceleração?",
		"options": ["Mudança de velocidade", "Mudança de posição", "Mudança de massa", "Mudança de força"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a velocidade da luz no vácuo?",
		"options": ["300.000 km/s", "150.000 km/s", "450.000 km/s", "600.000 km/s"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é inércia?",
		"options": ["Resistência à mudança de movimento", "Força aplicada", "Velocidade constante", "Aceleração"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual é a primeira lei de Newton?",
		"options": ["Lei da Inércia", "F = ma", "Ação e Reação", "Lei da Gravitação"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual é a unidade de medida da energia?",
		"options": ["Joule", "Watt", "Newton", "Pascal"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "O que é trabalho em física?",
		"options": ["Força × distância", "Massa × velocidade", "Energia × tempo", "Potência × tempo"],
		"correct": 0,
		"category": "fisica",
		"difficulty": 2
	})
	
	# Mais perguntas de Computação
	question_bank.append({
		"question": "O que é uma variável em programação?",
		"options": ["Um valor fixo", "Um espaço de memória que armazena dados", "Uma função", "Um loop"],
		"correct": 1,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a complexidade de tempo de um algoritmo de ordenação quicksort (médio caso)?",
		"options": ["O(n)", "O(n log n)", "O(n²)", "O(log n)"],
		"correct": 1,
		"category": "computacao",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é uma função recursiva?",
		"options": ["Uma função que chama a si mesma", "Uma função muito rápida", "Uma função sem parâmetros", "Uma função que retorna void"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "Qual estrutura de dados é FIFO (First In First Out)?",
		"options": ["Pilha", "Fila", "Lista", "Árvore"],
		"correct": 1,
		"category": "computacao",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é um array?",
		"options": ["Uma coleção ordenada de elementos", "Uma função", "Um loop", "Uma condição"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a complexidade de tempo de acesso a um elemento em um array?",
		"options": ["O(n)", "O(log n)", "O(1)", "O(n²)"],
		"correct": 2,
		"category": "computacao",
		"difficulty": 2
	})
	
	question_bank.append({
		"question": "O que é um ponteiro?",
		"options": ["Uma variável que armazena um endereço de memória", "Um tipo de loop", "Uma função", "Um operador"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 3
	})
	
	question_bank.append({
		"question": "O que significa HTML?",
		"options": ["HyperText Markup Language", "High Tech Modern Language", "HyperText Modern Language", "High Tech Markup Language"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "O que é um banco de dados?",
		"options": ["Sistema de armazenamento organizado de dados", "Um programa", "Uma linguagem", "Um algoritmo"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 1
	})
	
	question_bank.append({
		"question": "Qual é a complexidade de tempo de uma busca linear?",
		"options": ["O(n)", "O(log n)", "O(1)", "O(n²)"],
		"correct": 0,
		"category": "computacao",
		"difficulty": 2
	})

func get_random_question(difficulty: int = 0, category: String = ""):
	var available_questions = question_bank.duplicate()
	
	# Filtrar por categoria se especificada
	if category != "":
		available_questions = available_questions.filter(func(q): return q.category == category)
	
	# Filtrar por dificuldade se especificada
	if difficulty > 0:
		available_questions = available_questions.filter(func(q): return q.difficulty == difficulty)
	
	# Remover perguntas já usadas (comparar pelo texto da pergunta)
	available_questions = available_questions.filter(func(q): 
		for used in used_questions:
			if used.get("question", "") == q.get("question", ""):
				return false
		return true
	)
	
	# Se não há perguntas disponíveis, resetar lista de usadas
	if available_questions.is_empty():
		used_questions.clear()
		available_questions = question_bank.duplicate()
		if category != "":
			available_questions = available_questions.filter(func(q): return q.category == category)
		if difficulty > 0:
			available_questions = available_questions.filter(func(q): return q.difficulty == difficulty)
	
	# Selecionar pergunta aleatória
	var random_index = randi() % available_questions.size()
	current_question = available_questions[random_index].duplicate()
	
	# Adicionar à lista de perguntas usadas
	used_questions.append(current_question.duplicate())
	
	current_attempts = 0
	
	return current_question

func answer_question(option_index: int) -> bool:
	current_attempts += 1
	var correct = (option_index == current_question.correct)
	
	if correct:
		questions_correct += 1
		questions_answered += 1
		question_answered.emit(true)
		question_completed.emit()
		return true
	else:
		if current_attempts >= max_attempts:
			questions_answered += 1
			question_answered.emit(false)
			question_completed.emit()
			return false
		else:
			# Ainda tem tentativas
			question_answered.emit(false)
			return false

func get_remaining_attempts() -> int:
	return max_attempts - current_attempts

func reset_progress():
	questions_answered = 0
	questions_correct = 0
	current_question = {}
	current_attempts = 0

