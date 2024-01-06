extends Node


@export var lines: Array[Sprite2D]	# References to the edge lines
@export var lineParent: Node2D		# References the lines' parent node for color changing
@export var colors: Resource		# Defines the different line colors

var tile: Node2D			# The tile this building was placed on
var buildingData: Resource	# The data that defines this building


# The following line color functions set the color of the building's highlight lines
func SetLineColorValid():
	lineParent.modulate = colors.lineBuildingValidColor

func SetLineColorInvalid():
	lineParent.modulate = colors.lineBuildingInvalidColor

func SetLineColorSelected():
	lineParent.modulate = colors.lineSelectedColor

func SetLineColorDeselected():
	lineParent.modulate = colors.lineHiddenColor
