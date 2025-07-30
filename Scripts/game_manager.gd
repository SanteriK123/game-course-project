extends Node

# Scenes to be generated from code
@export var swamp_monster_scene: PackedScene
@export var rat_scene: PackedScene
@export var giant_rat_scene: PackedScene
@export var boss_scene: PackedScene
@export var stairs_scene: PackedScene

# Nodes
@onready var tile_map = $TileMapLayer
@onready var player = $Player
@onready var audio_stream = $AudioStreamPlayer
@onready var time = $UserInterface/HBoxContainer/Time

# Level variables
var level: int = 1
var steps: int = 100
var world_size: int = 40
var stairs: Node = null

# Lists
var enemies = []
var floor_positions = []

# Music
var sewer_music = preload("res://Assets/Music/sewergaming.ogg")
var boss_music = preload("res://Assets/Music/sewerboss.ogg")

# Signals
signal level_finished
signal all_enemies_killed

func _ready() -> void:
	audio_stream.stream = sewer_music
	audio_stream.play()
	generate_sewer_level(steps, 1)
					
func _process(delta: float) -> void:
	# Stupid emit signal, better ways to do this but im too lazy
	if enemies.size() <= 0:
		emit_signal("all_enemies_killed")

func pick_weighted_tile(tile_type: String) -> Vector2:
	var weights = Constants.SURFACE_TILES
	if tile_type == "dungeon_floors":
		weights = Constants.DUNGEON_FLOOR_WEIGHTS
	elif tile_type == "dungeon_walls":
		weights = Constants.DUNGEON_WALL_WEIGHTS

	# Github copilot helped with this function
	var total_weight = 0
	for weight in weights.values():
		total_weight += weight
	var pick = randi() % total_weight
	var cumulative = 0
	for tile in weights.keys():
		cumulative += weights[tile]
		if pick < cumulative:
			return tile
	return weights.keys()[0]

func generate_sewer_level(steps: int, dir_change_chance: float) -> void:
	var border = 25
	var enemy_spawned = false

	# Fill with walls, add a bit of extra (border) so level wont generate on edge
	for y in range(-border, world_size + border):
		for x in range(-border, world_size + border):
			tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), pick_weighted_tile("dungeon_walls"))
	
	# This is my implementation of drunkard's walk, so pick a random direction and walk
	# which is very easy way to generate traversable procedurally generated maps
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var pos = Vector2i(world_size / 2, world_size / 2)
	var start_pos = pos
	var dir = directions[randi_range(0, directions.size() - 1)]

	# Walk in a square of size 2 or 4, just to make enough path for player and enemies to move
	for i in range(steps):
		var block_size = randi_range(2, 4) # Random block size between 2 and 4
		for x in range(block_size):
			for y in range(block_size):
				var walk_pos = pos + Vector2i(x, y)
				tile_map.set_cell(walk_pos, tile_map.tile_set.get_source_id(0), pick_weighted_tile("dungeon_floors"))
				floor_positions.append(walk_pos)
				# Spawn enemies on a random floor, increasing every level
				var enemy_spawn_chance = level * 0.001
				var enemy: Enemy
				if randf() < enemy_spawn_chance:
					enemy = rat_scene.instantiate()
					if randf() >= 0.9:
						enemy = giant_rat_scene.instantiate()
					if randf() >= 0.7 && level >= 3:
						enemy = swamp_monster_scene.instantiate()
					enemy.position = (pos * Constants.TILE_SIZE) + Vector2i(Constants.TILE_SIZE / 2, Constants.TILE_SIZE / 2)
					enemy.enemy_dead.connect(_on_enemy_dead.bind(enemy))
					enemies.append(enemy)
					add_child(enemy)
					
		# Pick a random direction and move
		if (dir_change_chance >= randf()):
			dir = directions[randi() % directions.size()]
		pos += dir

		# Stay within bounds
		pos.x = clamp(pos.x, 0, world_size - 2)
		pos.y = clamp(pos.y, 0, world_size - 2)
	
	# Make sure at least one enemy is spawned
	if !enemy_spawned and floor_positions.size() > 0:
		var spawn_pos = floor_positions[randi() % floor_positions.size()]
		var enemy = rat_scene.instantiate()
		enemy.position = (spawn_pos * Constants.TILE_SIZE) + Vector2i(Constants.TILE_SIZE / 2, Constants.TILE_SIZE / 2)
		enemy.enemy_dead.connect(_on_enemy_dead.bind(enemy))
		enemies.append(enemy)
		add_child(enemy)
		enemy_spawned = true
	# Place player in the middle of the level
	player.position = start_pos * Constants.TILE_SIZE + Vector2i(8, 8) # Offset to center player
	place_stairs_and_floor()

