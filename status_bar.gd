class_name StatusBar

extends Control

@onready var lives := $MarginContainer/Lives as Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update() -> void:
	lives.text = "LIVES: " + str(Globals.lives)
