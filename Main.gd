extends Node2D


@export var tileScene: PackedScene			# Defines the tile that will be spawned
@export var gridSize := Vector2i(6, 6)		# Defines how many tiles will be spawned
@export var tileSize := Vector2i(56, 42)	# Defines how much space a tile takes up

# Stores references to all of the tiles
var tiles: Dictionary

# The Node that the tiles should be spawned as children of
@export var tileParent: Node2D

# Variables for tracking the selected tile (the tile the player's mouse is currently over)
var selectedTileQueue: Array[Node2D]
var selectedTile


# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnTiles()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If a new tile should be selected
	if selectedTileQueue.size() > 0 && selectedTile != selectedTileQueue[0]:
		# Deselect the previous tile
		if selectedTile != null:
			selectedTile.DeselectTile()
		
		# Select the new tile
		selectedTile = selectedTileQueue[0]
		selectedTile.SelectTile()
	# If no tile should be selected right now, then make sure none are
	elif selectedTileQueue.size() == 0:
		if selectedTile != null:
			selectedTile.DeselectTile()
			selectedTile = null


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
	
	# Now that the tiles have all been created, we can accurately determine which ones are edge tiles
	for key in tiles:
		var tile = tiles[key]
		tile.SetupLines(tiles)


# Used to add tiles to the selected tile queue so they can be selected as needed
func EnqueueTileForSelection(tileToEnqueue):
	selectedTileQueue.push_back(tileToEnqueue)


# Used to remove tiles from the selected tile queue so the next tile can be selected
func DequeueTileFromSelection(tileToDequeue):
	# The tile might not be the first tile in the queue, so we need to find it and then remove it
	selectedTileQueue.remove_at(selectedTileQueue.find(tileToDequeue))
