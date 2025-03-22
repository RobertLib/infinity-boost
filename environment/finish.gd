class_name Finish

extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _draw() -> void:
	draw_circle(Vector2.ZERO, 50, Color(0.1, 1, 1, 1))
