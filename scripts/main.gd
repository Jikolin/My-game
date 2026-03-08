extends Node3D


func _ready() -> void:
	var map = MapLayer.new(15, 15)
	var grid = map.build_grid_map()
	add_child(grid)

	var player = $Player
	player.position = Vector3(map.s_cell.x+0.5, 0.0, map.s_cell.y+0.5)
	player.target_pos = player.position
	player.map_grid = map.get_simple_grid()


func _physics_process(_delta: float) -> void:
	var player = $Player
	var camera = $Camera3D
	camera.position = player.position + Vector3(-0.5, 3, 2)
	camera.look_at(player.position)
