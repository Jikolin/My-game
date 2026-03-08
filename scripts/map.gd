extends Node3D
class_name MapLayer


enum CellType{WALL, BRIDGE, ROOM, START}
enum CellState{OUT_OF_GRID, USED, FREE}


class Cell:
	var x: int
	var y: int
	var type: CellType
	var dir: Vector2i

	func _init(coords: Vector2i, p_type: CellType, p_dir: Vector2i) -> void:
		y = coords.y
		x = coords.x
		type = p_type
		dir = p_dir


var width: int
var height: int
var s_cell = Vector2i.ZERO
var grid: Array = []

const DIRECTIONS = [
	Vector2i(0, -1),	#UP
	Vector2i(1, 0), 	#RIGHT
	Vector2i(0, 1), 	#DOWN
	Vector2i(-1, 0)		#LEFT
]


func _init(n_width: int, n_height: int) -> void:
	width = n_width
	height = n_height

	for y in range(height):
		var row = []
		for x in range(width):
			row.append(Cell.new(Vector2i.ZERO, CellType.WALL, Vector2i.ZERO))
		grid.append(row)

	s_cell = Vector2i(randi() % width, randi() % height)
	change_cell(s_cell, CellType.START, Vector2i.ZERO)

	generate_labyrinth()
	print_grid()


func change_cell(coords: Vector2i, p_type: CellType, p_dir: Vector2i) -> void:
	grid[coords.y][coords.x].type = p_type
	grid[coords.y][coords.x].dir = p_dir


func print_grid() -> void:
	var output = "\n    "
	for x in range(width):
		output += str(x).pad_zeros(2) + " "
	output += "\n"

	for y in range(height):
		output += str(y).pad_zeros(2) + " | "
		for x in range(width):
			match grid[y][x].type:
				CellType.ROOM: output += "@  "
				CellType.BRIDGE: output += "%  "
				CellType.WALL: output += "#  "
				CellType.START: output += "S  "
		output += "\n"
	print(output)


func get_cell_state(coords: Vector2i) -> CellState:
	if coords.y >= height or coords.y < 0 or coords.x >= width or coords.x < 0:
		return CellState.OUT_OF_GRID
	else:
		if grid[coords.y][coords.x].type == CellType.WALL:
			return CellState.FREE
	return CellState.USED


func get_poss_cells(coords: Vector2i) -> Array:
	var cells: Array = []
	for dir in DIRECTIONS:
		var cell = coords
		cell.y += dir.y
		cell.x += dir.x
		match get_cell_state(cell):
			CellState.FREE: 
				match get_cell_state(Vector2i(cell.x+dir.x, cell.y+dir.y)):
					CellState.FREE: cells.append(Cell.new(cell, CellType.WALL, dir))
			_: continue
	return cells


func generate_labyrinth() -> void:
	var curr_cell = s_cell
	var priority_cells = [curr_cell]
	var content_value = height * width * 0.5

	for _i in range(content_value):
		var way_lenght = randi_range(3, 5)
		for _a in range(way_lenght):
			var poss_cells = get_poss_cells(curr_cell)
			if poss_cells.is_empty():
				priority_cells.erase(curr_cell)
				#priority_cells.shuffle()
				if len(priority_cells) > 0:
					curr_cell = priority_cells[0]
				break

			poss_cells.shuffle()
			var n_cell = poss_cells[0]
			change_cell(Vector2i(n_cell.x, n_cell.y), CellType.BRIDGE, n_cell.dir)
			n_cell.y += n_cell.dir.y
			n_cell.x += n_cell.dir.x
			change_cell(Vector2i(n_cell.x, n_cell.y), CellType.ROOM, Vector2i.ZERO)
			curr_cell = Vector2i(n_cell.x, n_cell.y)
			priority_cells.append(curr_cell)


func build_grid_map() -> GridMap:
	var grid_map = GridMap.new()
	grid_map.cell_size = Vector3(1.0, 0.375, 1.0)
	grid_map.mesh_library = load("res://assets/map/labyrinth.tres")
	for y in range(height):
		for x in range(width):
			var cell = grid[y][x]
			match cell.type:
				CellType.ROOM: grid_map.set_cell_item(Vector3i(x, -2, y), 1)
				CellType.START: grid_map.set_cell_item(Vector3i(x, -2, y), 1)
				CellType.BRIDGE:
					var orientation = 0
					if cell.dir == DIRECTIONS[0]:
						orientation = 16
					elif cell.dir == DIRECTIONS[1]:
						orientation = 10
					elif cell.dir == DIRECTIONS[2]:
						orientation = 16
					elif cell.dir == DIRECTIONS[3]:
						orientation = 10

					grid_map.set_cell_item(Vector3i(x, -2, y), 0, orientation)

	return grid_map


func get_simple_grid() -> Array:
	var simple_grid = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(grid[y][x].type)
		simple_grid.append(row)

	return simple_grid
