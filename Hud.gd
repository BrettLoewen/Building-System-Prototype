extends Control


# References to UI elements and a scene for the building UI system
@export var buildingSpawnButtonScene: PackedScene
@export var buildingPanel: Control
@export var buildingPanelOpenButton: Control
@export var buildingSpawnButtonParent: Control
@export var buildingPrompt: Control

var mainNode


# Called when the node enters the scene tree for the first time.
func _ready():
	UpdateBuildingPanel(Constants.GameState.TOWN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Called when the building button is pressed to open the building panel
func _on_building_panel_button_pressed():
	UpdateBuildingPanel(Constants.GameState.BUILD_MENU)


# Called when the close button is pressed to close the building panel
func _on_close_button_pressed():
	UpdateBuildingPanel(Constants.GameState.TOWN)


# Used to update the game state regarding the building panel
func UpdateBuildingPanel(newGameState: Constants.GameState):
	# Ensure the new game state is stored
	if mainNode == null:
		mainNode = get_node("/root/Main")
	mainNode.gameState = newGameState
	
	# Turn on/off UI elements according to the new game state
	if newGameState == Constants.GameState.BUILD_MENU:
		buildingPanel.show()
		buildingPanelOpenButton.hide()
		buildingPrompt.hide()
		SetupBuildingSpawnButtons()
	elif newGameState == Constants.GameState.TOWN:
		buildingPanel.hide()
		buildingPanelOpenButton.show()
		buildingPrompt.hide()
	elif newGameState == Constants.GameState.BUILD_PLACE:
		buildingPanel.hide()
		buildingPanelOpenButton.hide()
		buildingPrompt.show()


# Used to setup the building buttons within the building list
func SetupBuildingSpawnButtons():
	# Destroy any pre-existing building buttons
	for child in buildingSpawnButtonParent.get_children():
		child.queue_free()
	
	# Get the main node
	if mainNode == null:
		mainNode = get_node("/root/Main")
	
	# Spawn a building button for each building resource the main node has
	for building in mainNode.buildings:
		var newBuildingSpawnButton = buildingSpawnButtonScene.instantiate()
		newBuildingSpawnButton.Setup(building, OnClickBuildingButton)
		buildingSpawnButtonParent.add_child(newBuildingSpawnButton)


# Passed to building buttons and they call it when they get pressed
func OnClickBuildingButton(buildingData: Resource):
	if mainNode == null:
		mainNode = get_node("/root/Main")
	
	# Spawn the building
	mainNode.StartSpawningBuilding(buildingData)
