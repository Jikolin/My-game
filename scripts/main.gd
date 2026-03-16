extends Node3D


var player = preload("res://scenes/enitites/player.tscn").instantiate()
var player_s_pos: Vector2i
var map: MapLayer
var map_grid: GridMap


func _ready() -> void:
	map = MapLayer.new(16, 16)
	map_grid = map.build_grid_map()

	add_child(player)
	player.setup(map.get_simple_grid(), map.s_cell)
	player_s_pos = Vector2i(player.position.x - 0.5, player.position.z - 0.5)
	player.enter_the_room.connect(enter_the_room)

	add_child(map_grid)


func _physics_process(_delta: float) -> void:
	var camera = $Camera3D
	camera.position = player.position + Vector3(-0.7, 2.5, 2.5)
	camera.look_at(player.position)


func enter_the_room(coords: Vector2i) -> void:
	if !player.is_in_the_room:
		player.position = Vector3(0, 0, 0)
		var player_grid_pos = Vector2i(player.position.x-0.5, player.position.z-0.5)
		map.generate_room(coords, player_grid_pos)
		var room = map.build_room(coords, map)
		add_child(room)
		player.reparent(room)
		map_grid.hide()
		#process_mode = Node.PROCESS_MODE_DISABLED
