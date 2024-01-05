extends ColorRect


# Track different information for controlling the scroll
var mouse_button_down = false
var scroll_container


func _ready():
	scroll_container = $ScrollContainer


# Called when the mouse is over the scroll container
func _on_ScrollContainer_gui_input(event):
	# Record when the left mouse button is down over this UI element
	if (event is InputEventMouseButton and event.button_index == 1):
		mouse_button_down = event.pressed;
	# If the mouse button is down and moving, scroll the container
	if (event is InputEventMouseMotion and mouse_button_down):
		scroll_container.scroll_horizontal -= event.relative.x
	# Also scrolling the container, just under a different input type
	if (event is InputEventScreenDrag):
		scroll_container.scroll_horizontal -= event.relative.x
