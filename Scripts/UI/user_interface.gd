extends CanvasLayer

# Nodes
@onready var game_ref = get_node("/root/Game")
@onready var level_label = $HBoxContainer/Level
@onready var level_cleared_text = $LevelCleared

func _ready() -> void:
	game_ref.level_finished.connect(_on_level_finished)
	game_ref.all_enemies_killed.connect(_on_all_enemies_killed)

func _on_level_finished() -> void:
	level_label.text = "Level: " + str(game_ref.level)
	level_cleared_text.visible = false

func _on_all_enemies_killed() -> void:
	level_cleared_text.visible = true
