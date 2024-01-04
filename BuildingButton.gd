extends Button


# Used to display the name of the building data for this button
@export var label: Label

# Used to store the building data for this button
var data: Resource


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Called from Hud.gd when spawning building buttons
# Used to setup and store values needed for this button
func Setup(buildingData: Resource):
	data = buildingData
	label.set_text(data.buildingName)
