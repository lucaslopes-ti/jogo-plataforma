extends Node

# Sistema de feedback educacional explicativo

signal feedback_shown(question: Dictionary, correct: bool, explanation: String)

var explanations: Dictionary = {}

func _ready():
	load_explanations()

func load_explanations():
	# Explicações para cada pergunta
	explanations = {
		"math_addition_1": "15 + 27 = 42. Some os números: 10+20=30, 5+7=12, então 30+12=42.",
		"math_sqrt_1": "A raiz quadrada de 64 é 8, porque 8 × 8 = 64.",
		"math_power_1": "3² × 2³ = 9 × 8 = 72. Primeiro calcule as potências, depois multiplique.",
		"math_derivative_1": "A derivada de x² é 2x. Use a regra: d/dx(xⁿ) = n×xⁿ⁻¹.",
		"math_division_1": "100 ÷ 4 = 25. Divida 100 por 4.",
		"physics_velocity_1": "Velocidade = distância/tempo (v = d/t). Esta é a fórmula fundamental da velocidade.",
		"physics_gravity_1": "A aceleração da gravidade na Terra é aproximadamente 9.8 m/s². Isso significa que objetos caem acelerando a 9.8 metros por segundo a cada segundo.",
		"physics_kinetic_1": "Energia cinética = ½mv². A energia cinética depende da massa e do quadrado da velocidade.",
		"physics_force_1": "Força = massa × aceleração (F = m×a). Esta é a segunda lei de Newton.",
		"physics_force_unit_1": "A unidade de força é Newton (N), nomeada em homenagem a Isaac Newton.",
		"comp_cpu_1": "CPU significa Central Processing Unit (Unidade Central de Processamento), o 'cérebro' do computador.",
		"comp_binary_search_1": "Busca binária tem complexidade O(log n) porque divide o espaço de busca pela metade a cada iteração.",
		"comp_algorithm_1": "Um algoritmo é uma sequência finita de passos bem definidos para resolver um problema específico.",
		"comp_stack_1": "Pilha (Stack) é LIFO (Last In First Out) - o último elemento a entrar é o primeiro a sair.",
		"comp_ram_1": "RAM significa Random Access Memory (Memória de Acesso Aleatório), memória volátil do computador.",
		"comp_binary_1": "Sistema binário usa base 2, com apenas dois dígitos: 0 e 1.",
		"comp_loop_1": "Loop infinito é um loop que nunca termina, geralmente causado por erro de programação.",
		"comp_bubble_sort_1": "Bubble sort tem complexidade O(n²) porque compara cada elemento com todos os outros."
	}

func get_explanation(question: Dictionary, correct: bool) -> String:
	# Gerar explicação baseada na pergunta
	if correct:
		return "Correto! " + generate_positive_feedback(question)
	else:
		return generate_explanation(question)

func generate_positive_feedback(_question: Dictionary) -> String:
	var feedbacks = [
		"Excelente trabalho!",
		"Muito bem! Você entendeu o conceito.",
		"Perfeito! Continue assim!",
		"Correto! Você está aprendendo bem."
	]
	return feedbacks[randi() % feedbacks.size()]

func generate_explanation(question: Dictionary) -> String:
	# Tentar encontrar explicação específica
	var question_category = question.get("category", "")
	for key in explanations.keys():
		if key.contains(question_category):
			return explanations[key]
	
	# Explicação genérica baseada na categoria
	var category_explanations = {
		"matematica": "Em matemática, revise os conceitos fundamentais. Pratique mais exercícios similares.",
		"fisica": "Em física, entenda os princípios por trás das fórmulas. A física explica como o mundo funciona.",
		"computacao": "Em computação, os conceitos são fundamentais para programação. Estude estruturas de dados e algoritmos."
	}
	
	return category_explanations.get(question_category, "Revise o conceito e tente novamente!")

func show_feedback(question: Dictionary, correct: bool):
	var explanation = get_explanation(question, correct)
	feedback_shown.emit(question, correct, explanation)
