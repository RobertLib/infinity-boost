extends Control

@export var number_of_parts := 2
@export var dir := -1
@export var speed := 50

var part_size = Vector2(40, 40)

@onready var tmp_part: AnimatableBody2D = $Part


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(number_of_parts):
		var part = tmp_part.duplicate()
		part.position.x = (size.x + part_size.x) / number_of_parts * i
		add_child(part)

	remove_child(tmp_part)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for part in get_children():
		if part.is_in_group("obstacle"):
			part.position.x += speed * dir * delta

			if dir == 1:
				if part.position.x > size.x:
					part.position.x = -part_size.x
			else:
				if part.position.x < -part_size.x:
					part.position.x = size.x
