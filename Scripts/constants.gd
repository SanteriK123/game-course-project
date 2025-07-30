extends Node

const TILE_SIZE = 16

# Dungeon tile atlas (only walls and floors)
const DUNGEON_TILES = {
	Walls = {
		Wall1 = Vector2(0, 2),
		Wall2 = Vector2(1, 2),
		Wall3 = Vector2(2, 2),
		Wall4 = Vector2(3, 2),
	},
	Floors = {
		Floor1 = Vector2(0, 3),
		Floor2 = Vector2(1, 3),
		Floor3 = Vector2(2, 3),
	}
}

# Floor tile weights for dungeon generation
const DUNGEON_FLOOR_WEIGHTS = {
	DUNGEON_TILES.Floors.Floor1: 50,
	DUNGEON_TILES.Floors.Floor2: 2,
	DUNGEON_TILES.Floors.Floor3: 48
}

# Wall tile weights for dungeon generation
const DUNGEON_WALL_WEIGHTS = {
	DUNGEON_TILES.Walls.Wall1: 50,
	DUNGEON_TILES.Walls.Wall2: 2,
	DUNGEON_TILES.Walls.Wall3: 20,
	DUNGEON_TILES.Walls.Wall4: 28
}

# Tiles for surface generation
const SURFACE_TILES = {
	Grass = Vector2i(0, 0),
	Grass2 = Vector2i(3, 1),
	GrassRoses = Vector2i(1, 0),
	GrassRoses2  = Vector2i(2, 0),
	GrassStone = Vector2i(3, 0),
	GrassStone2 = Vector2i(0, 1),
	Basic = Vector2i(1, 1),
	Bush = Vector2i(3, 3)
}
