extends Control


# References to UI elements and a scene for the building UI system
@export var buildingSpawnButtonScene: PackedScene
@export var buildingPanel: Control
@export var buildingPanelOpenButton: Control
@export var buildingSpawnButtonParent: Control


# Called when the node enters the scene tree for the first time.
func _ready():
	ToggleBuildingPanel(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Called when the building button is pressed to open the building panel
func _on_building_panel_button_pressed():
	ToggleBuildingPanel(true)


# Called when the close button is pressed to close the building panel
func _on_close_button_pressed():
	ToggleBuildingPanel(false)


# Used to open/close the building panel
func ToggleBuildingPanel(open: bool):
	if open:
		buildingPanel.show()
		buildingPanelOpenButton.hide()
		SetupBuildingSpawnButtons()
	else:
		buildingPanel.hide()
		buildingPanelOpenButton.show()


# Used to setup the building buttons within the building list
func SetupBuildingSpawnButtons():
	# Destroy any pre-existing building buttons
	for child in buildingSpawnButtonParent.get_children():
		child.queue_free()
	
	# Get the main node
	var mainNode = get_node("/root/Main")
	
	# Spawn a building button for each building resource the main node has
	for building in mainNode.buildings:
		var newBuildingSpawnButton = buildingSpawnButtonScene.instantiate()
		newBuildingSpawnButton.Setup(building)
		buildingSpawnButtonParent.add_child(newBuildingSpawnButton)
