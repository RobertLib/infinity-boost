class_name StatusBar

extends Control

@onready var livesLabel: Label = $MarginContainer/HBoxContainer/LivesLabel
@onready var timeLabel: Label = $MarginContainer/HBoxContainer/TimeLabel
@onready var settings: Settings = $Settings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update(lives: int, time: float) -> void:
	livesLabel.text = "LIVES: " + str(lives)
	timeLabel.text = "TIME: " + str(int(time))


func _on_settings_btn_pressed() -> void:
	settings.visible = true
	get_tree().paused = true


func _on_settings_close_settings() -> void:
	settings.visible = false
	get_tree().paused = false
