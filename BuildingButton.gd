extends Button


# Used to display the name of the building data for this button
@export var label: Label

var data: Resource				# Used to store the building data for this button
var onClickCallback: Callable	# Called when the button is pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Called from Hud.gd when spawning building buttons
# Used to setup and store values needed for this button
func Setup(buildingData: Resource, onClick: Callable):
	data = buildingData
	label.set_text(data.buildingName)
	onClickCallback = onClick


# Called when the button is pressed
func _on_pressed():
	# Call the passed callback from when this button was setup
	if onClickCallback != null:
		onClickCallback.call(data)
