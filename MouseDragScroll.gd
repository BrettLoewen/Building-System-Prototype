extends ColorRect


var mouse_button_down = false
var scroll_container


func _ready():
	scroll_container = $ScrollContainer


func _on_Subscription_pressed():
	print("Pressed")


func _on_ScrollContainer_gui_input(event):
	if (event is InputEventMouseButton and event.button_index == 1):
		mouse_button_down = event.pressed;
	if (event is InputEventMouseMotion and mouse_button_down):
		scroll_container.scroll_horizontal -= event.relative.x
	if (event is InputEventScreenDrag):
		scroll_container.scroll_horizontal -= event.relative.x
