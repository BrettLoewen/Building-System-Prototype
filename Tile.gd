extends Node2D


@export var lines: Array[Sprite2D]	# References to the edge lines
@export var colors: Resource		# Defines the different line colors

# Stores the tile's position in the grid and a reference to the main node
var gridPos: Vector2i
var mainNode


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Used to setup the tile's position, order, and store its grid position
func Setup(pos: Vector2, tileGridPos: Vector2i):
	position = pos
	z_index = tileGridPos.x + tileGridPos.y
	gridPos = tileGridPos


# Used to setup the tiles' edge lines
func SetupLines(tiles: Dictionary):
	SetupLine(tiles, Vector2i(0, 1), 0)
	SetupLine(tiles, Vector2i(1, 0), 1)
	SetupLine(tiles, Vector2i(-1, 0), 2)
	SetupLine(tiles, Vector2i(0, -1), 3)


# Used to set the color and order of a line (based on the index)
func SetupLine(tiles: Dictionary, offset: Vector2i, lineIndex: int):
	# Ensure the z index is correct in case this line was previously highlighted
	lines[lineIndex].z_index = lineIndex + 1
	
	# If the tile has a neighbour on this edge, then hide the line
	if tiles.has(gridPos + offset):
		lines[lineIndex].modulate = colors.lineHiddenColor
	# If the tile does not have a neighbour on this edge, then show the line
	else:
		lines[lineIndex].modulate = colors.lineEdgeColor


# Will be called when the mouse starts hovering over this tile
func _on_mouse_detector_mouse_entered():
	# Get the main node
	mainNode = get_node("/root/Main")
	
	# Add this tile to the selection queue
	if mainNode != null:
		mainNode.EnqueueTileForSelection(self)


# Will be called when the mouse stops hovering over this tile
func _on_mouse_detector_mouse_exited():
	# Remove this tile from the selection queue
	if mainNode != null:
		mainNode.DequeueTileFromSelection(self)


# Used to highlight this tile to show it's been selected
func SelectTile():
	# Loop through the lines
	for line in lines:
		# Ensure the lines are all completely visible
		line.z_index += 1000
		
		# Highlight the line
		line.modulate = colors.lineSelectedColor


# Used to stop highlighting this tile
func DeselectTile():
	# Get the main node and re-initialize the lines to reset them
	mainNode = get_node("/root/Main")
	SetupLines(mainNode.tiles)
