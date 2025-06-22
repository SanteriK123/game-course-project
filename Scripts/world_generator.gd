extends Node

@export var tree_1_scene: PackedScene
@export var tree_2_scene: PackedScene
@export var tree_3_scene: PackedScene

@onready var tileMap = $TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tileMap.clear()
	for y in range(-40, 41):
		for x in range(-40, 41):
			var noise = FastNoiseLite.new()
			noise.frequency = 5.0
			var noise_val = noise.get_noise_2d(x / 40.0, y / 40.0)
			if noise_val > 0.3:
				#var tree = generateTree()
				#tree.position = Vector2((x * 16)+ randi_range(0, 3), (y * 16) + randi_range(0, 3))
				#add_child(tree)
				tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.Basic)
			elif noise_val > 0.2:
				if randf() > 0.5:
					tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.GrassStone)
				else:
					tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.GrassStone2)
			elif noise_val > 0.1:
				tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.GrassRoses2)
			elif noise_val > 0.0:
				tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.GrassRoses)
			else:
				if randf() > 0.5:
					tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.Grass)
				else:
					tileMap.set_cell(Vector2i(x, y), tileMap.tile_set.get_source_id(0), Constants.TILE_ATLAS.Grass2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generateTree():
	var tree = tree_1_scene.instantiate()
	var rand = randf()
	if rand > 0.66:
		tree = tree_2_scene.instantiate()
	elif rand > 0.33:
		tree = tree_2_scene.instantiate()
	else:
		return tree
	return tree
