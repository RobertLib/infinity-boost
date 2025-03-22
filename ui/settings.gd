class_name Settings

extends PanelContainer

signal close_settings

@onready var clear_data_btn: Button = $VBoxContainer/VBoxContainer2/ClearDataBtn
@onready var clear_data_confirm: ConfirmationDialog = $ClearDataConfirm


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_close_btn_pressed() -> void:
	close_settings.emit()
	clear_data_btn.disabled = false


func _on_go_to_list_pressed() -> void:
	Globals.change_scene("screens/levels_menu")


func _on_clear_data_btn_pressed() -> void:
	clear_data_confirm.popup_centered()


func _on_clear_data_confirm_confirmed() -> void:
	Globals.clear_save()
	Globals.reached_level = 0
	Globals.change_scene("screens/main_menu")
