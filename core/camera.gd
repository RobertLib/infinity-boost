class_name Camera

extends Camera2D

@export var target_node: Node2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if target_node != null:
		position = target_node.global_position
