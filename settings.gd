class_name Settings

extends Control

signal close_settings

@onready var clear_data_btn: Button = $MarginContainer/VBoxContainer/VBoxContainer2/ClearDataBtn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_close_btn_pressed() -> void:
	close_settings.emit()
	clear_data_btn.disabled = false


func _on_clear_data_btn_pressed() -> void:
	Globals.clear_save()
	clear_data_btn.disabled = true
