extends Node3D


var player = preload("res://scenes/player.tscn").instantiate()


func _ready() -> void:
	var map = MapLayer.new(16, 16)
	var map_grid = map.build_grid_map()

	add_child(player)
	player.setup(map.get_simple_grid(), map.s_cell)

	add_child(map_grid)


func _physics_process(_delta: float) -> void:
	var camera = $Camera3D
	camera.position = player.position + Vector3(-0.5, 4, 2.5)
	camera.look_at(player.position)
