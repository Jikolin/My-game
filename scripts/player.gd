extends CharacterBody3D
class_name Player


signal enter_the_room(coords: Vector2i)
var map_pos: Vector3
signal exit_the_room()

var speed := 3.5
var target_velocity = Vector3.ZERO

var step_speed := 3
const step_size := 2
var is_moving := false
var is_in_the_room := false

var target_pos := Vector3.ZERO
var target_rot := Basis.IDENTITY

const move_indicator := preload("res://scenes/move_ind.tscn")
var indicators_container := Node3D.new()

var map_grid: Array
enum CellType { WALL, BRIDGE, ROOM, START }
const DIRECTIONS = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]


func setup(i_map_grid: Array, pos: Vector2i) -> void:
	map_grid = i_map_grid
	position = Vector3(pos.x + 0.5, 0.0, pos.y + 0.5)
	target_pos = position
	target_rot = Basis.looking_at(Vector3.FORWARD)

	add_child(indicators_container)
	indicators_container.top_level = true
	_show_poss_moves()


func _unhandled_input(event: InputEvent) -> void:
	if !is_in_the_room:
		if event.is_action_pressed("right"):
			_try_move(Vector3(1, 0, 0))
		elif event.is_action_pressed("left"):
			_try_move(Vector3(-1, 0, 0))
		elif event.is_action_pressed("up"):
			_try_move(Vector3(0, 0, -1))
		elif event.is_action_pressed("down"):
			_try_move(Vector3(0, 0, 1))

		if !is_moving:
			if event.is_action_pressed("switch_map"):
				map_pos = position
				enter_the_room.emit(Vector2i(position.x-0.5, position.z-0.5))
				is_in_the_room = true

	#elif !is_moving:
	else:	
		if event.is_action_pressed("switch_map"):
			exit_the_room.emit()
			is_in_the_room = false
			position = map_pos


func _try_move(direction: Vector3):
	if _is_move_possible(direction) and !is_moving:
		_clear_indicators()
		is_moving = true
		target_pos += Vector3(direction.x, direction.y, direction.z) * step_size
		target_rot = Basis.looking_at(-direction, Vector3.UP)


func _physics_process(delta: float) -> void:
	if is_moving:
		var new_pos = position.move_toward(target_pos, step_speed * delta)
		var curr_basis = basis
		position = new_pos
		basis = curr_basis.slerp(target_rot, 0.25)

		if position.distance_to(target_pos) < 0.01:
			position = target_pos
			is_moving = false
			_show_poss_moves()

	if is_in_the_room:
		var direction = Vector3.ZERO

		if Input.is_action_pressed("right"):
			direction.x += 1
		if Input.is_action_pressed("left"):
			direction.x -= 1
		if Input.is_action_pressed("down"):
			direction.z += 1
		if Input.is_action_pressed("up"):
			direction.z -= 1

		if direction != Vector3.ZERO:
			direction = direction.normalized()
			target_rot = Basis.looking_at(-direction, Vector3.UP)
			var curr_basis = basis
			basis = curr_basis.slerp(target_rot, 0.25)

		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed

		velocity = target_velocity
		move_and_slide()

	#elif !is_in_the_room:
		#enter_the_room.emit(Vector2i(position.x-0.5, position.z-0.5))
		#is_in_the_room = true


func _is_move_possible(direction: Vector3) -> bool:
	var grid_pos = Vector2(position.x - 0.5 + direction.x, position.z - 0.5 + direction.z)
	if grid_pos.x < 0 or grid_pos.x >= map_grid.size():
		return false
	elif grid_pos.y < 0 or grid_pos.y >= map_grid[0].size():
		return false

	return map_grid[grid_pos.x][grid_pos.y] in [CellType.START, CellType.BRIDGE, CellType.ROOM]


func _show_poss_moves() -> void:
	for dir in DIRECTIONS:
		if _is_move_possible(Vector3(dir.x, 0, dir.y)):
			var indicator = move_indicator.instantiate()
			indicators_container.add_child(indicator)
			indicator.global_position = Vector3(position.x + dir.x, 0, position.z + dir.y)
			indicator.move_to.connect(_move_to)
			indicator.dir = Vector3(dir.x, 0, dir.y)


func _move_to(direction: Vector3) -> void:
	_try_move(direction)


func _clear_indicators() -> void:
	for child in indicators_container.get_children():
		child.queue_free()
