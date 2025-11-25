extends CanvasLayer

@onready var score_label = $UI/ScoreLabel
@onready var lives_label = $UI/LivesLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var restart_button = $UI/GameOverPanel/RestartButton

var score = 0
var lives = 3

func _ready():
	update_ui()
	game_over_panel.visible = false
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)

func update_ui():
	if score_label:
		score_label.text = "Pontos: " + str(score)
	if lives_label:
		lives_label.text = "Vidas: " + str(lives)

func add_score(points: int):
	score += points
	update_ui()

func lose_life():
	lives -= 1
	update_ui()
	if lives <= 0:
		show_game_over()
		return true
	return false

func show_game_over():
	game_over_panel.visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

