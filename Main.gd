extends Node2D


@export var tileScene: PackedScene			# Defines the tile that will be spawned
@export var gridSize := Vector2i(6, 6)		# Defines how many tiles will be spawned
@export var tileSize := Vector2i(56, 42)	# Defines how much space a tile takes up

# Stores references to all of the tiles
var tiles: Dictionary

# The Node that the tiles should be spawned as children of
@export var tileParent: Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnTiles()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Called to spawn the grid of tiles
func SpawnTiles():
	# Define how much the tiles need to move in order to sit beside each other correctly
	var rightOffset = Vector2(tileSize.x/2.0, -tileSize.y/2.0)
	var leftOffset = Vector2(-tileSize.x/2.0, -tileSize.y/2.0)
	
	# Loop through the grid and spawn all the tiles
	for x in range(gridSize.x):
		for y in range(gridSize.y):
			# Use the tile's grid position and the offsets to determine this tile's position
			var tilePos = (y * leftOffset) + (x * rightOffset)
			var tileGridPos = Vector2i(x, y)
			
			# Spawn the tile and set it's position
			var newTile = tileScene.instantiate()
			newTile.Setup(tilePos, tileGridPos)
			tileParent.add_child(newTile)
			
			# Store references to the tiles for future calculations
			tiles[tileGridPos] = newTile
	
	for key in tiles:
		var tile = tiles[key]
		tile.SetupLines(tiles)
