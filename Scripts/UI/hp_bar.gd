extends TextureProgressBar

@onready var player = get_node("/root/Game/Player")

func _ready():
	# Connect the signal
	player.took_damage.connect(_on_player_took_damage)
	# Optionally, initialize the bar
	max_value = float(player.maxHp)
	value = float(player.hp)
	step = float(1)
	
func _on_player_took_damage():
	value = float(player.hp)
