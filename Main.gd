extends Node2D


# The current state of the game
var gameState: Constants.GameState

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
var selectedTileGridPos: Vector2i

@export var buildings: Array[Resource]	# Defines the buildings that will appear in the building menu
var selectedBuilding					# References the currently selected building
@export var buildingParent: Node2D		# The node the buildings will be spawned under
var movingBuilding: bool				# True if a building is being moved, false otherwise

# References the UI control node to call functions on it
@export var hudNode: Control


# Called when the node enters the scene tree for the first time.
func _ready():
	gameState = Constants.GameState.TOWN
	SpawnTiles()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Determines the currently selected tile
	SelectTileHandler()
	# Moves the selected building and places it
	# Handles selected an already placed building so it can be moved
	PlaceBuildingHandler()


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


# Spawn the building and then update the UI and game state
func StartSpawningBuilding(buildingData: Resource):
	# Spawn the building and store a reference to it
	var newBuilding = buildingData.buildingScene.instantiate()
	buildingParent.add_child(newBuilding)
	selectedBuilding = newBuilding
	selectedBuilding.SetLineColorValid()
	selectedBuilding.buildingData = buildingData
	
	# Update the UI and the game state
	hudNode.UpdateBuildingPanel(Constants.GameState.BUILD_PLACE)


# The logic for selecting tiles and displaying the selection highlights
func SelectTileHandler():
	# If a new tile should be selected
	if selectedTileQueue.size() > 0 && selectedTile != selectedTileQueue[0]:
		# Deselect the previous tile
		if selectedTile != null:
			if selectedTile.building == null:
				selectedTile.DeselectTile()
			else:
				selectedTile.building.SetLineColorDeselected()
		
		# Select the new tile
		selectedTile = selectedTileQueue[0]
		
		# Show the selected highlights
		# Only show the highlights for the tile if a building is not currently selected
		if selectedBuilding == null:
			if selectedTile.building == null:
				selectedTile.SelectTile()
			else:
				selectedTile.building.SetLineColorSelected()
	# If no tile should be selected right now, then make sure none are
	elif selectedTileQueue.size() == 0:
		if selectedTile != null:
			if selectedTile.building == null:
				selectedTile.DeselectTile()
			else:
				selectedTile.building.SetLineColorDeselected()
			selectedTile = null


# The logic for moving buildings, validating positions, and placing buildings
func PlaceBuildingHandler():
	# If the game is in the place building state
	if gameState == Constants.GameState.BUILD_PLACE:
		# Move the building to the currently selected tile
		if selectedBuilding != null and selectedTile != null:
			selectedBuilding.position = selectedTile.position
			selectedTileGridPos = selectedTile.gridPos
		# If there is not currently a selected tile, move the building to the 0,0 tile
		elif selectedBuilding != null and selectedTile == null:
			selectedBuilding.position = Vector2i(0, 0)
			selectedTileGridPos = Vector2i(0, 0)
		
		# Calculate the tiles this building occupies in this position
		
		# Define some variables for this calculation
		var positionValid = true
		var size = selectedBuilding.buildingData.size
		var buildingTiles = Array()
		
		# Check every tile that this building would cover and get the tiles if they exist
		for x in range(size.y):
			for y in range(size.x):
				var tileValid = tiles.has(Vector2i(selectedTileGridPos.x + x, selectedTileGridPos.y + y))
				# If the tile does not exist, this position is invalid
				if tileValid == false:
					positionValid = false
				# If the tile does exist, get it and store it
				else:
					var tile = tiles[Vector2i(selectedTileGridPos.x + x, selectedTileGridPos.y + y)]
					buildingTiles.append(tile)
		
		# If no tiles are missing, check if any tiles already have a building on them
		if positionValid == true:
			for tile in buildingTiles:
				# If the tile has a building on it already, this position is invalid
				if tile.building != null:
					positionValid = false
		
		# Set the buidling's highlight according to whether this position is valid or not
		if positionValid == true:
			selectedBuilding.SetLineColorValid()
		else:
			selectedBuilding.SetLineColorInvalid()
		
		# If the player clicked to place the building
		if positionValid == true and Input.is_action_just_pressed("place_building"):
			# Update the UI, game state, and highlights
			hudNode.UpdateBuildingPanel(Constants.GameState.TOWN)
			selectedBuilding.SetLineColorDeselected()
			
			# Setup references so the building and tiles know about each other
			selectedBuilding.tile = buildingTiles[0]
			for tile in buildingTiles:
				tile.building = selectedBuilding
			
			# Deselect the building which will leave it in place
			selectedBuilding = null
		# If the player clicked to cancel the building placement
		elif Input.is_action_just_pressed("cancel_building"):
			# If the building was being moved, reset it
			if movingBuilding == true:
				# Reset the tiles
				var buildingSize = selectedBuilding.buildingData.size
				var buildingGridPos = selectedBuilding.tile.gridPos
				for x in range(buildingSize.y):
					for y in range(buildingSize.x):
						var tileValid = tiles.has(Vector2i(buildingGridPos.x + x, buildingGridPos.y + y))
						if tileValid == true:
							var tile = tiles[Vector2i(buildingGridPos.x + x, buildingGridPos.y + y)]
							tile.building = selectedBuilding
				# Reset the building
				selectedBuilding.position = selectedBuilding.tile.position
				selectedBuilding.SetLineColorDeselected()
				movingBuilding = false
			# If the building was being placed, destroy it
			else:
				# Destroy the building
				selectedBuilding.queue_free()
			selectedBuilding = null
			# Update the UI and game state
			hudNode.UpdateBuildingPanel(Constants.GameState.TOWN)
	# Used to pick-up buildings to move them to a different place
	# If the game is in the town state
	elif gameState == Constants.GameState.TOWN:
		# If the user pressed the left mouse button
		if Input.is_action_just_pressed("place_building"):
			# If the user's mouse is currently over a tile with a building
			if selectedTile != null and selectedTile.building != null:
				selectedBuilding = selectedTile.building
				
				# Tell the tiles that this building was on that there isn't a building on them
				var size = selectedBuilding.buildingData.size
				var buildingGridPos = selectedBuilding.tile.gridPos
				for x in range(size.y):
					for y in range(size.x):
						var tileValid = tiles.has(Vector2i(buildingGridPos.x + x, buildingGridPos.y + y))
						if tileValid == true:
							var tile = tiles[Vector2i(buildingGridPos.x + x, buildingGridPos.y + y)]
							tile.building = null
				
				# Pick-up the building
				movingBuilding = true
				hudNode.UpdateBuildingPanel(Constants.GameState.BUILD_PLACE)