func place_stairs_and_floor():
	var border_square = Vector2i(8, 8)
	var offset = Vector2i(-2, -2)

	# Pick any random floor tile as place to put stairs
	var stairs_pos = floor_positions[randi() % floor_positions.size()]

	# Place floors around stairs to make space 
	for x in range(border_square.x):
		for y in range(border_square.y):
			var floor_pos = stairs_pos + offset + Vector2i(x, y)
			tile_map.set_cell(floor_pos, tile_map.tile_set.get_source_id(0), pick_weighted_tile("dungeon_floors"))

	# Place the stairs at stairs_pos
	stairs = stairs_scene.instantiate()
	stairs.position = stairs_pos * Constants.TILE_SIZE
	stairs.player_tried_exiting_level.connect(_on_player_tried_exiting_level)
	add_child(stairs)

func _on_player_tried_exiting_level():
	if enemies.size() == 0:
		level += 1
		emit_signal("level_finished")
		call_deferred("regenerate_sewer_level")
	else:
		print("Kill all enemies!")
		
func regenerate_sewer_level():
	# Clear old enemies
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	floor_positions.clear()
	tile_map.clear()
	stairs.queue_free()

	# Generate new level
	if (level >= 5):
		# Level 5 is boss fight
		generate_surface_level()
	else:
		# Increase difficulty on level 3
		if level >= 3:
			world_size + 20
			world_size + 20
		generate_sewer_level(level * steps, randf())

func generate_surface_level():
	player.position = Vector2i(64, 64)
	
	audio_stream.stop()
	audio_stream.stream = boss_music
	audio_stream.play()
	# Create boss and spawn him in the middle
	var boss = boss_scene.instantiate()
	boss.add_to_group("boss")
	boss.position = Vector2i(world_size * Constants.TILE_SIZE / 2, world_size * Constants.TILE_SIZE / 2)
	boss.enemy_dead.connect(_on_enemy_dead.bind(boss))
	enemies.append(boss)
	add_child(boss)
	
	# Place bushes around map to block escape
	var border = 20
	for y in range(-border, world_size + border):
		for x in range(-border, world_size + border):
			tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.Bush)
			
	# use fastnoise for some noice placements of roses etc
	for y in range(0, world_size):
		for x in range(0, world_size):
			var noise = FastNoiseLite.new()
			noise.frequency = 5.0
			var noise_val = noise.get_noise_2d(x / 40.0, y / 40.0)
			if noise_val > 0.3:
				tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.Basic)
			elif noise_val > 0.2:
				if randf() > 0.5:
					tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.GrassStone)
				else:
					tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.GrassStone2)
			elif noise_val > 0.1:
				tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.GrassRoses2)
			elif noise_val > 0.0:
				tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.GrassRoses)
			else:
				if randf() > 0.5:
					tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.Grass)
				else:
					tile_map.set_cell(Vector2i(x, y), tile_map.tile_set.get_source_id(0), Constants.SURFACE_TILES.Grass2)

func _on_enemy_dead(enemy: Enemy) -> void:
	if enemy in enemies:
		if enemy.is_in_group("boss"):
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
			var previous_best = load_from_file()
			if previous_best > float(time.text):
				save_to_file(time.text)
		enemies.erase(enemy)

func save_to_file(content: String) -> void:
	var file = FileAccess.open("user://best_time.dat", FileAccess.WRITE)
	file.store_string(content)
	
func load_from_file() -> float:
	if not FileAccess.file_exists("user://best_time.dat"):
		return 0
	var file = FileAccess.open("user://best_time.dat", FileAccess.READ)
	var content = file.get_as_text()
	return float(content)
