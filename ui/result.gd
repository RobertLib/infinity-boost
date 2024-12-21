class_name Result

extends CenterContainer

@onready var label: Label = $PanelContainer/VBoxContainer/Label
@onready var next_level_btn: Button = $PanelContainer/VBoxContainer/NextLevelBtn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func level_completed() -> void:
	label.text = "Level completed"
	next_level_btn.visible = true
	get_tree().paused = true
	show()


func level_failed() -> void:
	label.text = "Level failed"
	get_tree().paused = true
	show()


func time_out() -> void:
	label.text = "Time out"
	get_tree().paused = true
	show()


func _exit_tree() -> void:
	get_tree().paused = false


func _on_go_to_list_btn_pressed() -> void:
	Globals.change_scene("screens/levels_menu")


func _on_restart_btn_pressed() -> void:
	Globals.restart_level()


func _on_next_level_btn_pressed() -> void:
	Globals.next_level()
