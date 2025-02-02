extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button: Button in $ScrollContainer/MarginContainer/GridContainer.get_children():
		button.connect("pressed", _on_button_pressed.bind(button))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed(button: Button) -> void:
	Globals.change_level(int(button.text))
