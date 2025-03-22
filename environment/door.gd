extends Polygon2D

enum Type { RED, GREEN, BLUE }

@export var type: Type = Type.RED


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match type:
		Type.RED:
			color = Color(1, 0, 0)
		Type.GREEN:
			color = Color(0, 1, 0)
		Type.BLUE:
			color = Color(0, 0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
