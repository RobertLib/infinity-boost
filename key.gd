class_name Key

extends Area2D

signal picked(key: Key)

enum Type { RED, GREEN, BLUE }

@export var type: Type = Type.RED

var color := Color(1, 1, 1, 1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match type:
		Type.RED:
			color = Color(1, 0, 0, 1)
		Type.GREEN:
			color = Color(0, 1, 0, 1)
		Type.BLUE:
			color = Color(0, 0, 1, 1)

	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _draw() -> void:
	draw_circle(Vector2.ZERO, 15, color)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		picked.emit(self)
		queue_free()
