extends CharacterBody3D
class_name Player


var step_speed = 3
var step_size = 2
var is_moving = false
var target_pos = Vector3.ZERO
var animation_p: AnimationPlayer

var map_grid: Array
enum CellType { WALL, BRIDGE, ROOM, START }


func _ready() -> void:
	#animation_p = $Model/AnimationPlayer
	#animation_p.speed_scale = 2.0
	pass


func _physics_process(delta: float) -> void:
	if is_moving:
		#animation_p.play("2762272363296_TempMotion")
		var new_pos = position.move_toward(target_pos, step_speed * delta)
		position = new_pos
		
		if position.distance_to(target_pos) < 0.01:
			position = target_pos
			is_moving = false
	else:
		#animation_p.stop()
		pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		_try_move(Vector3(step_size, 0.0, 0.0))
	elif event.is_action_pressed("left"):
		_try_move(Vector3(-step_size, 0.0, 0.0))
	elif event.is_action_pressed("up"):
		_try_move(Vector3(0.0, 0.0, -step_size))
	elif event.is_action_pressed("down"):
		_try_move(Vector3(0.0, 0.0, step_size))


func _try_move(dir: Vector3) -> void:
	if _move_is_possible(dir) and !is_moving:
		$".".basis = Basis.looking_at(-dir)
		is_moving = true
		target_pos += dir


func _move_is_possible(dir: Vector3) -> bool:
	var grid_pos = Vector2i(floor(position.x), floor(position.z))
	var grid_dir = Vector2i(dir.x / step_size, dir.z / step_size)
	var new_grid_pos = grid_pos + grid_dir

	if new_grid_pos.y < 0 or new_grid_pos.y >= map_grid.size():
		return false
	if new_grid_pos.x < 0 or new_grid_pos.x >= map_grid[0].size():
		return false

	var new_cell = map_grid[new_grid_pos.y][new_grid_pos.x]
	return new_cell in [CellType.ROOM, CellType.START, CellType.BRIDGE]
