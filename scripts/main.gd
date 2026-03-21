extends Node3D


var player = preload("res://scenes/enitites/player.tscn").instantiate()
var player_s_pos: Vector2i
var map: MapLayer
var map_grid: GridMap

var room


func _ready() -> void:
	map = MapLayer.new(16, 16)
	map_grid = map.build_grid_map()

	add_child(player)
	player.setup(map.get_simple_grid(), map.s_cell)
	player_s_pos = Vector2i(player.position.x - 0.5, player.position.z - 0.5)
	player.enter_the_room.connect(enter_the_room)
	player.exit_the_room.connect(exit_the_room)

	add_child(map_grid)


func _physics_process(_delta: float) -> void:
	var camera = $Camera3D
	camera.position = player.position + Vector3(-0.7, 2.5, 2.5)
	camera.look_at(player.position)


func enter_the_room(coords: Vector2i) -> void:
	if !player.is_in_the_room:
		player.position = Vector3(0, 0, 0)
		var player_grid_pos = Vector2i(player.position.x-0.5, player.position.z-0.5)
		if !map.grid[player_grid_pos.x][player_grid_pos.y]:
			map.generate_room(coords, player_grid_pos)
		room = map.build_room(coords, map)
		add_child(room)
		map_grid.hide()


func exit_the_room() -> void:
	remove_child(room)
	map_grid.show()
