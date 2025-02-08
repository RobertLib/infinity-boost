class_name StatusBar

extends Control

@onready var lives: Label = $MarginContainer/HBoxContainer/LivesLabel
@onready var time: Label = $MarginContainer/HBoxContainer/TimeLabel
@onready var settings: Settings = $Settings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update() -> void:
	lives.text = "LIVES: " + str(Globals.lives)
	time.text = "TIME: " + str(int(Globals.time))


func _on_settings_btn_pressed() -> void:
	settings.visible = true
	get_tree().paused = true


func _on_settings_close_settings() -> void:
	settings.visible = false
	get_tree().paused = false
