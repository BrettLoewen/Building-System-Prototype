extends Node2D


@export var lines: Array[Sprite2D]

var gridPos: Vector2i


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func Setup(pos: Vector2, tileGridPos: Vector2i):
	position = pos
	z_index = tileGridPos.x + tileGridPos.y
	gridPos = tileGridPos


func SetupLines(tiles: Dictionary):
	SetupLine(tiles, Vector2i(0, 1), 0)
	SetupLine(tiles, Vector2i(1, 0), 1)
	SetupLine(tiles, Vector2i(-1, 0), 2)
	SetupLine(tiles, Vector2i(0, -1), 3)

func SetupLine(tiles: Dictionary, offset: Vector2i, lineIndex: int):
	if tiles.has(gridPos + offset):
		lines[lineIndex].modulate = Color(0, 0, 0, 0)
	else:
		lines[lineIndex].modulate = Color(0, 0, 0, 100)
