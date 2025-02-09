extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.load()

	var grid_container := $MarginContainer/GridContainer

	for i in range(grid_container.get_child_count()):
		var button: Button = grid_container.get_child(i)
		button.connect("pressed", _on_button_pressed.bind(button))

		if i > Globals.reached_level:
			button.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed(button: Button) -> void:
	Globals.change_level(int(button.text))
