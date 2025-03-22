extends Polygon2D

@export var wall_scene: PackedScene = preload("res://environment/wall.tscn")
@export var wall_thickness := 10.0


func _ready() -> void:
	generate_walls()


func create_wall_between_points(start_point: Vector2, end_point: Vector2) -> void:
	var wall = wall_scene.instantiate()
	add_child(wall)

	var midpoint = (start_point + end_point) / 2
	wall.position = midpoint

	var segment_length = start_point.distance_to(end_point)

	var angle = (end_point - start_point).angle()
	wall.rotation = angle

	wall.scale.x = segment_length / 20.0
	wall.scale.y = wall_thickness / 20.0


func generate_walls() -> void:
	for i in range(polygon.size()):
		var start_point = polygon[i]
		var end_point = polygon[(i + 1) % polygon.size()]
		create_wall_between_points(start_point, end_point)
